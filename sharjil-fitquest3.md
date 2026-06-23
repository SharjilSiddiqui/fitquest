# DartStream Sample Review — `fitquest` (round 4)

**Developer:** Sharjil Siddiqui
**Repo:** https://github.com/SharjilSiddiqui/fitquest
**Reviewed at commit:** `58f047b deployed to firebase` (2026-06-16)
**Live URL:** https://sharjil-siddiqui.web.app  ·  https://sharjil-siddiqui.firebaseapp.com (both **200 ✅**)
**Previous reviews:** June 11 (faithful core, cloud-save correct, but `^3.12.1` floor / thin integration / debug prints / `.env` as web asset), June 12 (genuine SDK migration, flags drive gameplay — but NEW P0: `.env` declared as a flutter asset but gitignored → fresh-clone `build web` FAILED; checkpoint, "still pushing updates")
**Date:** 2026-06-22
**Toolchain:** Flutter 3.44.1 / Dart 3.12.1, fresh clone

> TL;DR — **Everything from the round-2 checkpoint is resolved, and he shipped it.** The `.env`
> -as-asset P0 is fixed (now `--dart-define`, no dotenv loading), `reactive.trackEvent` is
> wired, all debug prints are gone, CI runs analyze + test + build web, and the app is
> **deployed and live on Firebase Hosting** — the only sample in the cohort with a working
> hosted URL, which is exactly what Jeremy asked for. `pub get` / `analyze` / `test` /
> `build web` are all green on a fresh clone. Remaining items are P2/P3 polish (unused dotenv
> dep, a duplicate config file, placeholder-only tests).

---

## Scorecard (Δ vs round 2)

| Area | Round 2 (`d3c81eb`) | Round 4 (`58f047b`) |
|------|---------------------|---------------------|
| Fresh-clone `build web` | 🔴 P0 — `.env` asset gitignored → FAILS | ✅ `--dart-define`, no asset → `✓ Built build/web` |
| Firebase key handling | dotenv asset | ✅ `String.fromEnvironment('FIREBASE_API_KEY')` |
| `reactive.trackEvent` | 🟡 missing | ✅ `event_service` → `reactive.trackEvent` |
| Debug prints (ids/payloads) | 🟡 26 | ✅ 0 in `lib/` |
| CI | 🔴 none | ✅ analyze + test + `build web --dart-define=…` |
| Deployed / hosted URL | none | ✅ **live** at sharjil-siddiqui.web.app (200) |
| `analyze` / `test` / `build web` | partial | ✅ / ✅ 1/1 / ✅ |
| Pure SDK (no `package:http`) | ✅ | ✅ |

---

## Verification evidence (fresh clone, Flutter 3.44.1 / Dart 3.12.1)

```
flutter pub get                                        ✅ hosted dartstream_client 0.0.1
flutter analyze                                        ✅ No issues found! (2.9s)
flutter test                                           ✅ 1/1 (widget smoke)
flutter build web --dart-define=FIREBASE_API_KEY=dummy ✅ ✓ Built build/web   (was 🔴 P0 in round 2)
curl https://sharjil-siddiqui.web.app                  ✅ 200
curl https://sharjil-siddiqui.firebaseapp.com          ✅ 200
```

---

## ✅ What's now strong

- **The round-2 P0 is fixed the right way.** `.env` is no longer a declared flutter asset;
  there's no `dotenv` load anywhere in `lib/`; the key comes from
  `String.fromEnvironment('FIREBASE_API_KEY')` injected via `--dart-define`. Fresh-clone
  `build web` succeeds and CI proves it with a dummy define.
- **Actually deployed.** `.firebaserc` targets project `aortem-sample-apps`, hosting site
  `sharjil-siddiqui`; `firebase.json` serves `build/web` as an SPA. Both `.web.app` and
  `.firebaseapp.com` return 200 — **this is the live URL to hand to the marketing/AI round-up.**
- **Clean service-oriented architecture, pure SDK.** One service per concern
  (`dartstream_client_service`, `auth_me_service`, `feature_flag_service`, `cloud_save_service`,
  `event_service`, plus RPG/level/xp domain services) and **zero `package:http` in `lib/`** —
  everything goes through `dartstream_client`. Four services wired: auth
  (`createEmailPasswordSession` / `onboardFirebaseSession` / `signInWithEmailPassword` /
  `updateUser`), platform (`listFeatureFlags`), experience (`loadCloudSave` / `saveCloudSave`),
  reactive (`trackEvent`).
- **Hygiene** — no `.env` tracked or in history, no committed keys, debug prints gone, CI green.

---

## 🟡 P2 — Cleanups

- **`flutter_dotenv: ^5.2.1` is now an unused dependency.** The migration to `--dart-define`
  left dotenv in `pubspec.yaml` with no import or `.load()` anywhere in `lib/`. Remove it so
  the dep list reflects reality (and to avoid anyone re-introducing the asset pattern).
- **Two config files define the same key.** `lib/config.dart` (used by
  `dartstream_client_service`) and `lib/config/app_config.dart` both declare
  `firebaseApiKey = String.fromEnvironment(...)`. Delete the unused one
  (`lib/config/app_config.dart`) to avoid drift.

---

## 🟡 P2 — Tests are placeholder-only

`test/widget_test.dart` is a single trivial smoke ("test suite is configured"). There are no
SDK-contract tests. CI runs `flutter test`, so adding real coverage is cheap and high-value:
inject a `MockClient` into the real `DartStreamClient` (James/Emeka's pattern) and assert the
`saveCloudSave` envelope and the `trackEvent` payload shape. The clean service split makes this
straightforward.

---

## 🔵 P3 — Notes

- **Inventory still isn't backed by the SDK.** There's an `inventory_screen.dart`, but no
  `experience.inventory` call — it's local RPG state. Fine for the demo; wiring it would round
  out the experience-service story (carried over from round 2).
- **Committed review docs.** `sharjil-fitquest1.md` / `sharjil-fitquest2.md` (my round-1/2
  reviews) are committed in the repo root. Harmless, but probably not what you want shipping in
  a featured sample — consider removing or moving to `/docs`.
- Auth uses the **instance-level** methods (`createEmailPasswordSession` +
  `onboardFirebaseSession`) rather than the static `DartStreamClient.signIn/signUp` convenience
  the others use. Both are valid; just noting the cohort divergence.

---

## Action checklist

- [x] P0 — fix `.env`-as-asset so fresh-clone `build web` works (done → `--dart-define`)
- [x] P1 — add `reactive.trackEvent`, remove debug prints, add CI (all done)
- [x] deploy to a live URL (done → sharjil-siddiqui.web.app)
- [ ] P2 — remove the unused `flutter_dotenv` dependency
- [ ] P2 — delete the duplicate `lib/config/app_config.dart`
- [ ] P2 — add MockClient SDK-contract tests (cloud-save envelope + trackEvent payload)
- [ ] P3 — back `inventory_screen` with `experience.inventory`; move/remove committed review docs

**Bottom line:** Sharjil closed every round-2 item and went one further — fitquest is the
**only sample that's actually deployed and reachable**, with clean analyze/test/build-web on a
fresh clone, pure-SDK service architecture, and proper `--dart-define` key handling. The
remaining work is light polish (drop the unused dotenv dep, dedupe config, add real tests).
This is effectively a sign-off pending those P2 cleanups — and right now it's the best
candidate for the marketing/AI feature because it has a live URL. Great work, Sharjil.
