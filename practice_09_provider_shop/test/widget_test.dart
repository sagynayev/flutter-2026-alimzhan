import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sagynayev_alimzhan_practice_09/main.dart';
import 'package:sagynayev_alimzhan_practice_09/models/book.dart';
import 'package:sagynayev_alimzhan_practice_09/models/cart.dart';

void main() {
  test('cart rejects duplicates and tracks quantity', () {
    final cart = Cart();

    expect(cart.add(books.first), isTrue);
    expect(cart.add(books.first), isFalse);
    cart.increment(books.first);

    expect(cart.count, 1);
    expect(cart.qtyOf(books.first), 2);
    expect(cart.total, books.first.price * 2);
  });

  testWidgets('adds a book and changes its quantity', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    expect(find.text('Sagynayev Alimzhan'), findsOneWidget);
    await tester.tap(find.text('Add').first);
    await tester.pump();
    expect(find.text('Added'), findsWidgets);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increment'));
    await tester.pump();

    expect(find.text('4200 ₸  ×2'), findsOneWidget);
    expect(find.text('8400 ₸'), findsOneWidget);
  });
}
