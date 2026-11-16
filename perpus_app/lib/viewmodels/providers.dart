import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../core/routes/app_router.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Provider untuk penyimpanan token.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider untuk API Service.
final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.read(storageServiceProvider);

  final dio = DioClient.build(
    storage,
    onUnauthorized: redirectToLogin,
  );

  return ApiService(dio);
});

// Provider untuk Auth Repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});

// Provider untuk Book Repository.
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(
    ref.read(apiServiceProvider),
  );
});

// Provider untuk mengambil data profil pengguna.
final profileProvider = FutureProvider<UserModel>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);

  return authRepository.getProfile();
});
