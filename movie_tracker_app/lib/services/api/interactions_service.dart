import 'package:dio/dio.dart';

import '../../../models/user_content/personal_list.dart';

import 'api_client.dart';
import 'error_handler.dart';

class InteractionsService {
  final ApiClient _apiClient;
  final _baseEndpoint = '/interactions';

  InteractionsService(this._apiClient);

  Future<PersonalListResponse> createList(PersonalListCreate request) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/lists',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PersonalListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<PersonalListResponse>> getUserLists() async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/lists');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => PersonalListResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<PersonalListWithItems> getListWithItems({
    required int listId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/lists/$listId',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return PersonalListWithItems.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<PersonalListResponse> updateList({
    required int listId,
    required PersonalListUpdate request,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '$_baseEndpoint/lists/$listId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PersonalListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> deleteList(int listId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseEndpoint/lists/$listId');

      if (response.statusCode != 204) {
        throw ErrorHandler.handleError(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<PersonalListItemResponse> addMediaToList({
    required int listId,
    required int mediaId,
  }) async {
    try {
      final request = PersonalListItemAdd(mediaId: mediaId);
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/lists/$listId/items',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PersonalListItemResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> removeMediaFromList({
    required int listId,
    required int mediaId,
  }) async {
    try {
      final response = await _apiClient.dio.delete(
        '$_baseEndpoint/lists/$listId/items/$mediaId',
      );

      if (response.statusCode != 204) {
        throw ErrorHandler.handleError(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}