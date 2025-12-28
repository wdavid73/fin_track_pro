# 🎨 Animation Implementation Plan - Phase 0 Polish

> **Context:** The goal is to elevate the user experience from "functional" to "premium" by implementing advanced Material Design 3 motion patterns.

## 🎯 Objectives
1.  **Smoothness:** Eliminate abrupt screen changes.
2.  **Continuity:** Connect UI elements to show relationship (e.g., FAB expanding to a page).
3.  **Delight:** Add staggered entrance animations to lists.

---

## 🛠️ Proposed Animations (Priority Order)

### 1. Staggered List Animations (High Impact / Low Effort)
**Target:** `AllTransactionsPage` (and any future lists).
**Why:** Items popping in all at once feels stiff. Staggered entrance feels organic.
**Implementation:**
-   **Library:** `animate_do` (Already in project).
-   **Pattern:** Wrap `TransactionCard` in a `FadeInUp` widget.
-   **Logic:** Add a `delay` based on list index: `Duration(milliseconds: index * 50)`.

```dart
// Example Concept
ListView.builder(
  itemBuilder: (context, index) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 50),
      duration: const Duration(milliseconds: 400),
      child: TransactionCard(...),
    );
  },
)
```

### 2. OpenContainer Transform (High Impact)
**Target:** Floating Action Button (FAB) -> `AddTransactionPage`.
**Why:** The FAB literally "morphs" into the new screen, establishing a clean parent-child relationship. Standard Material 3 pattern.
**Implementation:**
-   **Library:** `animations` (Need to add if missing).
-   **Widget:** `OpenContainer` from the `animations` package.
-   **Usage:** Replace the current FAB `onPressed` logic with `OpenContainer` as the FAB wrapper.

### 3. Shared Axis Page Transitions
**Target:** Navigation between parent pages (Home) and child pages (See All Transactions).
**Why:** Standard "Slide" transitions can feel disconnected. Shared Axis (Z-axis) gives depth.
**Implementation:**
-   **Library:** `go_router` + `animations`.
-   **Logic:** Use `CustomTransitionPage` in `app_router.dart` with `SharedAxisTransition`.

### 4. Hero Animations (Polish)
**Target:** Category icons, Total Balance card (if expanding).
**Why:** Connects the same element across different screens.
**Implementation:**
-   **Widget:** Standard Flutter `Hero` widget.
-   **Tag:** Must use unique tags (e.g., `tag: 'category_icon_${category.id}'`).
-   **Note:** Requires the element to exist visually on both source and destination screens.

---

60: ## 📦 Dependencies Checked
61: -   ✅ `animate_do` (Present)
62: -   ✅ `animations` (Added)
63: 
64: ## 📅 Action Plan
65: 1.  **[x] Add `animations` package** (if missing).
66: 2.  **[x] Implement Staggered List** on `AllTransactionsPage`.
67: 3.  **[x] Implement OpenContainer** on Home Page FAB.
68: 4.  **[x] Implement Shared Axis** on Page Transitions.
69: 5.  **[x] Implement Hero Animations** (Polish).
70: 6.  **[x] Review and Polish** timing/curves.
