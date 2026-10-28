import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$total ₸'),
        const SizedBox(width: 6),
        Badge(
          label: Text('$count'),
          child: IconButton(
            tooltip: 'Cart',
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
