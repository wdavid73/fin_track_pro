# FinTrack Pro - Project Context & Strategy

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Project Vision](#project-vision)
- [Developer Profile](#developer-profile)
- [Technical Strategy](#technical-strategy)
- [Project Phases](#project-phases)
- [Learning Objectives](#learning-objectives)
- [Success Metrics](#success-metrics)
- [Project Philosophy](#project-philosophy)
- [Risk Management](#risk-management)
- [Career Impact](#career-impact)

---

## Executive Summary

**FinTrack Pro** is a comprehensive mobile personal finance management application built with Flutter, designed as a professional portfolio project to demonstrate advanced mobile development skills and software architecture expertise. The project evolves through 4 phases over 32 months (131 weekends), starting with a basic MVP and culminating in a production-ready application published on App Store and Google Play.

### Key Facts

- **Duration:** 32.5 months (~2.5 years)
- **Time Commitment:** 8 hours/weekend (Saturday 4h + Sunday 4h)
- **Total Investment:** ~1,040 hours
- **Phases:** 4 progressive phases (Phase 0-3 + optional advanced Phase 4)
- **Target Audience:** Recruiters, hiring managers, and potential employers
- **Primary Goal:** Career advancement to senior/staff positions with 3-5x salary increase

---

## Project Vision

### What is FinTrack Pro?

FinTrack Pro is more than a simple finance tracker. It's a comprehensive platform that will demonstrate:

1. **Architectural Excellence**: Clean Architecture, Feature-First structure, MVVM patterns
2. **Production Quality**: ≥75% test coverage (filtered), complete CI/CD, monitoring, and observability
3. **Full-Stack Capabilities**: Custom Go backend, real-time features, cloud infrastructure
4. **Modern Technologies**: Machine learning, OCR, multi-platform support
5. **Professional Standards**: Documentation, testing, DevOps, and deployment

### Why This Project?

**Career Acceleration:**
- Create a standout portfolio piece that differentiates from typical demo apps
- Demonstrate capabilities beyond current job requirements
- Show commitment to professional growth and learning
- Provide concrete examples for technical interviews

**Skill Development:**
- Master advanced Flutter patterns and architectures
- Learn backend development with Go
- Implement ML features and computer vision
- Build complete DevOps and infrastructure skills
- Practice technical writing and content creation

**Real-World Impact:**
- Build something that could genuinely help people manage their finances
- Create a product worthy of App Store publication
- Potentially generate passive income or opportunities

---

## Developer Profile

### Current State

**Name:** Wilson David Padilla  
**Location:** Barranquilla, Colombia  
**Experience:** ~4 years as Flutter Developer

**Current Skills:**
- Flutter & Dart (intermediate to advanced)
- BLoC pattern (solid understanding)
- Riverpod state management
- Clean Architecture implementation
- Feature-First structure
- MVVM pattern
- Unit, Widget, and Integration testing
- Firebase services (Auth, Firestore, Cloud Messaging)
- CI/CD with GitHub Actions (basic to intermediate)

**Skills to Acquire:**
- Advanced BLoC patterns (complex state scenarios)
- Monorepo architecture with Melos
- Go backend development
- WebSocket real-time communication
- PostgreSQL and Redis
- Machine Learning with TensorFlow Lite
- OCR with ML Kit
- Infrastructure as Code (Terraform)
- Advanced DevOps (Docker, Kubernetes basics)
- Production monitoring and observability

### Availability & Constraints

**Time Commitment:**
- **Weekdays:** Not available (full-time job)
- **Saturdays:** 4 hours
- **Sundays:** 4 hours
- **Total:** 8 hours per weekend

**Constraints:**
- Limited time requires focused, well-planned work sessions
- Need clear task breakdown to maximize productivity
- Must balance with personal life and rest
- Potential for interruptions (family, emergencies, burnout)

**Advantages:**
- Consistent schedule reduces context switching
- Weekend work allows uninterrupted focus
- Long timeline permits deep learning
- Pressure-free environment for quality work

---

## Technical Strategy

### Architecture Approach

**Clean Architecture Layers:**

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (UI, BLoC, ViewModels, Pages)   │
├─────────────────────────────────────┤
│          Domain Layer               │
│   (Entities, Use Cases, Contracts)  │
├─────────────────────────────────────┤
│           Data Layer                │
│  (Repositories, Data Sources, DTOs) │
└─────────────────────────────────────┘
```

**Feature-First Structure:**
```
features/
├── transactions/
│   ├── domain/
│   ├── data/
│   └── presentation/
├── categories/
│   ├── domain/
│   ├── data/
│   └── presentation/
└── analytics/
    ├── domain/
    ├── data/
    └── presentation/
```

### Technology Decisions

**Why Flutter?**
- Cross-platform (iOS, Android, Web) from single codebase
- Strong performance and native feel
- Excellent developer experience
- Large ecosystem and community
- Hot reload for rapid iteration

**Why BLoC?**
- Predictable state management
- Excellent for complex business logic
- Great testing story
- Separates presentation from business logic
- Industry standard for enterprise Flutter apps

**Why Clean Architecture?**
- Testability (can test business logic independently)
- Maintainability (clear separation of concerns)
- Scalability (easy to add features)
- Platform independence (business logic independent of Flutter)
- Industry best practice

**Why Go for Backend?**
- High performance and efficiency
- Excellent concurrency support
- Simple deployment (single binary)
- Growing industry adoption
- Strong typing and compile-time checks
- Great for learning backend development

**Why Hive instead of Drift?**

*Decision Made:* Weekend 1 (Nov 2025)

During Phase 0 implementation, a strategic decision was made to use **Hive** instead of the originally planned **Drift** for local persistence. This decision was based on both technical and practical considerations:

**Comparison Table:**

| Aspect | Hive | Drift |
|--------|------|-------|
| **Type** | NoSQL (key-value) | SQL (relational) |
| **Setup Complexity** | Simple | Moderate |
| **Learning Curve** | Low | Medium |
| **Performance** | Excellent (in-memory) | Very Good |
| **Type Safety** | Good (with adapters) | Excellent (compile-time) |
| **Queries** | Key-based, filtering | Complex SQL queries |
| **Code Generation** | Minimal | Required for tables |
| **Migration** | Simple | Requires planning |
| **Best For** | Simple data models | Complex relationships |
| **Developer Experience** | Fast iteration | More structured |

**Technical Rationale:**
- **MVP Speed:** Hive allows faster iteration for Phase 0 MVP with simpler setup
- **Data Model Fit:** FinTrack Pro's data model (transactions, categories, budgets) works well with key-value storage
- **Performance:** Hive's in-memory caching provides excellent read performance for frequent queries
- **Code Generation:** Less boilerplate compared to Drift's table definitions
- **Flexibility:** Easy to add/modify fields without complex migrations

**Personal Context:**
This was also a personal decision - I had previously worked with Hive in other projects and felt more comfortable with its API and patterns. This familiarity allowed me to focus on implementing Clean Architecture and business logic rather than learning a new database abstraction during the critical MVP phase.

**Future Considerations:**
- Hive is suitable for Phase 0-2
- May revisit for Phase 3 when implementing custom Go backend
- If complex queries become necessary, migration to Drift or direct SQL is possible
- The Clean Architecture's repository pattern makes this transition straightforward

**Decision Status:** ✅ Validated - Working well for MVP needs

### Testing Strategy

**Test Pyramid:**
```
        ╱╲
       ╱E2E╲        10% - Integration tests (Patrol)
      ╱──────╲
     ╱ Widget ╲     30% - Widget tests
    ╱──────────╲
   ╱    Unit    ╲   60% - Unit tests (business logic)
  ╱──────────────╲
```

**Coverage Goals:**
- Overall: ≥75% (filtered, excluding generated code)
- Business Logic: ≥85%
- Presentation: ≥65%
- Data Layer: ≥80%

> **Nota sobre el 80%:** El techo del ~79% refleja código legítimamente difícil de testear
> (widgets con `getIt` directo, archivos `part of` BLoC, DI containers, Hive wrappers).
> El gate de CI está en ≥60% para proteger regresiones; el target real de calidad es ≥75%.

---

## Project Phases

### Phase 0: MVP Foundation (Weekends 1-14)

**Duration:** 14 weekends (112 hours)  
**Goal:** Build functional MVP with Clean Architecture

**Key Deliverables:**
- Transaction management (create, read, update, delete)
- Category system with icons
- Balance tracking
- Basic analytics with charts
- Clean Architecture setup
- Local persistence with Hive *(changed from Drift - see Technical Strategy)*
- Material Design 3 UI

**Learning Focus:**
- Clean Architecture implementation
- BLoC pattern mastery
- Hive database *(local key-value storage)*
- fl_chart for visualizations

**Demo Video:** 3-minute MVP showcase

---

### Phase 1: Testing & CI/CD (Weekends 15-32)

**Duration:** 18 weekends (144 hours)  
**Goal:** Achieve production-quality testing and automation

**Key Deliverables:**
- Unit test suite (>60% coverage)
- Widget test suite (>20% coverage)
- Integration tests with Patrol (>10% coverage)
- Golden tests for UI consistency
- GitHub Actions CI/CD pipeline
- Automated deployment to Firebase App Distribution
- Fastlane configuration for iOS and Android
- Code quality checks (linting, formatting)

**Learning Focus:**
- Advanced testing patterns
- Mocking and test doubles
- CI/CD pipeline configuration
- Fastlane automation
- GitHub Actions workflows

**Content Creation:**
- Article: "Building a Complete CI/CD Pipeline for Flutter"
- Video: "Testing Strategy for Production Flutter Apps"

---

### Phase 2: Architecture & Firebase (Weekends 33-57)

**Duration:** 25 weekends (200 hours)  
**Goal:** Scale architecture and add cloud synchronization

**Key Deliverables:**
- Monorepo with Melos (multiple packages)
- Budget management features
- Firebase Authentication (Email, Google, Apple)
- Multi-device synchronization with Firestore
- Offline-first architecture
- Smart push notifications
- Remote Config for feature flags
- Firebase Analytics and Crashlytics
- A/B testing capabilities

**Learning Focus:**
- Monorepo architecture
- Package management with Melos
- Firebase ecosystem
- Offline-first patterns
- Cloud synchronization strategies

**Content Creation:**
- Article: "Implementing Offline-First Architecture in Flutter"
- Article: "Building a Monorepo with Melos"
- Article: "Hive to Firestore: Local-First to Cloud Sync Migration" *(updated)*
- Video: "Firebase Integration Best Practices"

---

### Phase 3: Custom Backend (Weekends 58-92)

**Duration:** 35 weekends (280 hours)  
**Goal:** Build and deploy custom backend infrastructure

**Key Deliverables:**
- Go backend with REST API
- WebSocket for real-time features
- PostgreSQL database with GORM
- Redis caching layer
- JWT authentication
- Migration from Firebase to custom backend
- Advanced analytics processing
- PDF/CSV export generation
- Docker containerization
- Terraform infrastructure as code
- Monitoring with Prometheus
- Error tracking with Sentry
- Deployment to Cloud Run or Railway

**Learning Focus:**
- Go programming language
- Backend architecture patterns
- RESTful API design
- WebSocket implementation
- Database design and optimization
- Caching strategies
- DevOps and infrastructure
- Monitoring and observability

**Content Creation:**
- Article: "Building a Go Backend for Flutter Apps"
- Article: "Real-time Features with WebSocket"
- Article: "Migrating from Firebase to Custom Backend"
- Video: "Full-Stack Flutter Development"

---

### Phase 4: ML & Launch (Weekends 93-131) [Optional]

**Duration:** 39 weekends (312 hours)  
**Goal:** Add advanced features and publish to stores

**Key Deliverables:**
- Machine Learning models:
  - Spending prediction
  - Anomaly detection
  - Smart categorization
- OCR receipt scanning with ML Kit
- Multi-user features:
  - Shared budgets
  - Family accounts
  - Permission system
- Flutter Web dashboard
- Internationalization (i18n)
- Accessibility (a11y) compliance
- Performance optimization
- App Store submission and approval
- Google Play submission and approval
- Marketing website

**Learning Focus:**
- TensorFlow Lite integration
- ML model training and optimization
- ML Kit and Firebase ML
- Flutter Web specifics
- Internationalization
- Accessibility standards
- App Store optimization (ASO)
- Store submission process

**Content Creation:**
- Article: "Adding Machine Learning to Flutter Apps"
- Article: "OCR Receipt Scanning with ML Kit"
- Video: "The Complete Journey: From Idea to App Store"

---

## Learning Objectives

### Technical Skills

**Flutter & Dart:**
- [ ] Master advanced BLoC patterns and state management
- [ ] Implement complex animations and custom painters
- [ ] Optimize app performance and bundle size
- [ ] Build responsive and adaptive layouts
- [ ] Create reusable design system components

**Architecture:**
- [ ] Implement Clean Architecture at scale
- [ ] Design scalable feature-first structure
- [ ] Manage monorepo with multiple packages
- [ ] Apply SOLID principles consistently
- [ ] Design effective dependency injection

**Backend Development:**
- [ ] Learn Go programming language
- [ ] Build REST APIs with Gin framework
- [ ] Implement WebSocket communication
- [ ] Design PostgreSQL schemas
- [ ] Optimize queries and use Redis caching
- [ ] Implement JWT authentication

**DevOps & Infrastructure:**
- [ ] Configure advanced CI/CD pipelines
- [ ] Master Docker containerization
- [ ] Learn infrastructure as code with Terraform
- [ ] Set up monitoring and alerting
- [ ] Implement error tracking and logging
- [ ] Deploy to cloud platforms

**Machine Learning:**
- [ ] Integrate TensorFlow Lite models
- [ ] Implement ML Kit for OCR
- [ ] Train basic ML models
- [ ] Optimize ML performance on mobile

**Testing:**
- [ ] Write comprehensive unit tests
- [ ] Create widget test suites
- [ ] Implement integration tests
- [ ] Use golden tests for UI
- [ ] Mock external dependencies effectively

### Soft Skills

**Content Creation:**
- [ ] Write 8+ technical articles
- [ ] Create 6+ technical videos
- [ ] Build presence on Medium/Dev.to
- [ ] Grow YouTube channel

**Open Source:**
- [ ] Contribute 50+ GitHub contributions
- [ ] Engage with Flutter community
- [ ] Help others with issues and PRs

**Communication:**
- [ ] Document decisions clearly
- [ ] Explain complex concepts simply
- [ ] Present technical work effectively

**Project Management:**
- [ ] Break down complex projects
- [ ] Estimate time accurately
- [ ] Manage scope and priorities
- [ ] Maintain consistent progress

---

## Success Metrics

### Technical Metrics

**Code Quality:**
- [ ] Test coverage ≥75% (filtrada, excl. generados) — CI gate: ≥60%
- [ ] Zero critical bugs in production
- [ ] Code follows style guide (100% lint passing)
- [ ] All features documented

**Performance:**
- [ ] Cold start time <2 seconds
- [ ] App size <2MB (download size)
- [ ] 60 FPS maintained during animations
- [ ] API response time <300ms (p95)

**Deployment:**
- [ ] CI/CD pipeline <10 minutes
- [ ] Automated testing on every PR
- [ ] Zero-downtime deployments
- [ ] Rollback capability <5 minutes

**User Metrics (Post-Launch):**
- [ ] 100+ active users
- [ ] 4.5+ star rating on stores
- [ ] <5% crash rate
- [ ] >70% user retention (30 days)

### Career Metrics

**Portfolio:**
- [ ] Professional GitHub profile
- [ ] README with detailed documentation
- [ ] Live demo available
- [ ] Case study written

**Content:**
- [ ] 8+ technical articles published
- [ ] 1000+ total article views
- [ ] 6+ videos published
- [ ] 500+ video views

**Community:**
- [ ] 50+ GitHub stars on project
- [ ] 50+ open source contributions
- [ ] Active presence in Flutter community

**Career Advancement:**
- [ ] Updated CV with project
- [ ] Portfolio site with case study
- [ ] LinkedIn profile enhanced
- [ ] 3-5x salary increase achieved

### Project Completion Metrics

- [ ] 131 weekends completed
- [ ] 1,040 hours invested
- [ ] 4 phases completed
- [ ] 630+ tasks completed
- [ ] App published on both stores

---

## Project Philosophy

### Core Principles

**1. Quality Over Speed**
- Better to do something right than to do it fast
- Take time to understand concepts deeply
- Refactor when necessary
- Don't accumulate technical debt

**2. Ship Over Perfect**
- Done is better than perfect
- Release iterative versions
- Get feedback early and often
- Perfection is the enemy of progress

**3. Consistency Over Intensity**
- 8 hours every weekend > 20 hours sporadically
- Build habits, not sprints
- Sustainable pace prevents burnout
- Regular progress compounds

**4. Learn in Public**
- Document everything
- Share progress and learnings
- Help others learn from your journey
- Build credibility through transparency

**5. Process Over Outcomes**
- Focus on what you can control (effort, learning)
- Results will follow good process
- Enjoy the journey of learning
- Measure progress, not just completion

### Development Mantras

**"Start simple, iterate complex"**
- Begin with the simplest possible implementation
- Add complexity only when needed
- Refactor as understanding grows

**"Test before, test after, test always"**
- Write tests for critical paths
- Don't skip testing for "simple" features
- Tests are documentation

**"Document for future you"**
- You'll forget why you made decisions
- Comments explain "why", not "what"
- Keep README and docs updated

**"Break it down, build it up"**
- Large tasks are overwhelming
- Small tasks are achievable
- Celebrate small wins

---

## Risk Management

### Identified Risks & Mitigation

**1. Time Management Risk**

*Risk:* Weekend time gets consumed by other priorities

*Mitigation:*
- Block calendar every Saturday and Sunday morning
- Communicate boundaries with family
- Track actual hours worked
- Adjust timeline if needed

**2. Scope Creep Risk**

*Risk:* Adding too many features, never finishing

*Mitigation:*
- Strict phase boundaries
- Feature freeze periods
- "Nice to have" vs "Must have" lists
- Phase 4 is explicitly optional

**3. Motivation Risk**

*Risk:* Losing interest or burnout over 32 months

*Mitigation:*
- Celebrate milestones
- Share progress publicly
- Take breaks without guilt
- Connect with community

**4. Technical Complexity Risk**

*Risk:* Getting stuck on difficult problems

*Mitigation:*
- Research before implementing
- Ask for help in communities
- Use proven patterns and libraries
- Simplify when stuck >2 weekends

**5. Career Timing Risk**

*Risk:* Job market changes, project becomes outdated

*Mitigation:*
- Ship early and often
- MVP is launchable after Phase 1
- Keep technologies current
- Focus on principles over specific tools

### Contingency Plans

**If you fall behind >2 weekends:**
1. Review and reduce scope
2. Simplify current phase features
3. Skip optional enhancements
4. Focus on core deliverables

**If you advance faster than planned:**
1. Add optional features
2. Improve test coverage
3. Enhance documentation
4. Start next phase early

**If work emergency arises:**
1. Pause project without guilt
2. Document current state
3. Resume when possible
4. Adjust timeline

**If motivation drops:**
1. Review goals and "why"
2. Celebrate current achievements
3. Take a week off
4. Adjust scope to be more exciting

---

## Career Impact

### Target Positions

**Current Level:**
- Mid-level Flutter Developer
- Salary: ~$X (base)

**Target Level:**
- Senior Flutter Developer
- Staff Flutter Engineer
- Mobile Architect
- Full-Stack Mobile Engineer

**Expected Salary Range:**
- 3-5x current salary
- Better benefits
- Remote opportunities
- More interesting projects

### How This Project Helps

**Interview Advantage:**
- Concrete example of complex project
- Demonstrates initiative and self-learning
- Shows commitment and consistency
- Proves full-stack capabilities

**Resume Enhancement:**
- Real production-quality project
- Measurable metrics (test coverage, users, etc.)
- Modern tech stack
- Published apps

**Portfolio Differentiation:**
- Goes beyond typical tutorial projects
- Shows architectural thinking
- Demonstrates DevOps skills
- Includes backend development

**Technical Credibility:**
- Written content establishes expertise
- Video content shows communication skills
- Open source contributions show community engagement
- Live app proves execution ability

### Application Strategy

**Resume:**
- Feature FinTrack Pro prominently
- Highlight specific metrics (test coverage, users, etc.)
- Emphasize full-stack capabilities
- Show progression through phases

**Portfolio Site:**
- Dedicated case study page
- Screenshots and demo video
- Technical breakdown
- Links to articles and code

**LinkedIn:**
- Post milestone achievements
- Share articles and videos
- Update skills section
- Engage with posts about project

**Applications:**
- Mention project in cover letter
- Reference in behavioral questions
- Use as technical discussion topic
- Share GitHub repository

---

## Timeline & Milestones

### Major Milestones

| Milestone | Weekend | Date (Estimated) | Celebration |
|-----------|---------|------------------|-------------|
| Project Start | 1 | [Start Date] | Kick-off commit |
| MVP Complete | 14 | [+3.5 months] | Demo video |
| First Tests | 20 | [+5 months] | Test party 🎉 |
| 80% Coverage | 32 | [+8 months] | Coverage badge |
| Firebase Sync | 45 | [+11 months] | Multi-device demo |
| Monorepo Done | 57 | [+14 months] | Architecture article |
| Backend Live | 75 | [+18 months] | API launch |
| Go Backend | 92 | [+23 months] | Backend article series |
| ML Features | 110 | [+27 months] | ML demo video |
| Store Approval | 125 | [+31 months] | Pre-launch party |
| **PUBLIC LAUNCH** | 131 | [+32 months] | **🚀 LAUNCH DAY! 🎊** |

### Content Creation Schedule

**Articles (8+):**
1. "Building FinTrack Pro: Clean Architecture in Flutter" (Phase 0)
2. "Complete CI/CD Pipeline for Flutter Apps" (Phase 1)
3. "Testing Strategy for Production Apps" (Phase 1)
4. "Hive vs Drift: Choosing the Right Local Database" (Phase 2) *(updated)*
5. "Managing a Flutter Monorepo with Melos" (Phase 2)
6. "Building a Go Backend for Flutter" (Phase 3)
7. "Real-time Features with WebSocket" (Phase 3)
8. "Machine Learning in Flutter Apps" (Phase 4)

**Videos (6+):**
1. MVP Demo (3 min) - Phase 0
2. Testing Strategy Deep Dive (10 min) - Phase 1
3. Firebase Integration Tutorial (15 min) - Phase 2
4. Full-Stack Development Walkthrough (20 min) - Phase 3
5. ML Features Showcase (12 min) - Phase 4
6. Complete Journey: Idea to App Store (25 min) - Phase 4

---

## Support & Resources

### Learning Resources

**Flutter:**
- Official Flutter documentation
- Flutter Widget of the Week (YouTube)
- Reso Coder tutorials
- Dart documentation

**Architecture:**
- Clean Architecture by Robert C. Martin
- Reso Coder Clean Architecture series
- Flutter architecture samples (GitHub)

**Go:**
- A Tour of Go (official)
- Go by Example
- Learn Go with Tests

**Testing:**
- Flutter testing documentation
- Test-Driven Development by Kent Beck
- bloc_test documentation

**DevOps:**
- GitHub Actions documentation
- Fastlane documentation
- Terraform tutorials

### Community Support

**Discord/Slack:**
- Flutter Community
- Flutter Berlin
- Go Community

**Reddit:**
- r/FlutterDev
- r/golang
- r/iOSProgramming

**Twitter:**
- Follow Flutter team
- Follow Go developers
- Share progress

### Getting Help

**When Stuck:**
1. Read documentation thoroughly
2. Search Stack Overflow
3. Ask in Discord/Slack
4. Create minimal reproduction
5. Post detailed question

**Code Review:**
- Ask in Flutter Community
- Share in Discord
- Tweet with #FlutterDev
- Create discussion issue

---

## Document Control

**Document Version:** 1.1
**Last Updated:** December 2025
**Status:** 🚧 In Progress - Phase 0 MVP (~60% complete)
**Next Action:** Weekend 3 - Transaction Edit & Analytics

**Change Log:**
- 2024-11-XX: Initial document creation
- 2025-11-23: Project started - Weekend 1 completed
- 2025-12-06: Updated with Hive vs Drift decision rationale
- 2025-12-06: Updated Phase 0 progress status (~60% complete)
- 2025-12-06: Updated tech stack to reflect actual implementation (Hive)

---

## Appendix

### Useful Commands

```bash
# Setup
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Testing
flutter test
flutter test --coverage
flutter test integration_test/

# Code Quality
flutter analyze
dart format .
dart fix --apply

# Build
flutter build apk --release
flutter build ios --release
flutter build web --release

# Run
flutter run --flavor dev
flutter run --flavor prod
```

### Important Links

- **Repository:** [To be created]
- **Project Board:** [To be created]
- **Portfolio:** https://wdavid73.netlify.app/
- **Articles:** [To be published]
- **Videos:** [To be created]

### Contact

For questions or collaboration:
- GitHub: [@wdavid73](https://github.com/wdavid73)
- Email: [Your Email]
- LinkedIn: [Your LinkedIn]

---

**Remember:** This is a marathon, not a sprint. Stay consistent, enjoy the process, and celebrate every milestone! 🚀
