// ignore_for_file: avoid_print

import 'dart:io';

import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

// ============================================================================
// Source of Truth — Expected configuration per flavor
// ============================================================================

const Map<String, Map<String, String>> expectedConfig = {
  'dev': {
    'appName': 'FinTrack Pro DEV',
    'bundleId': 'com.fintrackpro.dev',
    'androidAppIdSuffix': '.dev',
    'environment': 'development',
  },
  'staging': {
    'appName': 'FinTrack Pro STG',
    'bundleId': 'com.fintrackpro.staging',
    'androidAppIdSuffix': '.staging',
    'environment': 'staging',
  },
  'prod': {
    'appName': 'FinTrack Pro',
    'bundleId': 'com.fintrackpro',
    'androidAppIdSuffix': '',
    'environment': 'production',
  },
};

const String androidBaseAppId = 'com.fintrackpro';

const List<String> requiredEnvVars = [
  'APP_NAME',
  'APP_SUFFIX',
  'BUNDLE_ID',
  'API_BASE_URL',
  'API_TIMEOUT',
  'ENABLE_LOGGING',
  'ENABLE_DEBUG_BANNER',
  'ENVIRONMENT',
];

const List<String> flavors = ['dev', 'staging', 'prod'];

// ============================================================================
// Validation Result Tracking
// ============================================================================

enum ResultType { pass, fail, warning }

class ValidationResult {
  final ResultType type;
  final String category;
  final String message;

  ValidationResult(this.type, this.category, this.message);

  bool get isFail => type == ResultType.fail;
  bool get isWarning => type == ResultType.warning;
}

final List<ValidationResult> results = [];

void pass(String category, String message) {
  results.add(ValidationResult(ResultType.pass, category, message));
  print('  ✅ $message');
}

void fail(String category, String message) {
  results.add(ValidationResult(ResultType.fail, category, message));
  print('  ❌ $message');
}

void warn(String category, String message) {
  results.add(ValidationResult(ResultType.warning, category, message));
  print('  ⚠️  $message');
}

// ============================================================================
// Main
// ============================================================================

void main() {
  print('');
  print('═══════════════════════════════════════════════════════');
  print('  FinTrack Pro — Pre-Release Configuration Validator');
  print('═══════════════════════════════════════════════════════');
  print('');

  validateIosPbxproj();
  validateInfoPlist();
  validateIosSchemes();
  validateAndroidBuildGradle();
  validateEnvFiles();
  validateDartEntryPoints();
  validatePubspec();
  validateSecurity();

  printSummary();

  final hasFailures = results.any((r) => r.isFail);
  exit(hasFailures ? 1 : 0);
}

// ============================================================================
// iOS — project.pbxproj parsing helper
// ============================================================================

/// Parses XCBuildConfiguration blocks from project.pbxproj for the Runner
/// target (identified by INFOPLIST_FILE = Runner/Info.plist).
/// Returns a map of configName -> {key: value} for build settings.
Map<String, Map<String, String>> _parsePbxprojRunnerConfigs(String content) {
  final configs = <String, Map<String, String>>{};
  final lines = content.split('\n');

  var inBuildConfig = false;
  var inBuildSettings = false;
  var braceDepth = 0;
  var currentSettings = <String, String>{};
  String? currentName;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.contains('isa = XCBuildConfiguration;')) {
      inBuildConfig = true;
      currentSettings = {};
      currentName = null;
      continue;
    }

    if (inBuildConfig) {
      if (line == 'buildSettings = {') {
        inBuildSettings = true;
        braceDepth = 1;
        continue;
      }

      if (inBuildSettings) {
        if (line.contains('{')) braceDepth++;
        if (line.contains('}')) braceDepth--;

        if (braceDepth <= 0) {
          inBuildSettings = false;
          continue;
        }

        // Extract key = value pairs (simple single-line ones)
        final kvMatch = RegExp(r'(\w+)\s*=\s*(.+);$').firstMatch(line);
        if (kvMatch != null) {
          final key = kvMatch.group(1)!;
          var value = kvMatch.group(2)!.trim();
          // Remove surrounding quotes
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
          currentSettings[key] = value;
        }
      }

      // Match name = "ConfigName"; at the end of the block
      final nameMatch = RegExp(r'name = "(.+)";').firstMatch(line);
      if (nameMatch != null) {
        currentName = nameMatch.group(1)!;

        // Only keep Runner target configs (have INFOPLIST_FILE for Runner)
        if (currentSettings.containsKey('INFOPLIST_FILE') &&
            currentSettings['INFOPLIST_FILE'] == 'Runner/Info.plist') {
          configs[currentName] = Map.from(currentSettings);
        }

        inBuildConfig = false;
        currentSettings = {};
      }
    }
  }

  return configs;
}

// ============================================================================
// iOS — project.pbxproj
// ============================================================================

void validateIosPbxproj() {
  print('📱 iOS Build Configurations (project.pbxproj)');
  print('───────────────────────────────────────────────');

  final file = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!file.existsSync()) {
    fail('iOS', 'project.pbxproj not found');
    print('');
    return;
  }

  final content = file.readAsStringSync();

  // Parse XCBuildConfiguration blocks for Runner target (not RunnerTests)
  // Uses line-by-line approach to handle nested structures in pbxproj
  final configBlocks = _parsePbxprojRunnerConfigs(content);

  for (final flavor in flavors) {
    final expected = expectedConfig[flavor]!;

    for (final buildType in ['Debug', 'Release']) {
      final configName = '$buildType-$flavor';

      // Check that the configuration exists
      if (!content.contains('name = "$configName"')) {
        fail('iOS', 'Build Configuration "$configName" not found');
        continue;
      }

      final block = configBlocks[configName];
      if (block == null) {
        fail('iOS', '[$configName] Could not parse Runner build settings');
        continue;
      }

      final actualBundleId = block['PRODUCT_BUNDLE_IDENTIFIER'] ?? '';
      final actualProductName = block['PRODUCT_NAME'] ?? '';

      // Validate PRODUCT_BUNDLE_IDENTIFIER
      if (actualBundleId == expected['bundleId']) {
        pass('iOS', '[$configName] PRODUCT_BUNDLE_IDENTIFIER = $actualBundleId');
      } else {
        fail(
          'iOS',
          '[$configName] PRODUCT_BUNDLE_IDENTIFIER: '
              'expected "${expected['bundleId']}", got "$actualBundleId"',
        );
      }

      // Validate PRODUCT_NAME
      if (actualProductName == expected['appName']) {
        pass('iOS', '[$configName] PRODUCT_NAME = "$actualProductName"');
      } else {
        fail(
          'iOS',
          '[$configName] PRODUCT_NAME: '
              'expected "${expected['appName']}", got "$actualProductName"',
        );
      }
    }
  }
  print('');
}

// ============================================================================
// iOS — Info.plist
// ============================================================================

void validateInfoPlist() {
  print('📋 iOS Info.plist');
  print('───────────────────────────────────────────────');

  final file = File('ios/Runner/Info.plist');
  if (!file.existsSync()) {
    fail('Info.plist', 'Info.plist not found');
    print('');
    return;
  }

  final content = file.readAsStringSync();
  final document = XmlDocument.parse(content);
  final dict = document.findAllElements('dict').first;
  final children = dict.children
      .whereType<XmlElement>()
      .toList();

  final plistMap = <String, String>{};
  for (var i = 0; i < children.length - 1; i++) {
    if (children[i].localName == 'key') {
      final key = children[i].innerText;
      final value = children[i + 1].innerText;
      plistMap[key] = value;
    }
  }

  // CFBundleDisplayName should use $(PRODUCT_NAME) variable
  final displayName = plistMap['CFBundleDisplayName'] ?? '';
  if (displayName == r'$(PRODUCT_NAME)') {
    pass('Info.plist', 'CFBundleDisplayName uses \$(PRODUCT_NAME) variable');
  } else {
    fail(
      'Info.plist',
      'CFBundleDisplayName should be \$(PRODUCT_NAME), '
          'got "$displayName" (hardcoded names cause flavor issues)',
    );
  }

  // CFBundleIdentifier should use $(PRODUCT_BUNDLE_IDENTIFIER)
  final bundleId = plistMap['CFBundleIdentifier'] ?? '';
  if (bundleId == r'$(PRODUCT_BUNDLE_IDENTIFIER)') {
    pass(
      'Info.plist',
      'CFBundleIdentifier uses \$(PRODUCT_BUNDLE_IDENTIFIER) variable',
    );
  } else {
    fail(
      'Info.plist',
      'CFBundleIdentifier should be \$(PRODUCT_BUNDLE_IDENTIFIER), '
          'got "$bundleId"',
    );
  }

  print('');
}

// ============================================================================
// iOS — Xcode Schemes
// ============================================================================

void validateIosSchemes() {
  print('🔧 iOS Xcode Schemes');
  print('───────────────────────────────────────────────');

  for (final flavor in flavors) {
    final schemeFile = File(
      'ios/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme',
    );

    if (!schemeFile.existsSync()) {
      fail('Schemes', '$flavor.xcscheme not found');
      continue;
    }

    pass('Schemes', '$flavor.xcscheme exists');

    // Parse scheme and check ArchiveAction buildConfiguration
    final content = schemeFile.readAsStringSync();
    final document = XmlDocument.parse(content);

    final archiveAction = document.findAllElements('ArchiveAction');
    if (archiveAction.isEmpty) {
      warn('Schemes', '[$flavor] No ArchiveAction found in scheme');
      continue;
    }

    final archiveConfig =
        archiveAction.first.getAttribute('buildConfiguration') ?? '';
    final expectedConfig = 'Release-$flavor';

    if (archiveConfig == expectedConfig) {
      pass('Schemes', '[$flavor] ArchiveAction uses $expectedConfig');
    } else {
      fail(
        'Schemes',
        '[$flavor] ArchiveAction buildConfiguration: '
            'expected "$expectedConfig", got "$archiveConfig"',
      );
    }
  }
  print('');
}

// ============================================================================
// Android — build.gradle.kts
// ============================================================================

void validateAndroidBuildGradle() {
  print('🤖 Android Build Configuration (build.gradle.kts)');
  print('───────────────────────────────────────────────');

  final file = File('android/app/build.gradle.kts');
  if (!file.existsSync()) {
    fail('Android', 'build.gradle.kts not found');
    print('');
    return;
  }

  final content = file.readAsStringSync();

  // Validate base applicationId
  final appIdRegex = RegExp(r'applicationId\s*=\s*"([^"]+)"');
  final appIdMatch = appIdRegex.firstMatch(content);

  if (appIdMatch != null) {
    final actualAppId = appIdMatch.group(1)!;
    if (actualAppId == androidBaseAppId) {
      pass('Android', 'applicationId = "$actualAppId"');
    } else {
      fail(
        'Android',
        'applicationId: expected "$androidBaseAppId", got "$actualAppId"',
      );
    }
  } else {
    fail('Android', 'applicationId not found in build.gradle.kts');
  }

  // Validate each flavor
  for (final flavor in flavors) {
    final expected = expectedConfig[flavor]!;

    // Check flavor block exists
    final flavorBlockRegex = RegExp(
      r'create\("' + RegExp.escape(flavor) + r'"\)\s*\{([^}]+)\}',
      dotAll: true,
    );
    final flavorMatch = flavorBlockRegex.firstMatch(content);

    if (flavorMatch == null) {
      fail('Android', 'Product flavor "$flavor" not found');
      continue;
    }

    final flavorBlock = flavorMatch.group(1)!;

    // Validate applicationIdSuffix
    final suffixRegex = RegExp(r'applicationIdSuffix\s*=\s*"([^"]*)"');
    final suffixMatch = suffixRegex.firstMatch(flavorBlock);
    final expectedSuffix = expected['androidAppIdSuffix']!;

    if (expectedSuffix.isEmpty) {
      // prod should NOT have applicationIdSuffix
      if (suffixMatch == null) {
        pass('Android', '[$flavor] No applicationIdSuffix (correct for prod)');
      } else {
        fail(
          'Android',
          '[$flavor] Should not have applicationIdSuffix, '
              'but found "${suffixMatch.group(1)}"',
        );
      }
    } else {
      if (suffixMatch != null && suffixMatch.group(1) == expectedSuffix) {
        pass('Android', '[$flavor] applicationIdSuffix = "$expectedSuffix"');
      } else {
        fail(
          'Android',
          '[$flavor] applicationIdSuffix: expected "$expectedSuffix", '
              'got "${suffixMatch?.group(1) ?? 'not found'}"',
        );
      }
    }

    // Validate resValue app_name
    final resValueRegex = RegExp(
      r'resValue\(\s*"string"\s*,\s*"app_name"\s*,\s*"([^"]+)"\s*\)',
    );
    final resValueMatch = resValueRegex.firstMatch(flavorBlock);

    if (resValueMatch != null) {
      final actualAppName = resValueMatch.group(1)!;
      if (actualAppName == expected['appName']) {
        pass('Android', '[$flavor] app_name = "$actualAppName"');
      } else {
        fail(
          'Android',
          '[$flavor] app_name: expected "${expected['appName']}", '
              'got "$actualAppName"',
        );
      }
    } else {
      fail('Android', '[$flavor] resValue for app_name not found');
    }
  }
  print('');
}

// ============================================================================
// Environment Files
// ============================================================================

void validateEnvFiles() {
  print('🌍 Environment Files');
  print('───────────────────────────────────────────────');

  for (final flavor in flavors) {
    final envFile = File('.env.$flavor');
    final expected = expectedConfig[flavor]!;

    if (!envFile.existsSync()) {
      warn(
        'Env',
        '.env.$flavor not found (expected — files are gitignored)',
      );
      continue;
    }

    pass('Env', '.env.$flavor exists');

    // Parse env file
    final envMap = <String, String>{};
    for (final line in envFile.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex == -1) continue;
      final key = trimmed.substring(0, eqIndex).trim();
      final value = trimmed.substring(eqIndex + 1).trim();
      envMap[key] = value;
    }

    // Check required variables
    for (final requiredVar in requiredEnvVars) {
      if (envMap.containsKey(requiredVar)) {
        pass('Env', '[$flavor] $requiredVar is defined');
      } else {
        fail('Env', '[$flavor] Missing required variable: $requiredVar');
      }
    }

    // Validate key values match expected config
    if (envMap['APP_NAME'] != null &&
        envMap['APP_NAME'] != expected['appName']) {
      fail(
        'Env',
        '[$flavor] APP_NAME: expected "${expected['appName']}", '
            'got "${envMap['APP_NAME']}"',
      );
    }

    if (envMap['BUNDLE_ID'] != null &&
        envMap['BUNDLE_ID'] != expected['bundleId']) {
      fail(
        'Env',
        '[$flavor] BUNDLE_ID: expected "${expected['bundleId']}", '
            'got "${envMap['BUNDLE_ID']}"',
      );
    }

    if (envMap['ENVIRONMENT'] != null &&
        envMap['ENVIRONMENT'] != expected['environment']) {
      fail(
        'Env',
        '[$flavor] ENVIRONMENT: expected "${expected['environment']}", '
            'got "${envMap['ENVIRONMENT']}"',
      );
    }

    // Check for placeholder values
    final placeholders = ['YOUR_API_KEY', 'CHANGE_ME', 'TODO', 'FIXME'];
    for (final entry in envMap.entries) {
      for (final placeholder in placeholders) {
        if (entry.value.toUpperCase().contains(placeholder)) {
          fail(
            'Env',
            '[$flavor] ${entry.key} contains placeholder value: '
                '"${entry.value}"',
          );
        }
      }
    }
  }
  print('');
}

// ============================================================================
// Dart Entry Points
// ============================================================================

void validateDartEntryPoints() {
  print('🎯 Dart Entry Points');
  print('───────────────────────────────────────────────');

  for (final flavor in flavors) {
    final entryFile = File('lib/flavors/main_$flavor.dart');
    if (entryFile.existsSync()) {
      pass('Dart', 'lib/flavors/main_$flavor.dart exists');
    } else {
      fail('Dart', 'lib/flavors/main_$flavor.dart not found');
    }
  }
  print('');
}

// ============================================================================
// pubspec.yaml
// ============================================================================

void validatePubspec() {
  print('📦 pubspec.yaml');
  print('───────────────────────────────────────────────');

  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    fail('Pubspec', 'pubspec.yaml not found');
    print('');
    return;
  }

  final content = file.readAsStringSync();
  final yaml = loadYaml(content) as YamlMap;

  // Validate version follows semver
  final version = yaml['version']?.toString() ?? '';
  final semverRegex = RegExp(r'^\d+\.\d+\.\d+([+-].+)?$');
  if (semverRegex.hasMatch(version)) {
    pass('Pubspec', 'Version "$version" follows semver');
  } else {
    fail('Pubspec', 'Version "$version" does not follow semver format');
  }

  // Validate env assets are declared
  final flutter = yaml['flutter'] as YamlMap?;
  final assets = flutter?['assets'] as YamlList?;
  final assetList = assets?.map((e) => e.toString()).toList() ?? [];

  for (final flavor in flavors) {
    final envAsset = '.env.$flavor';
    if (assetList.contains(envAsset)) {
      pass('Pubspec', 'Asset "$envAsset" declared');
    } else {
      fail('Pubspec', 'Asset "$envAsset" not declared in flutter.assets');
    }
  }

  // Check for local path dependencies
  final dependencies = yaml['dependencies'] as YamlMap?;
  final devDependencies = yaml['dev_dependencies'] as YamlMap?;

  bool hasLocalPaths = false;
  for (final deps in [dependencies, devDependencies]) {
    if (deps == null) continue;
    for (final entry in deps.entries) {
      if (entry.value is YamlMap) {
        final map = entry.value as YamlMap;
        if (map.containsKey('path')) {
          fail(
            'Pubspec',
            'Dependency "${entry.key}" uses local path: "${map['path']}" '
                '(not suitable for production)',
          );
          hasLocalPaths = true;
        }
      }
    }
  }
  if (!hasLocalPaths) {
    pass('Pubspec', 'No local path dependencies found');
  }

  print('');
}

// ============================================================================
// Security Checks
// ============================================================================

void validateSecurity() {
  print('🔒 Security Checks');
  print('───────────────────────────────────────────────');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    fail('Security', 'lib/ directory not found');
    print('');
    return;
  }

  // API key patterns to search for
  final apiKeyPatterns = [
    RegExp(r'AIza[0-9A-Za-z_-]{35}'), // Google API key
    RegExp(r'sk-[a-zA-Z0-9]{20,}'), // OpenAI / Stripe secret key
    RegExp(r'AKIA[0-9A-Z]{16}'), // AWS Access Key
    RegExp(r'ghp_[a-zA-Z0-9]{36}'), // GitHub personal access token
    RegExp(r'glpat-[a-zA-Z0-9\-_]{20,}'), // GitLab personal access token
  ];

  final placeholderPatterns = [
    RegExp(r'YOUR_API_KEY', caseSensitive: false),
    RegExp(r'CHANGE_ME', caseSensitive: false),
    RegExp(r'INSERT_.*_HERE', caseSensitive: false),
  ];

  bool foundSecurityIssue = false;

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final dartFile in dartFiles) {
    final content = dartFile.readAsStringSync();
    final relativePath = dartFile.path;

    for (final pattern in apiKeyPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        fail(
          'Security',
          'Possible hardcoded API key in $relativePath: '
              '"${match.group(0)!.substring(0, 8)}..."',
        );
        foundSecurityIssue = true;
      }
    }

    for (final pattern in placeholderPatterns) {
      if (pattern.hasMatch(content)) {
        warn('Security', 'Placeholder value found in $relativePath');
        foundSecurityIssue = true;
      }
    }
  }

  if (!foundSecurityIssue) {
    pass('Security', 'No hardcoded API keys or placeholders found in lib/');
  }

  print('');
}

// ============================================================================
// Summary
// ============================================================================

void printSummary() {
  final passed = results.where((r) => r.type == ResultType.pass).length;
  final failed = results.where((r) => r.type == ResultType.fail).length;
  final warnings = results.where((r) => r.type == ResultType.warning).length;

  print('═══════════════════════════════════════════════════════');
  print('  Summary');
  print('═══════════════════════════════════════════════════════');
  print('');
  print('  ✅ Passed:   $passed');
  print('  ❌ Failed:   $failed');
  print('  ⚠️  Warnings: $warnings');
  print('');

  if (failed > 0) {
    print('  ❌ VALIDATION FAILED — Fix the errors above before releasing.');
    print('');
    print('  Failed checks:');
    for (final r in results.where((r) => r.isFail)) {
      print('    - [${r.category}] ${r.message}');
    }
  } else {
    print('  ✅ ALL CHECKS PASSED — Configuration is valid.');
  }

  print('');
  print('═══════════════════════════════════════════════════════');
  print('');
}
