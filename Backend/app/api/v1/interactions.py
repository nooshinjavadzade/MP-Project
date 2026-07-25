from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List

from app.core.db import get_db
from app.dependencies.auth import get_current_user
from app.models import User, Media, PersonalList, PersonalListItem
from app.schemas.interactions import (
    PersonalListCreate, PersonalListUpdate, PersonalListResponse,
    PersonalListWithItems, PersonalListItemAdd, PersonalListItemResponse,
)


router = APIRouter(tags=["interactions"])


@router.post("/lists", response_model=PersonalListResponse)
async def create_list(
    list_in: PersonalListCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create or update a custom personal list."""
    existing = (
        db.query(PersonalList)
        .filter(
            PersonalList.user_id == current_user.id,
            PersonalList.name == list_in.name,
        )
        .first()
    )

    if existing:
        return HTTPException(status_code=400, detail="A list with this name already exists")

    new_list = PersonalList(
        user_id=current_user.id,
        name=list_in.name,
        description=list_in.description,
        is_default=False,
    )

    db.add(new_list)
    db.commit()
    db.refresh(new_list)

    return new_list


@router.get("/lists", response_model=List[PersonalListResponse])
async def get_user_lists(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all lists for the authenticated user (including default lists)"""
    lists = db.query(PersonalList).filter(PersonalList.user_id == current_user.id).all()
    return lists


@router.get("/lists/{list_id}", response_model=PersonalListWithItems)
async def get_list_with_items(
    list_id: int,
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a personal list with its media items (paginated)"""
    lst = db.query(PersonalList).filter(
        PersonalList.id == list_id,
        PersonalList.user_id == current_user.id
    ).first()
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")

    offset = (page - 1) * per_page
    items = db.query(PersonalListItem).filter(PersonalListItem.list_id == lst.id).order_by(
        PersonalListItem.added_at.desc()
    ).offset(offset).limit(per_page).all()

    media_ids = [item.media_id for item in items]
    media_items = db.query(Media).filter(Media.id.in_(media_ids)).all() if media_ids else []
    media_map = {m.id: m for m in media_items}

    item_responses = []
    for item in items:
        if item.media_id in media_map:
            item_responses.append(PersonalListItemResponse(
                id=item.id,
                list_id=item.list_id,
                media_id=item.media_id,
                media=media_map[item.media_id],
                added_at=item.added_at
            ))

    return PersonalListWithItems(
        **lst.__dict__,
        items=item_responses,
        item_count=len(item_responses)
    )


@router.patch("/lists/{list_id}", response_model=PersonalListResponse)
async def update_list(
    list_id: int,
    list_update: PersonalListUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update list metadata (name, description)"""
    lst = db.query(PersonalList).filter(
        PersonalList.id == list_id,
        PersonalList.user_id == current_user.id
    ).first()
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")

    if lst.is_default:
        raise HTTPException(status_code=400, detail="Cannot modify default lists")

    if list_update.name is not None and list_update.name != lst.name:
        existing = db.query(PersonalList).filter(
            PersonalList.user_id == current_user.id,
            PersonalList.name == list_update.name
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="A list with this name already exists")
        lst.name = list_update.name

    if list_update.description is not None:
        lst.description = list_update.description

    db.commit()
    db.refresh(lst)
    return lst


@router.delete("/lists/{list_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_list(
    list_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a custom list (cannot delete default lists)"""
    lst = db.query(PersonalList).filter(
        PersonalList.id == list_id,
        PersonalList.user_id == current_user.id
    ).first()
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")

    if lst.is_default:
        raise HTTPException(status_code=400, detail="Cannot delete default lists")

    db.delete(lst)
    db.commit()


@router.post("/lists/{list_id}/items", response_model=PersonalListItemResponse)
async def add_media_to_list(
    list_id: int,
    item_in: PersonalListItemAdd,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Add media to a personal list"""
    lst = db.query(PersonalList).filter(
        PersonalList.id == list_id,
        PersonalList.user_id == current_user.id
    ).first()
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")

    media = db.query(Media).filter(Media.id == item_in.media_id).first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")

    existing = db.query(PersonalListItem).filter(
        PersonalListItem.list_id == list_id,
        PersonalListItem.media_id == item_in.media_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Media already in this list")

    new_item = PersonalListItem(list_id=list_id, media_id=item_in.media_id)
    db.add(new_item)
    db.commit()
    db.refresh(new_item)

    return PersonalListItemResponse(
        id=new_item.id,
        list_id=new_item.list_id,
        media_id=new_item.media_id,
        media=media,
        added_at=new_item.added_at
    )


@router.delete("/lists/{list_id}/items/{media_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_media_from_list(
    list_id: int,
    media_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Remove media from a personal list"""
    lst = db.query(PersonalList).filter(
        PersonalList.id == list_id,
        PersonalList.user_id == current_user.id
    ).first()
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")

    item = db.query(PersonalListItem).filter(
        PersonalListItem.list_id == list_id,
        PersonalListItem.media_id == media_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Media not found in this list")

    db.delete(item)
    db.commit()