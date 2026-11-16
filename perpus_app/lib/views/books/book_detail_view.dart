import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book_model.dart';
import '../../viewmodels/book_vm.dart';
import '../../views/books/book_form_dialog.dart';

class BookDetailView extends ConsumerWidget {
  final BookModel book;

  const BookDetailView({
    super.key,
    required this.book,
  });

  Color get stockColor {
    if (book.stock == 0) return Colors.red;
    if (book.stock <= 5) return Colors.orange;
    return Colors.green;
  }

  Widget _detailItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 22,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editBook(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookFormDialog(
        book: book,
        onSubmit: (payload) {
          return ref
              .read(bookProvider.notifier)
              .update(book.id, payload);
        },
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteBook(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Buku?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus buku "${book.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final error = await ref
        .read(bookProvider.notifier)
        .delete(book.id);

    if (!context.mounted) return;

    if (error == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text(
          'Detail Buku',
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
            constraints: const BoxConstraints(
              maxWidth: 750,
            ),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 95,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 60,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        book.author,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Divider(),

                    _detailItem(
                      Icons.tag,
                      'ID Buku',
                      book.id.toString(),
                    ),

                    _detailItem(
                      Icons.book,
                      'Judul Buku',
                      book.title,
                    ),

                    _detailItem(
                      Icons.person_outline,
                      'Penulis',
                      book.author,
                    ),

                    _detailItem(
                      Icons.business,
                      'Penerbit',
                      book.publisher ?? '-',
                    ),

                    _detailItem(
                      Icons.qr_code,
                      'ISBN',
                      book.isbn,
                    ),

                    _detailItem(
                      Icons.calendar_month,
                      'Tahun Terbit',
                      book.publishedYear.toString(),
                    ),

                    _detailItem(
                      Icons.inventory_2_outlined,
                      'Jumlah Stok',
                      book.stock.toString(),
                    ),

                    _detailItem(
                      Icons.description_outlined,
                      'Deskripsi',
                      book.description ?? 'Tidak ada deskripsi',
                    ),

                    const SizedBox(height: 15),

                    Center(
                      child: Chip(
                        label: Text(
                          book.stock == 0
                              ? 'Stok Habis'
                              : 'Stok Tersedia: ${book.stock}',
                        ),
                        backgroundColor:
                            stockColor.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _editBook(context, ref),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                _deleteBook(context, ref),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus'),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
