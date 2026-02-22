# 💰 FinTrack Pro

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.32.0+-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Phase](https://img.shields.io/badge/Phase-1%20Testing%20&%20CI/CD%20(5%25)-blue)
[![codecov](https://codecov.io/gh/wdavid73/fintrack-pro/branch/main/graph/badge.svg)](https://codecov.io/gh/wdavid73/fintrack-pro)
![Commits](https://img.shields.io/badge/Commits-15-brightgreen)

**A comprehensive personal finance management application built with Flutter**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Roadmap](#-roadmap) • [Contributing](#-contributing)

</div>

---

## 📖 About

**FinTrack Pro** is a professional-grade mobile application for personal finance management, designed to demonstrate advanced Flutter development skills and modern software architecture. This project showcases Clean Architecture, comprehensive testing, CI/CD pipelines, and a custom Go backend.

> **Current Progress:** Phase 0 MVP (~60% complete) | ~3 weekends invested | 15 commits | 6,022 LOC

### 🎯 Project Goals

- 🏗️ Demonstrate mastery of Flutter and advanced architectures (Clean Architecture, Feature-First, MVVM)
- ✅ Achieve >80% test coverage with comprehensive testing strategies
- 🚀 Implement complete CI/CD pipelines and DevOps practices
- 🎓 Serve as a portfolio piece for senior/staff engineering positions
- 📱 Deploy to App Store and Google Play with real users

### 📊 Quick Stats

| Metric | Current | Target |
|--------|---------|--------|
| Phase | Phase 0 (60%) | Phase 4 Complete |
| Weekends | ~3 | 131 total |
| Test Coverage | 70.5% | >80% |
| LOC | 6,022 | - |
| Features | 3/6 core | All complete |

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
- **Framework:** Flutter 3.24+ / Dart 3.10+
- **State Management:** BLoC (flutter_bloc 9.1.1)
- **Architecture:** Clean Architecture, Feature-First, MVVM
- **Local Database:** Hive 2.2.3 (NoSQL, key-value)
- **Navigation:** go_router 17.0.0
- **Dependency Injection:** get_it 9.1.0 + injectable 2.6.0
- **Code Generation:** injectable_generator, build_runner, hive_generator
- **Testing:** bloc_test 10.0.0, mocktail 1.0.4
- **UI:** Material Design 3, fl_chart 0.69.0, shimmer 3.0.0
- **Forms:** formz 0.8.0

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

2. **Run project setup** (installs dependencies, configures git hooks, runs code generation)
```bash
./setup.sh
```

3. **Run the app**
```bash
flutter run
```

### Running Tests

```bash
# Run all tests
fvm flutter test

# Run tests with coverage (recommended)
./coverage.sh

# View coverage report
open coverage/html/index.html
```

📖 **For detailed testing documentation, see [TESTING.md](TESTING.md)**

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

- **Test Coverage:** 70.5% (Target: >80%) 📈
  - Models: 100% ✅
  - Datasources: 100% ✅
  - Use Cases: 100% ✅
  - BLoCs: 100% ✅
  - Core Widgets: 100% ✅
- **Code Quality:** Following Clean Architecture principles ✅
- **Commits:** 15 with conventional commits (gitmoji)
- **Performance:** <2s cold start time (TBD)
- **App Size:** Target <2MB (TBD)
- **CI/CD:** GitHub Actions configured ✅

**Detailed Metrics:** See [docs/METRICS.md](docs/METRICS.md) for comprehensive dashboard

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
