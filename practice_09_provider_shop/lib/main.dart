import 'package:flutter/material.dart';

import 'book.dart';
import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];

  int get _total => _cart.fold(0, (sum, book) => sum + book.price);

  void _add(Book book) => setState(() => _cart.add(book));

  void _remove(Book book) => setState(() => _cart.remove(book));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practice 9 - Sagynayev Alimzhan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      routes: {
        '/': (_) => BooksScreen(cart: _cart, total: _total, onAdd: _add),
        '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
      },
    );
  }
}
