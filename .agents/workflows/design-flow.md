---
description: Workflow 5 — Consistent Design Flow & Workflow 7 — Null Safety & Production Readiness
---

Goal: Investor and Sponsor screens should feel like one app, not two apps stitched together, even though their feature code is separated (Workflow 3).

5.1 Centralized managers (non-negotiable)
AppColors, AppTextStyles, AppSpacing, AppAssets — no hardcoded hex values, font sizes, or asset path strings inside feature code.
One AppCard used everywhere a project/card is shown, themed via parameters — not two near-identical card widgets, one per role.
5.2 Shared state-widgets (backing Workflow 2)

Build these once, in core/widgets/, and reuse across every Tier B screen:

AppShimmer — the loading skeleton, parameterized by shape (card, list row, detail block).
AppErrorView(message, onRetry)
AppEmptyView(message, icon)
AppDataView isn't really a widget — it's just "your actual screen content," but keep its entry point consistent (always a ListView.builder for lists, always the same padding/scaffold shape for detail screens).
5.3 Per-screen consistency checklist

Before a screen is considered done:

 Loading, data, and error/empty states all present (Tier B) or a direct-field update used correctly (Tier A) — not a hybrid.
 No hardcoded colors, text styles, or spacing values.
 Uses AppShimmer/AppErrorView/AppEmptyView, not a bespoke one-off version.
 Role-appropriate navigation only (no cross-role route leakage).
 Debug log box appears for every network call this screen triggers.
Workflow 7 — Null Safety & Production Readiness

Goal: the app should never crash on a malformed or missing backend field, and errors should be typed and traceable, not generic Exception('error') strings.

7.1 Typed exceptions
dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException() : super('No internet connection. Please check your network.');
}
class TimeoutException extends AppException {
  const TimeoutException() : super('The request took too long. Please try again.');
}
class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please login again.');
}
class ForbiddenException extends AppException {
  const ForbiddenException() : super('You don\'t have permission to do this.');
}
class ServerException extends AppException {
  const ServerException() : super('Something went wrong on our end. Please try again.');
}
class ParsingException extends AppException {
  const ParsingException(String detail) : super('Unexpected data format.');
}
class ValidationException extends AppException {
  const ValidationException(super.message);
}

Map Dio errors to these once, centrally, in the repository layer (or a shared ErrorMapper) — screens should only ever see the typed message, not a raw DioException.

7.2 Null-safety rules
No ! on anything that came from JSON. If a field is truly guaranteed by the backend contract, still default it defensively in fromJson (json['title'] as String? ?? ''), because contracts drift.
No unguarded index access (list[0]) — check isNotEmpty first, or use firstOrNull.
Every model field is nullable unless there's a documented, enforced backend guarantee — and even then, prefer a safe default over a guarantee you can't verify at compile time.
late only for values initialized in initState/constructor before any possible read — never for "I'll set it eventually."
7.3 Pre-merge checklist
 No print() — debugPrint or the ApiLogger only, and both are kDebugMode-gated.
 No hardcoded strings that should be constants (routes, storage keys, endpoint paths).
 Every payload endpoint went through the field-validation check-in (Workflow 4.2) before implementation.
 Every Tier B screen has loading/data/error/empty covered; every Tier A field updates without a full rebuild.
 Role-scoped repository methods, no role parameters branching inside a single method.
 Cache invalidated / DataUpdateNotifier fired on any mutation that affects another role's view of the same data.
 Pull-to-refresh never blanks existing data.
 No file over ~200 lines; split screen+widgets or state+provider if it's creeping past that.
 Ran once in flutter run --profile if the screen has a list or animation, not just debug mode.
How These Workflows Fit Together

For a brand-new endpoint end to end, the order across all seven workflows is:

(W4.2) Field validation check-in — confirm the contract.
(W4.1) Model → Repository → Service (if needed) → Provider → Screen.
(W2) Decide Tier A vs Tier B for what this endpoint feeds — most list/detail endpoints are Tier B; single-field endpoints (like "mark as read") are often Tier A on the consuming side even if the call itself goes through the full repository flow.
(W3) Confirm it lives under the correct role folder, or shared/ if genuinely identical for both.
(W1) Confirm the debug box prints correctly — endpoint only, real payload, real response.
(W6) Add caching/prefetch/notifier wiring if this data is either expensive to reload or affects another screen/role.
(W5 + W7) Run the two checklists before calling it done.