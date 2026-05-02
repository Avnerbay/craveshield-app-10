# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CRAVESHIELD** — a Flutter wellness/addiction recovery app that helps users quit harmful habits (cigarettes, vaping, alcohol, sugar, cannabis, etc.). Backend is Firebase (Auth + Firestore).

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter run -d chrome    # Run on web
flutter run -d android   # Run on Android emulator
flutter run -d ios       # Run on iOS simulator
flutter analyze          # Static analysis (linting)
flutter test             # Run tests
flutter clean && flutter pub get && flutter run  # Full clean rebuild
flutter build apk        # Build for Android
flutter build web        # Build for web
```

## Architecture

The codebase has **two coexisting layers**:

### 1. Modern CRAVESHIELD Module (`lib/craveshield/`)
Hand-crafted, clean architecture — this is where active development happens:
- **`screens/`** — Full-page screens: `splash_screen.dart`, `disclaimer_screen.dart`, `register_screen.dart`, `login_screen.dart`, `home_screen.dart`, `my_shield_screen.dart`
- **`services/crave_auth_session.dart`** — Session management via `SharedPreferences` (stores `isLoggedIn`, `userName`, `userEmail`, `selectedAddiction`)
- **`widgets/`** — Reusable UI components: `CraveShieldButton`, `CraveShieldTextField`, `CraveShieldBackButton`, `CraveShieldScreen`
- **`theme/craveshield_colors.dart`** — Color palette: Navy `#062F72`, Blue `#0B4EA2`, Sky `#72B9FF`, Panel `#F4F8FF`

### 2. Legacy FlutterFlow Layer (`lib/flutter_flow/`, `lib/auth/`, `lib/backend/`, `lib/pages/`, etc.)
Auto-generated FlutterFlow boilerplate. Pages follow a model/widget pair pattern (`*_model.dart` + `*_widget.dart`). Treat this layer as read-only unless specifically modifying a legacy page.

### Auth Flow
`CraveSplashScreen` checks `CraveAuthSession` → if logged in, navigates to home; otherwise → `CraveDisclaimerScreen` → `CraveRegisterScreen` / `CraveLoginScreen` → `CraveHomeScreen`.

Firebase Auth handles the actual authentication; `CraveAuthSession` is a local session cache on top of it.

### State Management
- Global app state: `FFAppState` in `lib/app_state.dart` (Provider-based, used by FlutterFlow layer)
- Navigation: `Navigator.push`/`pushNamed` in CRAVESHIELD screens; `go_router` used in FlutterFlow layer
- Firebase data model base: `lib/backend/schema/` — `VictoriesRecord` is the primary Firestore collection

## Key Conventions

- New screens/features should go in `lib/craveshield/`, not in the FlutterFlow directories
- Use `CraveAuthSession` static methods for reading/writing session state
- Follow the color palette in `craveshield_colors.dart` for all new UI
- Firebase project ID: `thenew-crave-shield-app-sen3wk`
- Dart SDK constraint: `>=3.0.0 <4.0.0`
