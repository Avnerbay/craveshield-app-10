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

**Screens (`lib/craveshield/screens/`):**
- `splash_screen.dart` — checks session, routes to disclaimer or home
- `disclaimer_screen.dart`, `register_screen.dart`, `login_screen.dart` — auth flow
- `home_screen.dart` — main dashboard
- `my_shield_screen.dart` — 2×4 grid of 8 shield feature tiles with `FadeTransition`; uses `Image.asset` PNGs from `assets/my_shield_features/`; routes use screen class constants
- `my_breathing_screen.dart` — full 4-7-8 breathing exercise with animated circle, ripples, particles; supports 3 built-in techniques (4-7-8, Box Breathing, Deep Breathing) shown in a 2×2 grid; "Upload Yours" card lets user create custom techniques (persisted via SharedPreferences)
- `my_games_screen.dart` — games hub
- `my_music_screen.dart`, `my_sounds_screen.dart` — stubs (coming soon)
- `my_quotes_screen.dart`, `my_short_break_screen.dart`, `my_support_screen.dart` — stubs
- `settings_screen.dart`, `quick_shield_screen.dart` — stubs
- `memory_vault_screen.dart`, `memory_viewer_screen.dart` — photo memory vault
- `panic_button.dart` — emergency quick-access
- `games/` — individual game screens (bubble pop, memory match, tap target, etc.)

**Services & Theme:**
- `services/crave_auth_session.dart` — session management via `SharedPreferences`
- `theme/craveshield_colors.dart` — Navy `#062F72`, Blue `#0B4EA2`, Sky `#72B9FF`, Panel `#F4F8FF`

### 2. Legacy FlutterFlow Layer (`lib/flutter_flow/`, `lib/auth/`, `lib/backend/`)
Auto-generated FlutterFlow boilerplate. Treat as read-only. The `lib/pages/` directory was deleted during cleanup — do not recreate it.

### Auth Flow
`CraveSplashScreen` → `CraveDisclaimerScreen` → `CraveRegisterScreen` / `CraveLoginScreen` → `CraveHomeScreen` (via `QuitSelectionScreen` as home).

### State Management
- Global: `FFAppState` in `lib/app_state.dart` (Provider, FlutterFlow layer)
- Navigation: `Navigator.pushNamed` in CRAVESHIELD screens; `go_router` in FlutterFlow layer
- Firebase: `VictoriesRecord` in `lib/backend/schema/` is the primary Firestore collection

## Assets

```
assets/
  my_shield_features/   ← 8 PNG icons (my_breathing, my_games, my_music, my_photos,
                           my_quotes, my_short_break, my_sound, my_support) + SVGs + logo
  logo/                 ← craveshield_logo.png / .svg
  images/               ← craveshield_logo.svg + my_shield_features/ subfolder
  icons/                ← addiction icons: cigarette, alcohol, cannabis, cookie
  audio/                ← audio files
  fonts/                ← font assets
  videos/FAMILY.mp4
```

All asset folders are declared in `pubspec.yaml`.

## Routes (registered in `main.dart`)

| Screen | routePath |
|---|---|
| MyShieldScreen | `/crave-my-shield` |
| MyBreathingScreen | `/crave-my-breathing` |
| MyGamesScreen | `/crave-my-games` |
| MyMusicScreen | `/crave-my-music` |
| MySoundsScreen | `/crave-my-sounds` |
| MyQuotesScreen | `/crave-my-quotes` |
| MyShortBreakScreen | `/crave-my-short-break` |
| MySupportScreen | `/crave-my-support` |
| MemoryVaultScreen | `/crave-memory-vault` |
| SettingsScreen | `/crave-settings` |
| QuickShieldScreen | `/crave-quick-shield` |

## Key Conventions

- New screens/features go in `lib/craveshield/screens/`, not in FlutterFlow dirs
- Always use screen class `routePath` constants for navigation — never hardcode route strings
- Use `CraveAuthSession` static methods for reading/writing session state
- Follow the color palette in `craveshield_colors.dart` for all new UI
- Firebase project ID: `thenew-crave-shield-app-sen3wk`
- Dart SDK constraint: `>=3.0.0 <4.0.0`
- Background color convention: `Color(0xFF03122D)` (dark navy) for most screens
- Gradient convention: `[Color(0xFF06265A), Color(0xFF0E4FA8), Color(0xFF062B6D)]` top→bottom
