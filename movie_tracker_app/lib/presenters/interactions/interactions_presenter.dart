import 'package:flutter/foundation.dart';
import '../../models/user_content/personal_list.dart';
import '../../services/api/interactions_service.dart';
import '../../services/local/local_storage_service.dart';
import 'i_interactions_presenter.dart';

class InteractionsPresenter extends ChangeNotifier implements IInteractionsPresenter {
  final InteractionsService _interactionsService;
  final LocalStorageService _localStorageService;

  bool _isLoading = false;
  String? _errorMessage;

  List<PersonalListResponse> _userLists = [];
  PersonalListWithItems? _selectedListWithItems;
  PersonalListResponse? _currentListResponse;
  PersonalListItemResponse? _currentListItemResponse;

  InteractionsPresenter(
      this._interactionsService, {
        LocalStorageService? localStorageService,
      }) : _localStorageService = localStorageService ?? LocalStorageService();

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  List<PersonalListResponse> get userLists => _userLists;

  @override
  PersonalListWithItems? get selectedListWithItems => _selectedListWithItems;

  @override
  PersonalListResponse? get currentListResponse => _currentListResponse;

  @override
  PersonalListItemResponse? get currentListItemResponse => _currentListItemResponse;

  @override
  Future<void> createList(String name, {String? description}) async {
    _setLoading(true);
    try {
      final request = PersonalListCreate(name: name, description: description);
      _currentListResponse = await _interactionsService.createList(request);
      if (_currentListResponse != null) {
        _userLists.add(_currentListResponse!);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getUserLists() async {
    _setLoading(true);
    try {
      _userLists = await _interactionsService.getUserLists();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getListWithItems(int listId, {int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _selectedListWithItems = await _interactionsService.getListWithItems(
        listId: listId,
        page: page,
        perPage: perPage,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateList(int listId, {String? name, String? description}) async {
    _setLoading(true);
    try {
      final request = PersonalListUpdate(name: name, description: description);
      _currentListResponse = await _interactionsService.updateList(
        listId: listId,
        request: request,
      );
      if (_currentListResponse != null) {
        final index = _userLists.indexWhere((element) => element.id == listId);
        if (index != -1) {
          _userLists[index] = _currentListResponse!;
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> deleteList(int listId) async {
    _setLoading(true);
    try {
      await _interactionsService.deleteList(listId);
      _userLists.removeWhere((element) => element.id == listId);
      if (_selectedListWithItems?.id == listId) {
        _selectedListWithItems = null;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> addMediaToList(int listId, int mediaId) async {
    _setLoading(true);
    try {
      _currentListItemResponse = await _interactionsService.addMediaToList(
        listId: listId,
        mediaId: mediaId,
      );
      if (_selectedListWithItems?.id == listId) {
        await getListWithItems(listId);
        return;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> removeMediaFromList(int listId, int mediaId) async {
    _setLoading(true);
    try {
      await _interactionsService.removeMediaFromList(
        listId: listId,
        mediaId: mediaId,
      );
      if (_selectedListWithItems?.id == listId) {
        _selectedListWithItems?.items.removeWhere((item) => item.mediaId == mediaId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}