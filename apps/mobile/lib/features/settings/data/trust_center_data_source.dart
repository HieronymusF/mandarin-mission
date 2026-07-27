import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final class AppBuildInfo {
  const AppBuildInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;
}

abstract interface class TrustCenterDataSource {
  Future<AppBuildInfo> loadBuildInfo();

  Future<bool> openExternalUri(Uri uri);
}

final class PlatformTrustCenterDataSource implements TrustCenterDataSource {
  @override
  Future<AppBuildInfo> loadBuildInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppBuildInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  @override
  Future<bool> openExternalUri(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final class TrustCenterConfig {
  const TrustCenterConfig({
    this.supportEmail = '',
    this.supportUrl = '',
    this.privacyUrl = '',
    this.termsUrl = '',
  });

  factory TrustCenterConfig.fromEnvironment() {
    return const TrustCenterConfig(
      supportEmail: String.fromEnvironment('MM_SUPPORT_EMAIL'),
      supportUrl: String.fromEnvironment('MM_SUPPORT_URL'),
      privacyUrl: String.fromEnvironment('MM_PRIVACY_URL'),
      termsUrl: String.fromEnvironment('MM_TERMS_URL'),
    );
  }

  final String supportEmail;
  final String supportUrl;
  final String privacyUrl;
  final String termsUrl;

  Uri? get supportUri {
    final webpage = _validatedHttpsUri(supportUrl);
    if (webpage != null) return webpage;

    final email = supportEmail.trim();
    if (!_isValidEmail(email)) return null;
    return Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const {'subject': 'Mandarin Mission support'},
    );
  }

  Uri? get privacyUri => _validatedHttpsUri(privacyUrl);
  Uri? get termsUri => _validatedHttpsUri(termsUrl);
}

Uri? _validatedHttpsUri(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  return uri;
}

bool _isValidEmail(String value) {
  final at = value.indexOf('@');
  return at > 0 &&
      at == value.lastIndexOf('@') &&
      at < value.length - 1 &&
      !value.contains(RegExp(r'\s'));
}
