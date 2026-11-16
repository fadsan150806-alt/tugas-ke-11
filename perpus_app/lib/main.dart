import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

import 'models/book_model.dart';

import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/splash_view.dart';

import 'views/books/books_view.dart';
import 'views/books/book_detail_view.dart';

import 'views/profile/profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengaktifkan format tanggal bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  // Menjadikan bahasa Indonesia sebagai format tanggal default.
  Intl.defaultLocale = 'id_ID';

  runApp(
    const ProviderScope(
      child: PerpusApp(),
    ),
  );
}

class PerpusApp extends StatelessWidget {
  const PerpusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      navigatorKey: navigatorKey,

      initialRoute: AppRoutes.splash,

      routes: {
        // Halaman awal
        AppRoutes.splash: (context) => const SplashView(),

        // Halaman autentikasi
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.register: (context) => const RegisterView(),

        // Halaman daftar buku
        AppRoutes.books: (context) => const BooksView(),

        // Halaman detail buku
        AppRoutes.bookDetail: (context) {
          final book =
              ModalRoute.of(context)!.settings.arguments as BookModel;

          return BookDetailView(book: book);
        },

        // Halaman profil pengguna
        AppRoutes.profile: (context) => const ProfileView(),
      },
    );
  }
}
