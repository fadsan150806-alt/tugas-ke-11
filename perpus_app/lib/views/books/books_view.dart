import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routes/app_router.dart';
import '../../models/book_model.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';
import '../../widgets/book_card.dart';
import '../../widgets/responsive_layout.dart';
import 'book_detail_view.dart';
import 'book_form_dialog.dart';

class BooksView extends ConsumerStatefulWidget {
  const BooksView({super.key});

  @override
  ConsumerState<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends ConsumerState<BooksView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Timer untuk debounce pencarian.
  Timer? _searchDebounce;

  BookNotifier get _vm => ref.read(bookProvider.notifier);

  @override
  void initState() {
    super.initState();

    _scrollCtrl.addListener(_onScroll);

    Future.microtask(() => _vm.load(search: ''));
  }

  @override
  void dispose() {
    // Membatalkan timer ketika halaman ditutup.
    _searchDebounce?.cancel();

    _searchCtrl.dispose();

    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();

    super.dispose();
  }

  // TUGAS C: Pencarian otomatis dengan debounce 500 ms.
  void _onSearchChanged(String value) {
    // Membatalkan timer pencarian sebelumnya.
    _searchDebounce?.cancel();

    // Menjalankan pencarian setelah berhenti mengetik 500 ms.
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        _vm.load(search: value.trim());
      },
    );
  }

  // Memeriksa posisi scroll.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    if (_scrollCtrl.position.extentAfter < 300) {
      _loadMore();
    }
  }

  // Memuat buku berikutnya.
  Future<void> _loadMore() async {
    final err = await _vm.loadMore();

    if (err != null) {
      _toast(err, isError: true);
    }
  }

  // Menampilkan pesan.
  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      );
  }

  // Membuka form tambah atau edit buku.
  Future<void> _openForm([BookModel? book]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookFormDialog(
        book: book,
        onSubmit: (payload) {
          return book == null
              ? _vm.create(payload)
              : _vm.update(book.id, payload);
        },
      ),
    );

    if (saved == true) {
      _toast(
        book == null
            ? 'Buku berhasil ditambahkan'
            : 'Perubahan berhasil disimpan',
      );
    }
  }

  // Konfirmasi hapus buku.
  Future<void> _confirmDelete(BookModel book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Hapus "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final err = await _vm.delete(book.id);

    _toast(
      err ?? 'Buku berhasil dihapus',
      isError: err != null,
    );
  }

  // Membuka halaman detail buku.
  void _openDetail(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailView(book: book),
      ),
    );
  }

  // Membuka halaman profil.
  void _openProfile() {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
    );
  }

  // Logout pengguna.
  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();

    _vm.reset();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  // Tampilan daftar buku.
  Widget _body(BookState state) {
    if (state.loading && state.books.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _vm.load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _vm.load(),
      child: state.books.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    state.search.isEmpty
                        ? 'Belum ada buku.'
                        : 'Tidak ada buku untuk "${state.search}".',
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                96,
              ),
              itemCount: state.books.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 4),
              itemBuilder: (ctx, i) {
                if (i == state.books.length) {
                  return _footer(state);
                }

                final book = state.books[i];

                return BookCard(
                  key: ValueKey(book.id),
                  book: book,
                  onEdit: () => _openForm(book),
                  onDelete: () => _confirmDelete(book),
                  onDetail: () => _openDetail(book),
                );
              },
            ),
    );
  }

  // Bagian bawah daftar buku.
  Widget _footer(BookState state) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.hasMore) {
      return Center(
        child: TextButton(
          onPressed: _loadMore,
          child: const Text('Muat lebih banyak'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          '${state.books.length} dari ${state.total} buku',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookProvider);

    // Memantau error daftar buku.
    ref.listen(
      bookProvider.select((s) => s.error),
      (_, next) {
        if (next != null &&
            ref.read(bookProvider).books.isNotEmpty) {
          _toast(next, isError: true);
        }
      },
    );

    final userName =
        ref.watch(authProvider.select((s) => s.user?.name)) ?? '';

    // AppBar untuk HP dan desktop.
    final appBar = AppBar(
      title: const Text('Daftar Buku'),
      bottom: state.loading && state.books.isNotEmpty
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(
                minHeight: 2,
              ),
            )
          : null,
      actions: [
        // Tombol refresh.
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Muat ulang',
          onPressed: state.loading ? null : () => _vm.load(),
        ),

        // Tombol profil.
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Profil',
          onPressed: _openProfile,
        ),

        // Tombol logout.
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ],
    );

    // Kolom pencarian otomatis.
    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari judul / penulis...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Hapus pencarian',
            onPressed: () {
              // Batalkan timer yang masih berjalan.
              _searchDebounce?.cancel();

              _searchCtrl.clear();

              // Tampilkan kembali seluruh buku.
              _vm.load(search: '');
            },
          ),
        ),

        // Pencarian otomatis saat mengetik.
        onChanged: _onSearchChanged,

        // Pencarian langsung ketika tombol Enter ditekan.
        onSubmitted: (value) {
          _searchDebounce?.cancel();
          _vm.load(search: value.trim());
        },
      ),
    );

    // Tombol tambah buku.
    final fab = FloatingActionButton.extended(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add),
      label: const Text('Tambah'),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchBar,
        Expanded(
          child: _body(state),
        ),
      ],
    );

    return ResponsiveLayout(
      // Tampilan HP.
      mobile: Scaffold(
        appBar: appBar,
        body: content,
        floatingActionButton: fab,
      ),

      // Tampilan desktop.
      desktop: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.library_books),
                  label: Text('Buku'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Profil'),
                ),
              ],
              selectedIndex: 0,
              labelType: NavigationRailLabelType.all,

              // Navigasi menu desktop.
              onDestinationSelected: (index) {
                if (index == 1) {
                  _openProfile();
                }
              },

              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Text(
                        userName.isEmpty
                            ? '?'
                            : userName[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 72,
                      child: Text(
                        userName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 1),

            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: content,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: fab,
      ),
    );
  }
}
