import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'auth_service.dart';
import 'media_service.dart';
import 'interactions_service.dart';
import 'profile_service.dart';

class ApiService {
  late final ApiClient client;
  late final AuthService auth;
  late final MediaService media;
  late final InteractionsService interactions;
  late final ProfileService profile;

  ApiService() {
    client = ApiClient();
    auth = AuthService(client);
    media = MediaService(client);
    interactions = InteractionsService(client);
    profile = ProfileService(client);
  }

  Future<void> initialize() async {
    final isLoggedIn = await client.isLoggedIn();
    if (isLoggedIn) {
      try {
        await profile.getProfile();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void dispose() {
    client.dio.close();
  }
}

final apiService = ApiService();