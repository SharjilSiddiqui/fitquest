# DartStream Sample-App Review — `fitquest`

**Repo:** https://github.com/SharjilSiddiqui/fitquest
**Reviewed at commit:** `59aee90 readme updated`
**Reviewed against:** the DartStream SaaS reference sample app + our integration best practices
**Date:** 2026-06-10

> TL;DR — Solid, faithful DartStream **core** (REST auth → ds-auth, `Session`, single typed
> client, `Bearer` + `x-tenant-id`, experience via query params), and several hygiene things are
> done right (lockfile committed, `.env` gitignored, cloud-save used *correctly*). Two things to
> fix: it **won't `pub get` on the supported toolchain** (requires Dart 3.12.1, our floor is
> 3.12.0), and the **DartStream integration is thin** — only cloud-save is actually wired; the
> rest of the client surface is dead code. Plus a `FutureBuilder` bug and leftover debug logging.

---

## Scorecard

| Area | Status |
|------|--------|
| DartStream auth/session/client pattern | ✅ Faithful |
| Browser-safe REST auth (no admin SDK) | ✅ Correct |
| Cloud-save usage (single-slot save/load) | ✅ Correct (reads `snapshot.payload`) |
| `pubspec.lock` committed / `.env` gitignored | ✅ Good |
| **Resolves/builds on the support floor** | 🔴 **No** — requires Dart 3.12.1 |
| Breadth of DartStream integration | 🟠 Thin — only cloud-save used |
| Snapshot loading (rebuild behavior) | 🟡 Re-fetches every rebuild |
| Debug logging / secrets-on-web | 🟡 Leftover `print`/`debugPrint`; `.env` shipped as web asset |

---

## ✅ What's great (keep doing this)

- `lib/api/dartstream.dart`, `api/firebase_auth.dart`, `state/session.dart` faithfully follow the
  reference: Identity Toolkit REST sign-in/up → ID token → `DartstreamApi.signup()` (idempotent,
  `409 → /login`) → `userId`+`tenantId`. `Bearer` + `x-tenant-id`, experience calls pass
  `userId`/`tenantId` as query params. All correct.
- **Cloud-save is used the right way.** `CloudSaveService` saves the whole `PlayerData` to one
  `fitquest` slot and reads it back via `snapshot['snapshot']['payload']` — single-slot,
  last-write-wins, which is exactly what cloud-save is for (a resumable game save). 👍
- `pubspec.lock` is committed and `.env` is gitignored — both match our policy.
- Local RPG/game logic (`services/level`, `xp`, `rpg`, `achievement`) + DartStream cloud-save for
  persistence is a sensible split.

---

## 🔴 P0 — Make it build on the supported toolchain

`pubspec.yaml` declares `environment: sdk: ^3.12.1`. The DartStream sample **support floor is
Dart 3.12.0 / Flutter 3.44.0**, so on the canonical toolchain `flutter pub get` fails:

```
The current Dart SDK version is 3.12.0.
Because fitquest requires SDK version ^3.12.1, version solving failed.
```

i.e. the app demands a *higher* floor than the supported one and won't resolve/analyze/build on
it (verified locally on Dart 3.12.0). **Fix:** lower the constraint to match the floor:

```yaml
environment:
  sdk: ^3.12.0      # was ^3.12.1 — aligns with Flutter 3.44.0 / Dart 3.12.0
```

(If there's a real reason to need 3.12.1, raise it with the team and bump the *documented* floor —
but today the agreed floor is 3.12.0/3.44.0.)

---

## 🟠 P1 — The DartStream integration is thin (most of the client is dead code)

`DartstreamApi` defines `featureFlags`, `profile`, `inventory`, `logEvent`, `streamingChannels`,
and `me`, but a usage scan shows **only `saveSnapshot` / `loadSnapshot` are ever called**. So the
app demonstrates **auth + cloud-save only**; the rest is unused surface.

For a sample whose whole point is to *show DartStream*, wire the services into gameplay (mirroring
how the reference app drives a game from live services):
- **Feature flags** — gate a mechanic on a flag (the reference uses `double_score`/`hard_mode`/
  `extra_life`); e.g. a `boss_rush` or `hardcore` flag that changes FitQuest rules.
- **Reactive `logEvent`** — log `quest_completed`, `level_up`, `boss_defeated` events (you already
  have the method).
- **Experience `profile`/`inventory`** — back the hero profile / shop inventory with the
  experience service instead of (or alongside) local models.

Either use these or delete them — but using them turns this from "auth + save demo" into a real
DartStream showcase.

---

## 🟡 P1 — `FutureBuilder(future: _loadPlayer())` is created inside `build()`

`main.dart` does:

```dart
home: ... : FutureBuilder<PlayerData?>(
  future: _loadPlayer(),   // <-- new future on EVERY build
  builder: ...
)
```

`_loadPlayer()` runs `api.loadSnapshot(...)` (a network call). Because the future is created in
`build()`, **every rebuild** (each `notifyListeners()` / `setState`) starts a *fresh* snapshot
fetch — redundant network traffic, UI flicker, and possible reload loops. Memoize it:

```dart
Future<PlayerData?>? _playerFuture;
// create once, after sign-in (e.g. in a listener or didChangeDependencies):
_playerFuture ??= _loadPlayer();
// then: FutureBuilder(future: _playerFuture, ...)
```

so the snapshot loads once per session, not once per frame.

---

## 🟡 P1 — Remove leftover debug logging

- `lib/api/dartstream.dart` dumps the raw snapshot body to console (and is mis-indented):
  ```dart
  print('================ SNAPSHOT RESPONSE ================');
  print(resp.body);
  print('===================================================');
  ```
- Plus many `debugPrint(...)` of `userId` / `tenantId` / `payload` / full `PlayerData` in
  `session.dart`, `cloud_save_service.dart`, and `main.dart` (`debugPrint('Auth Host: …')`,
  `LOGIN SUCCESS … USER ID … TENANT ID …`).

These leak identifiers + payloads to the console and add noise. Strip them (or guard behind a
single debug flag) before this is used as a reference sample.

---

## 🔵 P2 — Best-practice alignment

- **Secrets on web.** `.env` is gitignored (good), but `pubspec.yaml` declares it as a Flutter
  **asset** (`assets: - .env`) and `main.dart` loads it via `flutter_dotenv`. On **Flutter web**,
  bundled assets are downloadable — the deployed site serves your `FIREBASE_API_KEY` + hosts at
  `…/assets/.env`. The reference uses `--dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY`
  (compile-time; no standalone downloadable env file). Recommend switching to `--dart-define` for
  the web build, and add a **`.env.example`** (none present) for onboarding.
- **Fail fast on missing config.** `config.dart` hosts default to `''`; if `.env` is absent every
  call hits a malformed URL with an opaque error. Surface a clear "missing host/.env config"
  message (the reference exposes `hasFirebaseApiKey` for exactly this).
- **Friendlier error copy.** `session.errorMessage = e.toString()` shows raw
  `DartstreamApiException(...)` / `FirebaseAuthException: ...`; the reference strips the prefix
  for user-facing text.
- **DRY the auth.** `signIn` and `signUp` are near-identical; share a private `_authenticate()`
  like the reference `Session`.
- **CI + smoke harness.** No `.github/workflows` and no live-contract check. Add a `flutter
  analyze` CI job and a small headless DartStream smoke script (sign in → exercise each call,
  PASS/FAIL per endpoint) — that would have caught the toolchain-floor break immediately.

---

## Action checklist (in order)

- [ ] Lower `environment: sdk` to `^3.12.0` (match Flutter 3.44.0 / Dart 3.12.0); confirm
      `flutter pub get` + `flutter analyze` + `flutter build web` are green.
- [ ] Memoize the `_loadPlayer()` future so the snapshot loads once per session.
- [ ] Wire real DartStream usage (feature flag + reactive events + experience profile/inventory)
      or remove the unused client methods.
- [ ] Strip the `print`/`debugPrint` of bodies, ids, and payloads.
- [ ] Move the web secret to `--dart-define`; add `.env.example`; fail fast on missing hosts.
- [ ] Friendlier error copy; DRY `signIn`/`signUp`.
- [ ] Add a CI workflow (`flutter analyze`) + a headless DartStream smoke harness.

---

## Appendix — how the DartStream SaaS reference sample does it

- **Drives the app from live services.** Feature flags change gameplay, inventory grants
  abilities, cloud-save persists/resumes full state, every beat logs a reactive event — the whole
  point is to *exercise* DartStream, not just authenticate.
- **Cloud-save = one resumable snapshot** (last-write-wins) — which FitQuest already does right.
- **Secrets via `--dart-define`**, `.env` never committed *and* never shipped as a web asset,
  `pubspec.lock` committed, toolchain pinned to the supported floor (Flutter 3.44.0 / Dart
  3.12.0), CI runs analyze, and `bin/*_deepdive.dart` verify the live contracts before shipping.
- **Load once, render many.** Network fetches are kicked off in state init / cached, never
  recreated inside `build()`.
- **Errors surfaced, not hidden**, with friendly copy for auth failures.

*Nice work on the core integration and the correct cloud-save usage — the main lift here is the
toolchain constraint and broadening the DartStream surface you actually demo. Happy to pair.*
