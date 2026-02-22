# FinTrack Pro — Release Checklist

Use this checklist before publishing any release to stores. Automated checks cover most items, but manual verification is the last line of defense.

---

## Automated Checks (CI/CD)

These run automatically on PRs to `main` and `release/*`:

- [ ] Config validation passes (`make validate`)
- [ ] `flutter analyze` passes
- [ ] All tests pass (`flutter test`)
- [ ] APK prod build succeeds
- [ ] No hardcoded API keys in `lib/`
- [ ] No `.env` files committed to repository

---

## Configuration

### iOS

- [ ] `prod.xcscheme` ArchiveAction uses `Release-prod` configuration
- [ ] `PRODUCT_NAME` is "FinTrack Pro" for `Release-prod`
- [ ] `PRODUCT_BUNDLE_IDENTIFIER` is `com.fintrackpro` for `Release-prod`
- [ ] `Info.plist` CFBundleDisplayName uses `$(PRODUCT_NAME)` (not hardcoded)
- [ ] Signing certificates and provisioning profiles are valid and not expired
- [ ] Correct team selected in Xcode signing settings

### Android

- [ ] `applicationId` is `com.fintrackpro` (no suffix for prod)
- [ ] `resValue` app_name is "FinTrack Pro" for prod flavor
- [ ] Release signing keystore is configured (not using debug keystore)
- [ ] ProGuard/R8 rules are configured if obfuscation is enabled

---

## Environment

- [ ] `.env.prod` has correct `API_BASE_URL` pointing to production API
- [ ] `.env.prod` has `ENABLE_LOGGING=false`
- [ ] `.env.prod` has `ENABLE_DEBUG_BANNER=false`
- [ ] `.env.prod` has `ENVIRONMENT=production`
- [ ] All required variables are present (no empty or placeholder values)

---

## Version

- [ ] `version` in `pubspec.yaml` has been incremented
- [ ] Version follows semver format (e.g., `1.0.0`, `1.1.0+2`)
- [ ] `versionCode` incremented for Android (if using build number)
- [ ] Changelog updated with release notes

---

## Functionality

- [ ] Test all critical user flows on a **prod build** (not debug)
- [ ] Verify no debug banners or dev indicators visible
- [ ] Test on at least one iOS physical device
- [ ] Test on at least one Android physical device
- [ ] Verify app name displays correctly ("FinTrack Pro")
- [ ] Verify app icon is correct

---

## Store Submission

- [ ] Screenshots updated if UI changed
- [ ] Store listing description reviewed
- [ ] Privacy policy URL is valid
- [ ] App category is correct
- [ ] Content rating questionnaire completed
- [ ] Target audience and content settings reviewed

---

## Post-Release

- [ ] Monitor crash reports (Crashlytics / Sentry)
- [ ] Verify production API connectivity
- [ ] Tag release in git (`git tag v1.x.x`)
- [ ] Notify team / stakeholders of release

---

_Last updated: February 2026_
