# DartStream SDK-Migration Review — `fitquest` (round 2)

**Developer:** Sharjil Siddiqui
**Repo:** https://github.com/SharjilSiddiqui/fitquest
**Reviewed at commit:** `d3c81eb migrated to dartstream_client`
**Previous review:** June 11 (pre-SDK, hand-written client)
**Date:** 2026-06-12

> TL;DR — This is a **genuine migration**: the hand-written `api/` client is gone, all auth and
> service calls go through `dartstream_client ^0.0.1`, and feature flags now actually **drive
> gameplay** (`double_xp` changes XP rewards) — the round-1 "thin integration" feedback was taken
> seriously. One P0 remains, and it's a new one: **a fresh clone fails `flutter build web`**
> because `.env` is declared as a Flutter asset but isn't (correctly!) committed. Drop the
> dotenv/asset pattern for `--dart-define` and this is in good shape. (Sharjil flagged he's still
> pushing updates, so treat this as a mid-flight checkpoint.)

---

## Scorecard

| Area | Status |
|------|--------|
| Migrated to `dartstream_client` (no hand-written HTTP) | ✅ Yes — no `package:http`, no Identity Toolkit code left |
| Auth via SDK (`signInWithEmailPassword` → `onboardFirebaseSession`) | ✅ Correct |
| Cloud-save via SDK (`DartStreamScope` + `slotKey`, reads `snapshot.payload`) | ✅ Correct |
| Feature flags wired **and driving gameplay** | ✅ New since round 1 — `double_xp` gates XP rewards |
| SDK constraint (`^3.12.0`) | ✅ Fixed from round 1's `^3.12.1` |
| `pubspec.lock` committed / `.env` not committed | ✅ Good |
| **Fresh clone builds (`flutter build web`)** | 🔴 **No** — missing `.env` asset aborts the build |
| Secrets delivery (`--dart-define` vs dotenv web asset) | 🔴 Still dotenv + `.env` shipped as a web asset |
| Debug logging | 🟡 26 `print`/`debugPrint`, incl. userId/tenantId + full save payloads |
| Integration breadth | 🟠 auth + flags + cloud-save; no `trackEvent`, inventory, profile |
| CI | 🔵 None |

---

## Verification evidence (fresh clone, Flutter 3.44.1 / Dart 3.12.1)

```
flutter pub get        ✅ resolves (hosted dartstream_client 0.0.1)
flutter analyze        ⚠️ 1 issue — "The asset file '.env' doesn't exist" (pubspec.yaml:65)
flutter build web      🔴 FAILS — "No file or variants found for asset: .env."
# with an empty .env touched into place:
flutter build web      ✅ succeeds (so the only blocker is the asset declaration)
```

---

## ✅ What's great (and what improved since June 11)

- **The migration is real.** `lib/services/dartstream_client_service.dart` is a clean singleton
  holding one `DartStreamClient` (`DartStreamConfig.dev(firebaseApiKey: …)`) + the active
  `DartStreamSession`. Sign-in/up use `client.auth.signInWithEmailPassword` /
  `createEmailPasswordSession` → `onboardFirebaseSession` — exactly the intended SDK flow. A
  repo-wide grep finds **zero** `package:http` imports and zero Identity Toolkit URLs in `lib/`.
- **Round-1 feedback closed out:**
  - "Integration is thin — only cloud-save wired" → **feature flags now drive the game.**
    `FeatureFlagService.load()` uses `platform.listFeatureFlags`, with tolerant key matching
    (`key ?? flag_key ?? flagKey`, `enabled || status == "active"`), and `double_xp` changes XP
    rewards in four activity paths in `home_screen.dart`. This is the pattern we asked for.
  - "`sdk: ^3.12.1` breaks the floor" → constraint is back to `^3.12.0`. ✅
  - "`_loadPlayer()` future created in `build()`" → gone; loading is `initState`-driven now. ✅
- **Cloud-save remains correct** (and is now SDK-shaped): `DartStreamScope(projectId: 'fitquest')`,
  single `fitquest` slot, payload read back from `snapshot['snapshot']['payload']`, errors
  propagate (no swallowing).

---

## 🔴 P0 — A fresh clone cannot build (and the `.env` asset pattern has to go)

`pubspec.yaml` still declares:

```yaml
flutter:
  assets:
    - .env
```

`.env` is gitignored (correctly), so anyone who clones the repo gets:

```
Error detected in pubspec.yaml:
No file or variants found for asset: .env.
Error: Failed to compile application for the Web.
```

This is the round-1 "`.env` shipped as a web asset" issue grown teeth: before it was a
secrets-hygiene concern (the deployed web bundle serves `.env` as a downloadable asset); now it
also **breaks every fresh checkout**. The fix solves both at once — replace flutter_dotenv with
compile-time injection, like the reference app and the SDK docs:

```dart
// lib/config.dart
class AppConfig {
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static bool get hasFirebaseApiKey => firebaseApiKey.isNotEmpty;
}
```

```sh
flutter run -d chrome --web-port=3000 --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY
```

Then delete: the `flutter_dotenv` dependency, `dotenv.load(...)` in `main.dart`, and the
`assets: - .env` entry. Commit a `.env.example` if you want to document the variable names.

---

## 🟡 P2 — Strip the debug logging

26 `print`/`debugPrint` calls remain, including a login banner that prints `USER ID` / `TENANT ID`
and `CloudSaveService` dumps of the **full save payload** on every load/save. In a deployed web
app these land in every user's browser console. Remove them (or gate behind `kDebugMode` if you
want a couple during development).

---

## 🟠 P2 — Cheap wins now that the SDK is in place

The SDK makes the remaining services one-liners; round 1's "show more of DartStream" is now much
cheaper:

- **Reactive events:** `client.reactive.trackEvent(session, eventType: 'workout_completed',
  payload: {...})` on workout / level-up / boss-defeat. This is the single highest-value add —
  FitQuest generates naturally event-shaped moments constantly.
- **Inventory:** `client.experience.inventoryItems(session, scope: …)` — you have an inventory
  screen and an equipment system; backing it with ds-experience inventory would demo a service no
  other part of the app touches.
- **Profile:** `client.auth.me(...)` for the profile screen instead of locally-held email only.

## 🔵 P3 — Hygiene

- **No CI.** Add a minimal workflow: `flutter pub get`, `flutter analyze`, and
  `flutter build web --dart-define=FIREBASE_API_KEY=dummy` (the dummy-key build is what would have
  caught the P0 above on the first push).
- README "Running" section still documents the `.env` file + plain `flutter run`; update to the
  `--dart-define` line once the P0 fix lands.

---

## Action checklist

- [ ] **P0:** remove `flutter_dotenv` + the `assets: - .env` entry; read the key via
      `String.fromEnvironment('FIREBASE_API_KEY')`; document the `--dart-define` run line.
- [ ] **P2:** delete/gate the 26 `print`/`debugPrint` calls (especially ids + save payloads).
- [ ] **P2:** wire `reactive.trackEvent` into gameplay moments; consider inventory + `auth.me`.
- [ ] **P3:** add CI (analyze + `build web` with a dummy `--dart-define`).
- [ ] **P3:** update README quickstart to the dart-define flow; add `.env.example`.

## Note on the toolchain policy (correction from round 1)

Round 1 flagged `^3.12.1` as breaking "the 3.12.0 floor". The policy has since been clarified:
**track the latest stable Flutter/Dart** (currently Flutter 3.44.1 / Dart 3.12.1), minimum Dart
3.12.0. `^3.12.0` (what you have now) is ideal for a Flutter app — note that `dartstream_client`
itself requires Dart ≥3.12.1, so the *effective* floor of the resolved app is 3.12.1, which the
current Flutter stable provides.
