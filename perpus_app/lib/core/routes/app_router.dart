import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String books = '/books';
  static const String bookDetail = '/books/detail';

  // Route untuk halaman profil pengguna.
  static const String profile = '/profile';
}

/// Navigator global agar interceptor Dio dapat
/// mengarahkan pengguna ke halaman login saat token tidak valid (401).
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void redirectToLogin() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.login,
    (route) => false,
  );
}
