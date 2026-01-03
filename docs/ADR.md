# Architecture Decision Records (ADR)

> A collection of records for architecturally significant decisions made during the development of FinTrack Pro.

**Project:** FinTrack Pro
**Started:** November 2025
**Maintained by:** Wilson David Padilla

---

## Table of Contents

- [ADR-001: Clean Architecture with Feature-First Structure](#adr-001-clean-architecture-with-feature-first-structure)
- [ADR-002: BLoC for State Management](#adr-002-bloc-for-state-management)
- [ADR-003: Hive over Drift for Local Storage](#adr-003-hive-over-drift-for-local-storage)
- [ADR-004: Injectable for Dependency Injection](#adr-004-injectable-for-dependency-injection)
- [ADR-005: go_router for Navigation](#adr-005-go_router-for-navigation)
- [ADR-006: Material Design 3](#adr-006-material-design-3)
- [ADR-007: Conventional Commits with Gitmoji](#adr-007-conventional-commits-with-gitmoji)
- [ADR-008: Flutter Flavors for Environment Management](#adr-008-flutter-flavors-for-environment-management)

---

## ADR-001: Clean Architecture with Feature-First Structure

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

The project needed an architectural pattern that would:
- Support long-term maintainability over 32+ months
- Enable independent testing of business logic
- Allow for easy feature additions and modifications
- Demonstrate professional software architecture skills for portfolio

### Decision

Implement **Clean Architecture** with a **Feature-First** folder structure:

```
lib/
├── features/
│   ├── transactions/
│   │   ├── domain/          # Business logic, entities, contracts
│   │   ├── data/            # Data sources, repositories impl
│   │   └── presentation/    # UI, BLoC, pages, widgets
│   ├── categories/
│   └── analytics/
├── core/                    # Shared utilities
└── app/                     # App configuration, DI
```

**Layers:**
1. **Domain Layer:** Pure Dart, no Flutter dependencies
2. **Data Layer:** Repository implementations, data sources
3. **Presentation Layer:** Flutter UI, state management

### Rationale

**Pros:**
- Testability: Can test business logic without Flutter
- Separation of Concerns: Clear boundaries between layers
- Platform Independence: Domain layer can be reused
- Scalability: Easy to add new features
- Industry Standard: Demonstrates professional knowledge

**Cons:**
- Initial Setup Complexity: More boilerplate initially
- Learning Curve: Requires understanding of architecture principles
- More Files: Each feature has multiple files across layers

**Alternatives Considered:**
- **MVC/MVVM alone:** Less structured, harder to scale
- **Layered Architecture:** Not as clean separation
- **No Architecture:** Would not demonstrate professional skills

### Consequences

**Positive:**
- Business logic is 100% testable independently
- Features are isolated and can be developed in parallel
- Easy to switch between different UI frameworks if needed
- Portfolio demonstrates advanced architectural knowledge

**Negative:**
- More time spent on initial setup
- New developers need training on Clean Architecture
- More files to navigate (mitigated by feature-first structure)

**Mitigation:**
- Feature-first structure keeps related files together
- Comprehensive documentation in PROJECT_CONTEXT.md
- Code generation tools reduce boilerplate

### Status

✅ **Validated** - Working well, 3 features implemented successfully

---

## ADR-002: BLoC for State Management

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Need a state management solution that:
- Works well with Clean Architecture
- Provides predictable state transitions
- Supports complex business logic
- Has excellent testing support
- Is widely used in enterprise Flutter apps

### Decision

Use **flutter_bloc (9.1.1)** as the primary state management solution.

### Rationale

**Pros:**
- Separates business logic from UI completely
- Event-driven architecture fits Clean Architecture
- Excellent testing story with bloc_test
- Predictable state transitions
- Stream-based, reactive
- Industry standard for enterprise apps

**Cons:**
- More boilerplate than simpler solutions
- Steeper learning curve
- Requires understanding of streams

**Alternatives Considered:**
- **Riverpod:** Good, but wanted to deepen BLoC expertise
- **Provider:** Too simple for complex business logic
- **GetX:** Criticized for mixing concerns
- **Redux:** Too much boilerplate

### Consequences

**Positive:**
- Clear separation between business logic and UI
- Easy to test business logic with bloc_test
- Supports complex state scenarios
- Time-travel debugging available

**Negative:**
- More files per feature (bloc, event, state)
- Learning curve for team members

**Mitigation:**
- Use bloc_test for easy testing
- Follow official bloc patterns
- Consider Cubit for simpler features

### Status

✅ **Validated** - Transaction BLoC working well, tests passing

---

## ADR-003: Hive over Drift for Local Storage

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Originally planned to use Drift (SQLite wrapper) for local persistence. During implementation, reconsidered based on:
- MVP speed requirements
- Data model simplicity
- Personal experience with Hive
- Time constraints (8h/weekend)

### Decision

Use **Hive 2.2.3** (NoSQL key-value database) instead of Drift.

### Comparison Matrix

| Aspect | Hive | Drift |
|--------|------|-------|
| Type | NoSQL (key-value) | SQL (relational) |
| Setup Complexity | Simple | Moderate |
| Learning Curve | Low | Medium |
| Performance | Excellent (in-memory) | Very Good |
| Type Safety | Good (adapters) | Excellent (compile-time) |
| Queries | Key-based, filtering | Complex SQL |
| Code Generation | Minimal | Required |
| Migration | Simple | Requires planning |
| Best For | Simple models | Complex relationships |

### Rationale

**Technical Reasons:**
- Data model (transactions, categories, budgets) fits key-value well
- No complex joins needed in Phase 0-2
- Faster iteration for MVP
- In-memory caching provides excellent performance
- Less boilerplate code

**Personal Reasons:**
- Previous experience with Hive in production apps
- Familiarity allows focus on Clean Architecture implementation
- Reduces cognitive load during critical MVP phase

**Cons:**
- Less powerful query capabilities
- Type safety not as strong as Drift
- May need migration in Phase 3 if complex queries needed

**Alternatives Considered:**
- **Drift:** More powerful, but slower setup
- **sqflite:** Too low-level
- **ObjectBox:** Good but less familiar

### Consequences

**Positive:**
- Faster MVP development
- Simple data persistence working in Weekend 1
- Good performance for read-heavy operations
- Easy to add/modify fields

**Negative:**
- Limited complex query support
- May need migration in Phase 3

**Mitigation:**
- Clean Architecture's repository pattern makes migration easy
- Can evaluate Drift in Phase 2-3 if needed
- PostgreSQL backend in Phase 3 will handle complex queries

### Future Considerations

- Suitable for Phase 0-2
- Review for Phase 3 when implementing Go backend
- Repository pattern allows easy swap if needed

### Status

✅ **Validated** - Hive working excellently for MVP needs

---

## ADR-004: Injectable for Dependency Injection

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Clean Architecture requires dependency injection to maintain separation of concerns and enable testing. Need a solution that:
- Supports constructor injection
- Reduces manual DI boilerplate
- Works with get_it service locator
- Generates code automatically

### Decision

Use **get_it 9.1.0** + **injectable 2.6.0** for dependency injection.

### Rationale

**Pros:**
- Automatic code generation reduces boilerplate
- Type-safe dependency resolution
- Supports various registration types (singleton, factory, lazy)
- Works seamlessly with Clean Architecture
- Compile-time dependency graph validation

**Cons:**
- Code generation step required
- Learning curve for annotations
- Build runner can be slow for large projects

**Alternatives Considered:**
- **Manual get_it:** Too much boilerplate
- **Riverpod:** Doesn't fit BLoC pattern as well
- **provider:** Limited DI capabilities

### Consequences

**Positive:**
- ~70% reduction in DI boilerplate
- Auto-generates injection_container.dart
- Easy to register new dependencies
- Clear dependency tree

**Negative:**
- Build step required: `dart run build_runner build`
- Developers need to learn annotations

**Mitigation:**
- Documentation in INJECTABLE_GUIDE.md
- Git hooks to run build_runner
- Clear examples in codebase

### Status

✅ **Validated** - DI working smoothly, easy to maintain

---

## ADR-005: go_router for Navigation

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Need a routing solution that:
- Supports deep linking for future web version
- Type-safe navigation
- Declarative routing
- Works with Material Design 3

### Decision

Use **go_router 17.0.0** for navigation.

### Rationale

**Pros:**
- Declarative routing approach
- Built-in deep linking support
- Type-safe route parameters
- Supports nested navigation
- Official Flutter team package
- Good for web and mobile

**Cons:**
- Different mental model than Navigator 1.0
- Learning curve

**Alternatives Considered:**
- **auto_route:** More code generation
- **Navigator 2.0 manual:** Too complex
- **Navigator 1.0:** Not suitable for web/deep links

### Consequences

**Positive:**
- Ready for Flutter Web in Phase 4
- Deep linking prepared
- Type-safe navigation

**Negative:**
- Team needs to learn go_router patterns

### Status

✅ **Validated** - Navigation working well

---

## ADR-006: Material Design 3

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Need a design system that:
- Provides modern, polished UI
- Supports theming (light/dark)
- Has comprehensive widget library
- Demonstrates modern Flutter knowledge

### Decision

Implement **Material Design 3** (Material You) as the design system.

### Rationale

**Pros:**
- Latest Material Design standard
- Dynamic color theming
- Better accessibility
- Modern, polished look
- Demonstrates up-to-date knowledge

**Cons:**
- Some widgets still evolving
- May need custom implementations

**Alternatives Considered:**
- **Material Design 2:** Older standard
- **Cupertino:** iOS only
- **Custom Design System:** Too much work for MVP

### Consequences

**Positive:**
- Modern, professional UI
- Easy theming with ColorScheme
- Good accessibility out of box

**Negative:**
- Some M3 widgets may need updates

### Status

✅ **Validated** - M3 theme working beautifully

---

## ADR-007: Conventional Commits with Gitmoji

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Need consistent commit message format for:
- Professional git history
- Easy to generate changelogs
- Clear communication of changes
- Portfolio demonstration

### Decision

Use **Conventional Commits** with **Gitmoji** emojis.

**Format:**
```
<emoji> <type>: <description>

Example:
✨ feat: add transaction filtering by category
🐛 fix: resolve balance calculation error
📝 docs: update API documentation
```

### Rationale

**Pros:**
- Visual distinction in git log
- Clear change categorization
- Professional commit history
- Easy changelog generation

**Cons:**
- Requires discipline
- Team needs to learn format

**Alternatives Considered:**
- **Plain Conventional Commits:** Less visual
- **No Standard:** Inconsistent history

### Consequences

**Positive:**
- Professional git history for portfolio
- Easy to scan commit log
- Automated changelog possible

**Negative:**
- Requires commitizen or manual discipline

### Status

✅ **Validated** - 15 commits following standard

---

## ADR-008: Flutter Flavors for Environment Management

**Status:** ✅ Accepted
**Date:** 2025-11-23
**Decision Makers:** Wilson David Padilla
**Phase:** 0 - MVP

### Context

Need to manage different environments:
- Development (local testing)
- Staging (pre-production)
- Production (live users)

Each with different:
- API endpoints
- Feature flags
- Analytics configurations

### Decision

Implement **Flutter Flavors** (dev, staging, prod) from day 1.

### Rationale

**Pros:**
- Separate environments from start
- Easy to switch between configurations
- Can test production builds safely
- Professional setup

**Cons:**
- More complex initial setup
- iOS setup more involved than Android

**Alternatives Considered:**
- **Single environment:** Not scalable
- **Environment variables only:** Less robust

### Consequences

**Positive:**
- Can safely test different configurations
- Production-ready from start
- Easy to add environment-specific features

**Negative:**
- iOS setup complexity (Xcode schemes)

**Mitigation:**
- Documentation in FLAVORS_GUIDE.md
- Scripts to switch flavors easily

### Status

✅ **Validated** - Three flavors working on both platforms

---

## ADR Template

Use this template for future ADRs:

```markdown
## ADR-XXX: [Title]

**Status:** 🔵 Proposed | 🟡 Accepted | 🟢 Implemented | 🔴 Deprecated | ⚫ Superseded
**Date:** YYYY-MM-DD
**Decision Makers:** [Names]
**Phase:** [0-4]

### Context
[Describe the problem and why a decision is needed]

### Decision
[State the decision clearly]

### Rationale

**Pros:**
- [List advantages]

**Cons:**
- [List disadvantages]

**Alternatives Considered:**
- **Option 1:** [Why not chosen]
- **Option 2:** [Why not chosen]

### Consequences

**Positive:**
- [Expected positive outcomes]

**Negative:**
- [Expected negative outcomes]

**Mitigation:**
- [How to address negative consequences]

### Status
[Current implementation status and notes]
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-06 | Wilson David Padilla | Initial ADR document created |
| - | - | - | 8 ADRs documented (001-008) |

---

## Contributing to ADRs

### When to Create an ADR

Create an ADR when making decisions about:
- Architecture patterns (layers, modules)
- Technology choices (libraries, frameworks)
- Design patterns (state management, navigation)
- Development practices (testing, CI/CD)
- Data structures and persistence
- Security and performance strategies

### When NOT to Create an ADR

Don't create ADRs for:
- Minor library version updates
- UI styling choices
- Variable naming conventions
- Temporary workarounds

### ADR Process

1. **Identify the Decision:** Recognize architecturally significant decision
2. **Research:** Explore alternatives, pros/cons
3. **Discuss:** Review with team/mentor if available
4. **Document:** Use ADR template
5. **Implement:** Proceed with decision
6. **Review:** Update status as implementation progresses

### ADR Status Lifecycle

- 🔵 **Proposed:** Decision under consideration
- 🟡 **Accepted:** Decision approved, not yet implemented
- 🟢 **Implemented:** Decision implemented and validated
- 🔴 **Deprecated:** No longer recommended
- ⚫ **Superseded:** Replaced by another ADR

---

## References

### Architecture Resources
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Reso Coder Clean Architecture Series](https://resocoder.com/flutter-clean-architecture-tdd/)

### ADR Resources
- [ADR GitHub Organization](https://adr.github.io/)
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR Tools](https://github.com/npryce/adr-tools)

### Flutter Resources
- [Flutter Official Docs](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev/)
- [go_router Package](https://pub.dev/packages/go_router)

---

**Document Version:** 1.0
**Last Updated:** 2025-12-06
**Status:** 🟢 Active

**Remember:** ADRs are living documents. Update them as decisions evolve or get superseded! 📚