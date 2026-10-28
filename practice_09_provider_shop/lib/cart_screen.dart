import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            onPressed: () => _clearCart(context),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                if (cart.items.isEmpty) {
                  return const Center(child: Text('The cart is empty'));
                }

                return ListView.separated(
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final book = cart.items[index];
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.price} ₸  ×${cart.qtyOf(book)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Increment',
                            onPressed: () => cart.increment(book),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => cart.remove(book),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<Cart>(
            child: const _TotalLabel(),
            builder: (context, cart, child) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      child!,
                      const Spacer(),
                      Text(
                        '${cart.total} ₸',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.receipt_long_outlined),
        SizedBox(width: 8),
        Text('Total'),
      ],
    );
  }
}
