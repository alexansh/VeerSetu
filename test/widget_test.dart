import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak_sense/main.dart';

void main() {
  testWidgets('RakshakSense renders Jawan Companion and MO Console views cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RakshakSenseApp());
    await tester.pumpAndSettle();

    // Verify Top Bar Branding
    expect(find.text('RAKSHAK SENSE'), findsOneWidget);
    expect(find.text('Jawan / Personnel Companion'), findsOneWidget);
    expect(
      find.text('Unit Medical Officer & Commander Console'),
      findsOneWidget,
    );

    // Verify Screen 1: Privacy Guardrail & Initial FRSI Score (78/100)
    expect(
      find.textContaining('MHA Medical Confidentiality'),
      findsOneWidget,
    );
    expect(find.text('Combat Ready'), findsOneWidget);
    expect(find.text('72 bpm'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('+1.5h'), findsOneWidget);

    // Toggle to Screen 2: Unit Medical Officer & Commander Console
    await tester.tap(find.text('Unit Medical Officer & Commander Console'));
    await tester.pumpAndSettle();

    // Verify KPI Cards
    expect(find.text('120'), findsOneWidget);
    expect(find.text('104 (86%)'), findsOneWidget);
    expect(find.text('12 (10%)'), findsOneWidget);
    expect(find.text('4 (4%)'), findsOneWidget);

    // Verify Triage Roster Personnel
    expect(find.text('Constable Rajesh Kumar (B Co.)'), findsOneWidget);
    expect(find.text('Havildar Surender Singh (Post 3)'), findsOneWidget);
    expect(find.text('Constable Amit Verma (A Co.)'), findsOneWidget);
  });
}
