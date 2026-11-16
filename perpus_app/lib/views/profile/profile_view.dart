import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/providers.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';
import '../../core/routes/app_router.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  Widget _profileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17365D),
        elevation: 0,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),

            child: profile.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      const Text('Gagal mengambil data profil'),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(profileProvider);
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),

              data: (user) {
                final date = user.createdAt == null
                    ? '-'
                    : DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(user.createdAt!);

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(28),

                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              const Color(0xFFE7F0FF),
                          child: const Icon(
                            Icons.person,
                            size: 55,
                            color: Color(0xFF2563EB),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Pengguna Perpustakaan',
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 25),
                        const Divider(),

                        _profileItem(
                          Icons.person_outline,
                          'Nama Lengkap',
                          user.name,
                        ),

                        _profileItem(
                          Icons.email_outlined,
                          'Email',
                          user.email,
                        ),

                        _profileItem(
                          Icons.calendar_month_outlined,
                          'Tanggal Bergabung',
                          date,
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,

                          child: FilledButton.icon(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(authProvider.notifier)
                                    .logout();

                                ref
                                    .read(bookProvider.notifier)
                                    .reset();

                                ref.invalidate(profileProvider);

                                if (!context.mounted) return;

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (_) => false,
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Logout gagal: $e',
                                    ),
                                  ),
                                );
                              }
                            },

                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),

                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
