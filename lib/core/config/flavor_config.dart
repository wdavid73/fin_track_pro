enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String appName;
  final String bundleId;
  final bool enableLogging;
  final bool showDebugBanner;

  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.appName,
    required this.bundleId,
    required this.enableLogging,
    required this.showDebugBanner,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception(
        'FlavorConfig not initialized. Call FlavorConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String bundleId,
    required bool enableLogging,
    required bool showDebugBanner,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      name: flavor.name,
      appName: appName,
      bundleId: bundleId,
      enableLogging: enableLogging,
      showDebugBanner: showDebugBanner,
    );
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;

  @override
  String toString() {
    return 'FlavorConfig(flavor: $name, appName: $appName, bundleId: $bundleId)';
  }
}
