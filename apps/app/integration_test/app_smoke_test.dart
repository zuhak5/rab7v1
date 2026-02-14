import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app smoke placeholder', (tester) async {
    // Placeholder integration test. Add full app bootstrap once environment
    // credentials are available in CI.
    expect(true, isTrue);
  });
}
