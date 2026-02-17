#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────
# Config
# ──────────────────────────────────────────

PROJECT_NAME="FinTrack Pro"
HOOKS_PATH="tools/git-hooks"
FLUTTER_REQUIRED_VERSION="3.19.0" # opcional: ajusta o elimina

CI_MODE=false

if [[ "${1:-}" == "--ci" ]]; then
  CI_MODE=true
fi

# ──────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────

print_header() {
  echo ""
  echo "========================================"
  echo "  $PROJECT_NAME — Project Setup"
  echo "========================================"
  echo ""
}

print_step() {
  echo ""
  echo "▶ $1"
}

fail() {
  echo ""
  echo "❌ ERROR: $1"
  echo ""
  exit 1
}

# ──────────────────────────────────────────
# 0. Ensure repo root
# ──────────────────────────────────────────

if [[ ! -d ".git" ]]; then
  fail "This script must be run from the project root."
fi

print_header

# ──────────────────────────────────────────
# 1. Validate Flutter environment
# ──────────────────────────────────────────

print_step "Validating Flutter environment..."

if command -v fvm &> /dev/null; then
  FLUTTER_CMD="fvm flutter"
  DART_CMD="fvm dart"
  echo "  Using FVM-managed Flutter"
elif command -v flutter &> /dev/null; then
  FLUTTER_CMD="flutter"
  DART_CMD="dart"
  echo "  Using global Flutter"
else
  fail "Flutter is not installed."
fi

if [[ -n "$FLUTTER_REQUIRED_VERSION" ]]; then
  CURRENT_VERSION=$($FLUTTER_CMD --version | head -n 1 | awk '{print $2}')
  echo "  Detected Flutter version: $CURRENT_VERSION"
  # comparación simple (puedes sofisticarla si quieres semver real)
  if [[ "$CURRENT_VERSION" != "$FLUTTER_REQUIRED_VERSION" ]]; then
    echo "  ⚠ Warning: Expected Flutter $FLUTTER_REQUIRED_VERSION"
  fi
fi

echo "  OK: Flutter validated"

# ──────────────────────────────────────────
# 2. Configure Git hooks
# ──────────────────────────────────────────

print_step "Configuring Git hooks..."

git config core.hooksPath "$HOOKS_PATH"

if [[ -d "$HOOKS_PATH" ]]; then
  chmod -R +x "$HOOKS_PATH"
  echo "  Hooks directory validated and permissions set"
else
  fail "Hooks directory '$HOOKS_PATH' not found."
fi

echo "  OK: Git hooks configured"

# ──────────────────────────────────────────
# 3. Install dependencies
# ──────────────────────────────────────────

print_step "Installing Flutter dependencies..."

$FLUTTER_CMD pub get

echo "  OK: Dependencies installed"

# ──────────────────────────────────────────
# 4. Code generation (only if needed)
# ──────────────────────────────────────────

print_step "Running code generation..."

if [[ "$CI_MODE" == false ]]; then
  $DART_CMD run build_runner build --delete-conflicting-outputs
else
  echo "  CI mode: Skipping local build_runner"
fi

echo "  OK: Code generation complete"

# ──────────────────────────────────────────
# 5. Optional: Initial quality check
# ──────────────────────────────────────────

print_step "Running initial analysis..."

$FLUTTER_CMD analyze

echo "  OK: Static analysis passed"

# ──────────────────────────────────────────
# Done
# ──────────────────────────────────────────

echo ""
echo "========================================"
echo "  Setup complete!"
echo "========================================"
echo ""