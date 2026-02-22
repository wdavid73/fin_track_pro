.PHONY: help setup-hooks validate analyze test generate clean \
       build-dev build-staging build-prod build-all \
       build-ios-dev build-ios-staging build-ios-prod \
       run-dev run-staging run-prod pre-release

# Use fvm if available, otherwise fallback to global flutter/dart
FLUTTER := $(shell command -v fvm > /dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DART := $(shell command -v fvm > /dev/null 2>&1 && echo "fvm dart" || echo "dart")

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────────────────────
# Setup
# ──────────────────────────────────────────

setup-hooks: ## Install git hooks from scripts/
	@cp scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git hooks installed successfully."

# ──────────────────────────────────────────
# Validation & Quality
# ──────────────────────────────────────────

validate: ## Run release config validation
	$(DART) run tools/validate_release_config.dart

analyze: ## Run static analysis
	$(FLUTTER) analyze --no-pub

test: ## Run all tests with coverage
	$(FLUTTER) test --no-pub --coverage

generate: ## Run build_runner code generation
	$(DART) run build_runner build --delete-conflicting-outputs

# ──────────────────────────────────────────
# Android Builds
# ──────────────────────────────────────────

build-dev: ## Build dev APK (debug)
	$(FLUTTER) build apk --flavor dev -t lib/flavors/main_dev.dart --debug

build-staging: ## Build staging APK (debug)
	$(FLUTTER) build apk --flavor staging -t lib/flavors/main_staging.dart --debug

build-prod: ## Build prod APK (release)
	$(FLUTTER) build apk --flavor prod -t lib/flavors/main_prod.dart --release

build-all: build-dev build-staging build-prod ## Build all flavors

# ──────────────────────────────────────────
# iOS Builds
# ──────────────────────────────────────────

build-ios-dev: ## Build dev iOS (debug, no codesign)
	$(FLUTTER) build ios --flavor dev -t lib/flavors/main_dev.dart --debug --no-codesign

build-ios-staging: ## Build staging iOS (debug, no codesign)
	$(FLUTTER) build ios --flavor staging -t lib/flavors/main_staging.dart --debug --no-codesign

build-ios-prod: ## Build prod iOS (release, no codesign)
	$(FLUTTER) build ios --flavor prod -t lib/flavors/main_prod.dart --release --no-codesign

# ──────────────────────────────────────────
# Run
# ──────────────────────────────────────────

run-dev: ## Run dev flavor
	$(FLUTTER) run --flavor dev -t lib/flavors/main_dev.dart

run-staging: ## Run staging flavor
	$(FLUTTER) run --flavor staging -t lib/flavors/main_staging.dart

run-prod: ## Run prod flavor
	$(FLUTTER) run --flavor prod -t lib/flavors/main_prod.dart

# ──────────────────────────────────────────
# Pre-release
# ──────────────────────────────────────────

pre-release: validate analyze test build-prod ## Full pre-release check (validate + analyze + test + build prod)
	@echo ""
	@echo "Pre-release checks passed!"

# ──────────────────────────────────────────
# Utilities
# ──────────────────────────────────────────

clean: ## Clean build artifacts and reinstall dependencies
	$(FLUTTER) clean
	$(FLUTTER) pub get
