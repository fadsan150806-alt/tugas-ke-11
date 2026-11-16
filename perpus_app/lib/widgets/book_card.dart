import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  });

  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel(int stock) {
    return stock == 0
        ? 'Stok: 0 (Habis)'
        : 'Stok: $stock';
  }

  @override
  Widget build(BuildContext context) {
    final color = _stockColor(book.stock);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE7F0FF),
          child: Text(
            book.id.toString(),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${book.author} · ${book.publishedYear} · ',
              ),
              TextSpan(
                text: _stockLabel(book.stock),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.blue,
              ),
              tooltip: 'Edit Buku',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              tooltip: 'Hapus Buku',
              onPressed: onDelete,
            ),
          ],
        ),

        onTap: onDetail,
      ),
    );
  }
}
