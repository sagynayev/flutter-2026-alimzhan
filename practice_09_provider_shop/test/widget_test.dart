import 'package:flutter_test/flutter_test.dart';
import 'package:sagynayev_alimzhan_practice_09/main.dart';

void main() {
  testWidgets('adds a book to the lifted cart', (tester) async {
    await tester.pumpWidget(const Shell());

    expect(find.text('Sagynayev Alimzhan'), findsOneWidget);
    expect(find.text('Added'), findsNothing);

    await tester.tap(find.text('Add').first);
    await tester.pump();

    expect(find.text('Added'), findsOneWidget);
    expect(find.text('4200 ₸'), findsOneWidget);
  });
}
