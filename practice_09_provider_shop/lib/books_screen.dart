import 'package:flutter/material.dart';

import 'book.dart';
import 'cart_badge.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
  });

  final List<Book> cart;
  final int total;
  final void Function(Book) onAdd;

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Books'),
            Text('Sagynayev Alimzhan', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [CartBadge(count: cart.length, total: total)],
      ),
      body: ListView.separated(
        itemCount: books.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final book = books[index];
          debugPrint('row ${book.title}');
          final added = cart.contains(book);

          return ListTile(
            title: Text(book.title),
            subtitle: Text('${book.author} · ${book.price} ₸'),
            trailing: added
                ? const Text('Added')
                : OutlinedButton(
                    onPressed: () => onAdd(book),
                    child: const Text('Add'),
                  ),
          );
        },
      ),
    );
  }
}
