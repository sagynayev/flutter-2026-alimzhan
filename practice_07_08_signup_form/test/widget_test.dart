import 'package:flutter_test/flutter_test.dart';
import 'package:sagynayev_alimzhan_practices_7_8/main.dart';

void main() {
  testWidgets('shows the practice and student details', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(practiceTitle), findsOneWidget);
    expect(find.text(studentName), findsWidgets);
    expect(find.text('Student name'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
