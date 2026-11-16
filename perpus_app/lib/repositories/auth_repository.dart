import '../core/constants/api_constants.dart';
import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  // Registrasi pengguna baru.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _api.post(
      ApiConstants.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return _saveSession(
      res.data as Map<String, dynamic>,
    );
  }

  // Login pengguna.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
        'device_name': 'perpus_app',
      },
    );

    return _saveSession(
      res.data as Map<String, dynamic>,
    );
  }

  // Mengambil data profil pengguna yang sedang login.
  Future<UserModel> getProfile() async {
    final res = await _api.get(ApiConstants.me);

    final data = res.data['data'] as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  // Mengambil kembali sesi pengguna dari token tersimpan.
  // Mengembalikan null jika token tidak tersedia atau tidak valid.
  Future<UserModel?> restoreSession() async {
    if (await _storage.getToken() == null) {
      return null;
    }

    try {
      final res = await _api.get(ApiConstants.me);

      return UserModel.fromJson(
        res.data['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _storage.clearToken();
        return null;
      }

      rethrow;
    }
  }

  // Logout pengguna.
  // Token lokal tetap dihapus meskipun server tidak dapat dihubungi.
  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout);
    } on ApiException {
      // Abaikan error server.
    } finally {
      await _storage.clearToken();
    }
  }

  // Menyimpan token dan mengambil data pengguna.
  Future<UserModel> _saveSession(
    Map<String, dynamic> body,
  ) async {
    await _storage.saveToken(
      body['token'] as String,
    );

    return UserModel.fromJson(
      body['user'] as Map<String, dynamic>,
    );
  }
}
