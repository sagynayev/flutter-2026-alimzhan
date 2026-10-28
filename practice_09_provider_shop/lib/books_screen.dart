import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visibleBooks = books.where((book) {
      final query = _search.trim().toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Books'),
            Text('Sagynayev Alimzhan', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: const [CartTotal(), SizedBox(width: 8), CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search books',
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: visibleBooks.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) => BookTile(book: visibleBooks[index]),
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final added = context.select<Cart, bool>(
      (cart) => cart.items.contains(book),
    );

    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final added = context.read<Cart>().add(book);
                if (added) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
