# Packages Reference

## State Management & Architecture

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `flutter_riverpod` | State management | Providers, StateNotifiers, ConsumerWidget |
| `riverpod_annotation` | Code generation for providers | `@riverpod` annotation (optional, prefer manual) |
| `dartz` | Functional programming | `Either<Failure, T>`, `Left`, `Right` |

## Navigation

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `go_router` | Declarative routing | Named routes, nested navigation, route guards |

## Networking

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `dio` | HTTP client | Interceptors, TLS cert pinning, base options |

## Forms & Validation

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `formz` | Form input validation | `FormzInput<Value, Error>` subclasses |

## Assets & Media

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `flutter_gen` | Asset code generation | Type-safe asset references (`Assets.images.logo`) |
| `flutter_svg` | SVG rendering | `SvgPicture.asset()` / `.network()` |
| `cached_network_image` | Image caching | `CachedNetworkImage(imageUrl: ...)` |
| `lottie` | Lottie animations | `Lottie.asset()`, cache compositions with `AssetLottie` |

## Loading States

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `skeletonizer` | Skeleton loading UI | Wrap widgets in `Skeletonizer(enabled: isLoading)` |

## Storage

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `flutter_secure_storage` | Encrypted key-value | Tokens, sensitive credentials |
| `shared_preferences` | Simple key-value | User preferences, flags, non-sensitive cache |

## Utilities

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `url_launcher` | Open URLs/deep links | `launchUrl(Uri.parse(...))` |
| `permission_handler` | Runtime permissions | `Permission.camera.request()` |
| `package_info_plus` | App version info | `PackageInfo.fromPlatform()` |

## Testing

| Package | Purpose | Usage Pattern |
|---------|---------|---------------|
| `flutter_test` | Widget & unit tests | `testWidgets`, `WidgetTester` |
| `mockito` | Mocking | `@GenerateMocks([...])`, `when(...).thenAnswer(...)` |
| `build_runner` | Code generation | `dart run build_runner build` for mockito mocks |

## CI/CD & Tooling

| Tool | Purpose |
|------|---------|
| FVM | Flutter version management per project |
| GitHub Actions | CI pipelines (lint, test, build) |
| Fastlane | iOS deployment automation, provisioning profiles |
| lcov / Coverage Gutters | Code coverage visualization in VS Code |

## Dio Client Setup Pattern

```dart
class AppDioClient {
  static Dio create({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```
