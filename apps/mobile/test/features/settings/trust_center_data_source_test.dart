import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/features/settings/data/trust_center_data_source.dart';

void main() {
  test('rejects invalid production resource configuration', () {
    const config = TrustCenterConfig(
      supportEmail: 'not-an-email',
      supportUrl: 'http://example.com/support',
      privacyUrl: 'javascript:alert(1)',
      termsUrl: '/terms',
    );

    expect(config.supportUri, isNull);
    expect(config.privacyUri, isNull);
    expect(config.termsUri, isNull);
  });

  test('accepts HTTPS policies and a valid support email', () {
    const config = TrustCenterConfig(
      supportEmail: 'support@example.com',
      privacyUrl: 'https://example.com/privacy',
      termsUrl: 'https://example.com/terms',
    );

    expect(config.supportUri?.scheme, 'mailto');
    expect(config.supportUri?.path, 'support@example.com');
    expect(config.privacyUri, Uri.parse('https://example.com/privacy'));
    expect(config.termsUri, Uri.parse('https://example.com/terms'));
  });
}
