import '../../models/user_content/personal_list.dart';

abstract class IInteractionsPresenter {
  bool get isLoading;
  String? get errorMessage;

  List<PersonalListResponse> get userLists;
  PersonalListWithItems? get selectedListWithItems;
  PersonalListResponse? get currentListResponse;
  PersonalListItemResponse? get currentListItemResponse;

  Future<void> createList(String name, {String? description});
  Future<void> getUserLists();
  Future<void> getListWithItems(int listId, {int page = 1, int perPage = 20});
  Future<void> updateList(int listId, {String? name, String? description});
  Future<void> deleteList(int listId);
  Future<void> addMediaToList(int listId, int mediaId);
  Future<void> removeMediaFromList(int listId, int mediaId);
}