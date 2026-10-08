# LinguaQuest

Offline-first Flutter learning adventure MVP. The Android-first source, bundled JSON content, SQLite schema, tests, store copy, and Android project configuration are included here.

## Run locally

Requirements: Flutter stable (Dart 3.3+), Android Studio / Android SDK, and Java 17.

```sh
flutter pub get
flutter run
```

## Verify and build

```sh
flutter analyze
flutter test
flutter build appbundle
```

The AAB is produced at `build/app/outputs/bundle/release/app-release.aab`. For a Play upload, replace the debug signing configuration in `android/app/build.gradle` with a private upload keystore. Do not commit that keystore or its passwords.

## What is included

- Splash and first-run setup for Kids (6-10), Junior (11-14), Teen (15-18), and Young Adult (18+).
- Five working bottom-navigation destinations: Home, Learn, Games, Progress, and Profile.
- Map with eleven XP-gated worlds, daily quest, five-phase vocabulary lesson, parent dashboard, premium preview, settings, and privacy page.
- Seven playable modes: multiple choice, word match, sentence builder, memory pairs, timed challenge, picture clue, and logic puzzle.
- English, Hindi, and Japanese starter packs with nine topics each.
- 20 original questions each for science, geography, general knowledge, and logic.
- SQLite schema for users, age profiles, languages, categories, worlds, levels, lessons, words, questions, answers, progress, achievements, daily challenges, settings, and content packs. Bundled JSON seeds the database on first run.
- Local XP, levels, daily quest reward, learning-day streak, and three badges. Progress survives app restarts.
- Riverpod was not needed for this MVP; Provider keeps state local and simple. Future tutor, speaking, personalization, and billing boundaries are defined as interfaces only.
- No internet permission, account, cloud service, analytics, chat, or advertising dependency.

## Deliberate MVP limits

- Audio playback is wired to local assets, but recorded clips are not shipped. A missing clip returns a friendly text fallback. See `assets/audio/README.txt`.
- “Offline ready” means all core app content is bundled and no network is required; the UI does not inspect the device's actual Wi-Fi/mobile-data switch.
- Age ranges select progressively larger question pools and are shown in the lesson UI. Expert-grade age calibration and parent-controlled profiles need content review in a later release.
- Premium plans are preview-only; billing is not enabled. Child-safety basics and core lessons remain free.
- Android Gradle Wrapper files are included. Flutter generates machine-specific `android/local.properties` and build caches on the first local build. Inspect the app on real small/regular/large Android devices before release.
- Verification in the preparation environment: `flutter test` passes all 11 tests; `flutter analyze` reports no errors and 17 info-level style notices. An AAB could not be built here because Java 17 and the Android SDK are unavailable.

## Structure

```text
lib/app/             app theme and entry shell
lib/models/          question and map models
lib/screens/         setup, map, learning, games, profile, parent, settings
lib/services/        SQLite, content, XP, progress, achievements, streak, audio
lib/widgets/         reusable cards, buttons, offline and progress widgets
assets/data/         language packs and 80 knowledge questions
assets/audio/        reserved local audio pack with safe fallback
test/                rules, database, and screen widget tests
android/             package, manifest, icon, Gradle app configuration
```
