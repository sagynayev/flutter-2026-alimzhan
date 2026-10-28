import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartTotal extends StatelessWidget {
  const CartTotal({super.key});

  @override
  Widget build(BuildContext context) {
    final total = context.select<Cart, int>((cart) => cart.total);
    return Center(child: Text('$total ₸'));
  }
}

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final count = context.select<Cart, int>((cart) => cart.count);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Badge(
        label: Text('$count'),
        child: IconButton(
          tooltip: 'Cart',
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
