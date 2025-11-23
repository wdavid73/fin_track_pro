# 💰 FinTrack Pro

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

**A comprehensive personal finance management application built with Flutter**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Roadmap](#-roadmap) • [Contributing](#-contributing)

</div>

---

## 📖 About

**FinTrack Pro** is a professional-grade mobile application for personal finance management, designed to demonstrate advanced Flutter development skills and modern software architecture. This project showcases Clean Architecture, comprehensive testing, CI/CD pipelines, and a custom Go backend.

### 🎯 Project Goals

- 🏗️ Demonstrate mastery of Flutter and advanced architectures (Clean Architecture, Feature-First, MVVM)
- ✅ Achieve >80% test coverage with comprehensive testing strategies
- 🚀 Implement complete CI/CD pipelines and DevOps practices
- 🎓 Serve as a portfolio piece for senior/staff engineering positions
- 📱 Deploy to App Store and Google Play with real users

## ✨ Features

### Phase 0 - MVP (Current)
- ✅ Transaction tracking (income/expenses)
- ✅ Customizable categories
- ✅ Current balance and history
- ✅ Basic analytics with charts
- ✅ Clean Architecture implementation

### Phase 1 - Testing & CI/CD
- 🧪 >80% test coverage (unit, widget, integration)
- 🔄 Complete CI/CD with GitHub Actions
- 📦 Automated deployment to Firebase App Distribution
- 🍎 Fastlane for iOS and Android
- 🎨 Golden tests for UI consistency

### Phase 2 - Architecture & Firebase
- 📦 Monorepo with Melos
- 💵 Budget management features
- 🔐 Firebase Auth (Email, Google, Apple Sign-In)
- ☁️ Multi-device sync with Firestore
- 🔔 Smart push notifications
- 🧪 Remote Config and A/B testing

### Phase 3 - Custom Backend
- 🖥️ Go backend with REST API
- ⚡ WebSocket for real-time features
- 🔄 Migration from Firebase to custom backend
- 📊 Advanced analytics with Redis caching
- 📄 PDF/CSV export functionality
- 🐳 Complete DevOps (Docker, Terraform, Monitoring)

### Phase 4 - ML & Launch
- 🤖 Machine Learning: Spending prediction, anomaly detection
- 📸 OCR: Receipt scanning with ML Kit
- 👥 Multi-user: Shared budgets, family accounts
- 🌐 Web Dashboard (Flutter Web)
- 🌍 Internationalization (i18n) and Accessibility (a11y)
- 🚀 App Store and Google Play publication

## 🛠 Tech Stack

### Frontend
- **Framework:** Flutter 3.38+ / Dart 3.10+
- **State Management:** BLoC 8.x, Riverpod
- **Architecture:** Clean Architecture, Feature-First, MVVM
- **Local Database:** Drift (SQLite)
- **Navigation:** go_router
- **Code Generation:** injectable, build_runner
- **Testing:** bloc_test, Mockito, Patrol, Golden tests
- **UI:** Material Design 3, fl_chart

### Backend
- **Language:** Go 1.21+
- **Framework:** Gin (HTTP), Gorilla WebSocket
- **Database:** PostgreSQL (GORM)
- **Caching:** Redis
- **Auth:** JWT

### Cloud & DevOps
- **Firebase:** Auth, Firestore, Cloud Messaging, Remote Config, Crashlytics, Analytics
- **CI/CD:** GitHub Actions, Fastlane
- **Hosting:** Firebase Hosting (web), Cloud Run/Railway (backend)
- **Infrastructure:** Terraform (IaC)
- **Monitoring:** Prometheus, Sentry, Firebase Performance

### ML & Advanced
- **ML Framework:** TensorFlow Lite
- **OCR:** ML Kit Text Recognition
- **Platforms:** Flutter Web, iOS, Android

## 🚀 Getting Started

### Prerequisites

```bash
# Flutter SDK 3.38+
flutter --version

# Dart SDK 3.10+
dart --version

# FVM (recommended)
fvm install 3.38.3
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/wdavid73/fintrack-pro.git
cd fintrack-pro
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📂 Project Structure

```
fintrack-pro/
├── packages/
│   ├── core/
│   │   ├── common/           # Shared utilities
│   │   ├── network/          # API clients
│   │   └── database/         # Local storage
│   ├── design_system/        # UI components
│   ├── features/
│   │   ├── transactions/     # Transaction management
│   │   ├── categories/       # Category management
│   │   ├── analytics/        # Analytics & charts
│   │   └── budgets/          # Budget features
│   └── app/                  # Main application
├── backend/                  # Go backend (Phase 3)
├── .github/workflows/        # CI/CD pipelines
├── docs/                     # Documentation
└── tools/                    # Development tools
```

## 📅 Roadmap

| Phase | Duration | Status |
|-------|----------|--------|
| **Phase 0:** MVP | 14 weekends | 🚧 In Progress |
| **Phase 1:** Testing & CI/CD | 18 weekends | ⏳ Planned |
| **Phase 2:** Firebase & Monorepo | 25 weekends | ⏳ Planned |
| **Phase 3:** Custom Backend | 35 weekends | ⏳ Planned |
| **Phase 4:** ML & Launch | 39 weekends | ⏳ Planned |

**Total Duration:** 32.5 months (~131 weekends)

See [ROADMAP.md](docs/ROADMAP.md) for detailed timeline.

## 📊 Project Metrics

- **Test Coverage:** Target >80%
- **Code Quality:** Following Clean Architecture principles
- **Performance:** <2s cold start time
- **App Size:** Target <2MB

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the code of conduct and the process for submitting pull requests.

## 📝 Development Log

Weekly progress updates are tracked in [docs/WEEKLY_LOG.md](docs/WEEKLY_LOG.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Wilson David Padilla**
- Portfolio: [wdavid73.netlify.app](https://wdavid73.netlify.app/)
- GitHub: [@wdavid73](https://github.com/wdavid73)
- Location: Barranquilla, Colombia

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open source community
- All contributors and supporters

---

<div align="center">

**Built with ❤️ using Flutter**

If you found this project helpful, please consider giving it a ⭐️

</div>
