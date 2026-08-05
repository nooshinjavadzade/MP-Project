import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/movie/movie_details.dart';
import 'package:movie_tracker_app/models/user_content/personal_list.dart';
import 'package:movie_tracker_app/presenters/interactions/interactions_presenter.dart';
import 'package:movie_tracker_app/services/api/interactions_service.dart';

class FakeInteractionsService implements InteractionsService {
  bool shouldThrowError = false;

  final DateTime _dummyDate = DateTime(2026, 1, 1);

  @override
  Future<PersonalListResponse> createList(PersonalListCreate request) async {
    if (shouldThrowError) throw Exception('Create list failed');
    return PersonalListResponse(
      id: 1,
      userId: 10,
      name: request.name,
      description: request.description,
      isDefault: false,
      createdAt: _dummyDate,
    );
  }

  @override
  Future<List<PersonalListResponse>> getUserLists() async {
    if (shouldThrowError) throw Exception('Fetch lists failed');
    return [
      PersonalListResponse(
        id: 1,
        userId: 10,
        name: 'Favorites',
        description: 'My favorites',
        isDefault: false,
        createdAt: _dummyDate,
      ),
    ];
  }

  @override
  Future<PersonalListWithItems> getListWithItems({
    required int listId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (shouldThrowError) throw Exception('Get list items failed');
    return PersonalListWithItems(
      id: listId,
      userId: 10,
      name: 'List $listId',
      isDefault: false,
      createdAt: _dummyDate,
      items: const [],
      itemCount: 0,
    );
  }

  @override
  Future<PersonalListResponse> updateList({
    required int listId,
    required PersonalListUpdate request,
  }) async {
    if (shouldThrowError) throw Exception('Update list failed');
    return PersonalListResponse(
      id: listId,
      userId: 10,
      name: request.name ?? 'Updated',
      isDefault: false,
      createdAt: _dummyDate,
    );
  }

  @override
  Future<void> deleteList(int listId) async {
    if (shouldThrowError) throw Exception('Delete list failed');
  }

  @override
  Future<PersonalListItemResponse> addMediaToList({
    required int listId,
    required int mediaId,
  }) async {
    if (shouldThrowError) throw Exception('Add media failed');
    return PersonalListItemResponse(
      id: 100,
      listId: listId,
      mediaId: mediaId,
      media: const MovieDetails(id: 1, tmdbId: "550", title: 'Sample Movie'),
      addedAt: _dummyDate,
    );
  }

  @override
  Future<void> removeMediaFromList({
    required int listId,
    required int mediaId,
  }) async {
    if (shouldThrowError) throw Exception('Remove media failed');
  }
}

void main() {
  late FakeInteractionsService fakeService;
  late InteractionsPresenter presenter;

  setUp(() {
    fakeService = FakeInteractionsService();
    presenter = InteractionsPresenter(fakeService);
  });

  group('InteractionsPresenter Tests', () {
    test('getUserLists populates userLists list on success', () async {
      await presenter.getUserLists();

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.userLists.length, 1);
      expect(presenter.userLists.first.name, 'Favorites');
    });

    test('createList updates currentListResponse', () async {
      await presenter.createList('Watch Later', description: 'Movies to watch');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.currentListResponse?.name, 'Watch Later');
    });

    test('getListWithItems sets selectedListWithItems', () async {
      await presenter.getListWithItems(42);

      expect(presenter.isLoading, false);
      expect(presenter.selectedListWithItems?.id, 42);
    });

    test('addMediaToList sets currentListItemResponse', () async {
      await presenter.addMediaToList(1, 99);

      expect(presenter.isLoading, false);
      expect(presenter.currentListItemResponse?.mediaId, 99);
    });

    test('error handling sets errorMessage correctly', () async {
      fakeService.shouldThrowError = true;

      await presenter.getUserLists();

      expect(presenter.isLoading, false);
      expect(presenter.userLists, isEmpty);
      expect(presenter.errorMessage, contains('Fetch lists failed'));
    });
  });
}