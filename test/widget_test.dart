import 'package:flutter_test/flutter_test.dart';

import 'package:storypath/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const StoryPathApp());
    expect(find.text('StoryPath — Loading...'), findsOneWidget);
  });
}
