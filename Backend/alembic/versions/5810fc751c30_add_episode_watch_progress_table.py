"""add_episode_watch_progress_table

Revision ID: 5810fc751c30
Revises: 8b833899af09
Create Date: 2026-08-06 22:41:50.978080

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '5810fc751c30'
down_revision: Union[str, Sequence[str], None] = '8b833899af09'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.execute("""
        CREATE TABLE episode_watch_progress (
            user_id INTEGER NOT NULL,
            media_id INTEGER NOT NULL,
            season_number INTEGER NOT NULL,
            episode_number INTEGER NOT NULL,
            status watchstatus NOT NULL DEFAULT 'plan_to_watch',
            watched_at TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE,
            PRIMARY KEY (user_id, media_id, season_number, episode_number),
            FOREIGN KEY (media_id) REFERENCES media (id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
    """)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('episode_watch_progress')