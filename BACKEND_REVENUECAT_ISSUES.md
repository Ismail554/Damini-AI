# RevenueCat / Subscription – Backend Changes Required

Base URL: `https://api.damani.app`
Last updated: 2026-11-15 (after the RevenueCat dashboard setup).
Sections 1–6 were found by probing the live API and the OpenAPI schema at an earlier date; re-check each one, some may already be fixed.

## Current configuration (source of truth)

| Item | Value |
|---|---|
| RevenueCat project | Damani AI (`29a8a82f`) |
| App bundle ID / package | `app.damani.mobile` |
| Entitlement ID | `damani_ai_pro` |
| Product IDs | `monthly`, `yearly`, `lifetime` |
| Offering | `default` (packages: monthly, annual, lifetime) |
| Webhook URL in RevenueCat | `https://api.damani.app/api/v1/subscriptions/revenuecat-webhook/` |
| Webhook scope | All apps, all events, production **and** sandbox |
| Webhook Authorization header | Not set yet (waiting for backend, see issue 1) |

The old IDs `pro_access`, `pro_yearly` and `pro_monthly` are no longer used anywhere. Replace every reference to them.

Prices are set in the stores, not in the backend. The Test Store currently uses $9.99 monthly, $79.99 yearly and $99.99 lifetime; final store prices are still to be confirmed.

## Frontend contract (what the app does)
- RevenueCat `appUserID` = the user's **email** (from `GET /api/v1/users/me/`). The app calls `Purchases.logIn(email)` before purchase.
- The app checks the entitlement `damani_ai_pro` in the RevenueCat SDK.
- The paywall is the RevenueCat-hosted paywall; prices shown come from RevenueCat and the stores.
- The app expects `subscription_tier` (`FREE` / `PRO`) in `GET /api/v1/users/me/`, updated by the RevenueCat webhook.
- After a purchase or restore the app calls `POST /api/v1/subscriptions/sync/`.
- On logout the app calls `Purchases.logOut()`.

---

## Changes caused by the new setup

### N1. Entitlement ID is `damani_ai_pro`
Any check for `pro_access` in the webhook handler or the sync endpoint must change to `damani_ai_pro`, otherwise no purchase grants PRO.

Decide PRO from `event.entitlement_ids` (webhook) or `subscriber.entitlements` (REST API), not from the product ID. On Google Play the product ID in events can arrive as `subscriptionId:basePlanId` (for example `monthly:<base-plan>`), so exact matches on `monthly` / `yearly` are fragile.

### N2. Product IDs are `monthly`, `yearly`, `lifetime`
Update any product-to-plan mapping and the `plan_id` values returned by the API.

### N3. Lifetime purchase (new)
`lifetime` is a one-time purchase. RevenueCat sends it as `NON_RENEWING_PURCHASE` with no expiration date, and no `RENEWAL` or `EXPIRATION` event will follow.
- Set the user to PRO permanently.
- `current_period_end` must be allowed to be `null`, `will_renew` is `false`.
- Only a refund (`CANCELLATION` with a refund reason, or the entitlement disappearing from the subscriber) removes it.

### N4. Sandbox and Test Store events
The webhook delivers both environments. Read `event.environment` (`SANDBOX` / `PRODUCTION`) and decide whether sandbox purchases may upgrade accounts on the production backend. Suggested: allow it only for a list of tester emails, or only on a staging backend.

### N5. Sync endpoint needs the RevenueCat secret key
`POST /api/v1/subscriptions/sync/` must call the RevenueCat REST API with this project's secret API key (`sk_…`, created in RevenueCat under API keys). Keep it server-side only; it must never be in the app or in the repository.

---

## 1. CRITICAL – Webhook has no authentication
`POST /api/v1/subscriptions/revenuecat-webhook/` accepts requests with no `Authorization` header.

```bash
curl -X POST https://api.damani.app/api/v1/subscriptions/revenuecat-webhook/ \
  -H "Content-Type: application/json" \
  -d '{"event":{"type":"INITIAL_PURCHASE","app_user_id":"nobody@example.com"}}'
# -> 200 {"status":"ignored","reason":"User nobody@example.com not found"}
```
The payload is processed (user lookup runs). With a real email, anyone could upgrade any account to PRO.

**Fix:** Generate a long random secret, store it in the backend environment, and verify the incoming `Authorization` header against it with a constant-time compare. Return 401 on mismatch. Then give the secret to the app team, who will enter it in the RevenueCat webhook ("Damani Backend"). Update the schema (`security`) accordingly.

## 2. CRITICAL – Client can self-upgrade
`PATCH /api/v1/users/me/` (`PatchedUserDetailsRequest`) includes `subscription_tier` (enum FREE/PRO) and it is not read-only.

**Fix:** Mark `subscription_tier` read-only in all user serializers. Only the webhook and the sync endpoint may change it.

## 3. Duplicate webhook endpoints
- `/api/v1/subscriptions/revenuecat-webhook/` (this one is configured in RevenueCat)
- `/api/v1/users/revenuecat-webhook/`

**Fix:** remove the `/users/` one, or protect it with the same auth.

## 4. User matching by email only → purchases dropped
Unknown users get `200 ignored`. Purchases made under `$RCAnonymousID:...` are lost silently.

**Fix:**
- Handle `app_user_id`, `original_app_user_id`, `aliases`, and `TRANSFER` events.
- Log/alert on unmatched events and return non-2xx (or store for retry) so RevenueCat retries.
- Recommended: use the backend **user ID** (UUID) as the RevenueCat app user id instead of email (emails change and are PII). Tell frontend if you switch; we will change `logIn(...)`.

## 5. Event handling contract undocumented
The schema has no request/response schema for the webhook. Please confirm and document:
- Entitlement id `damani_ai_pro` and product ids `monthly`, `yearly`, `lifetime`.
- Handled events: `INITIAL_PURCHASE`, `RENEWAL`, `NON_RENEWING_PURCHASE`, `CANCELLATION`, `UNCANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`, `PRODUCT_CHANGE`, `TRANSFER`. `TEST` events (sent from the dashboard) should return 200.
- `EXPIRATION` downgrades to `FREE`; `CANCELLATION` keeps PRO until the period end, unless it is a refund.
- Idempotency (dedupe on event `id`) and out-of-order events (use `event_timestamp_ms`).
- Sandbox vs production events (`environment`, see N4).

## 6. Docs mismatch – reports endpoint
`FRONTEND_COMPLIANCE_AND_UPDATES_GUIDE.md` says `POST /api/v1/core/reports/` → **404**.
Live endpoints: `/api/v1/reports/` (401 without auth) and `/api/v1/moderation/report/`.
The app now uses `/api/v1/reports/` with fallback to the moderation path. Please correct the guide and confirm the canonical endpoint.

---

## Needed from backend (not code)
- The webhook Authorization secret, once the check from issue 1 is deployed.
- Confirmation of which decision was taken for sandbox events (N4).

---

# Subscription APIs (to be built / confirmed)

All endpoints under `/api/v1/subscriptions/`. Auth: `Authorization: Bearer <jwt>` unless noted. Prices and the purchase itself stay in RevenueCat + stores; backend is the source of truth for **tier/entitlement state**.

## A. `GET /api/v1/subscriptions/plans/`
Marketing/config for plans. The paywall itself is rendered by RevenueCat, so this is only used where the app shows plan info outside the paywall. Prices here are display fallbacks and must match the stores.

Response `200`:
```json
{
  "plans": [
    {
      "id": "yearly",
      "name": "Pro Yearly",
      "billing_period": "YEARLY",
      "price": 79.99,
      "currency": "USD",
      "revenuecat_product_id": "yearly",
      "entitlement": "damani_ai_pro",
      "is_best_value": true,
      "trial_days": 0,
      "features": ["Unlimited projects", "Priority support"]
    },
    {
      "id": "monthly",
      "name": "Pro Monthly",
      "billing_period": "MONTHLY",
      "price": 9.99,
      "currency": "USD",
      "revenuecat_product_id": "monthly",
      "entitlement": "damani_ai_pro",
      "is_best_value": false,
      "trial_days": 0,
      "features": ["Unlimited projects"]
    }
  ]
}
```
Note: the app currently parses `billing_period` as `YEARLY` or anything else = monthly. Do not add a `lifetime` plan to this list until the app team confirms the app handles a `LIFETIME` period.

## B. `GET /api/v1/subscriptions/me/`
Current user's subscription status (drives Pro badge, gating, "manage" UI).

Response `200`:
```json
{
  "tier": "PRO",
  "status": "ACTIVE",
  "plan_id": "yearly",
  "entitlement": "damani_ai_pro",
  "store": "APP_STORE",
  "is_trial": false,
  "will_renew": true,
  "current_period_start": "2026-10-01T00:00:00Z",
  "current_period_end": "2027-10-01T00:00:00Z",
  "cancelled_at": null,
  "billing_issue_detected_at": null,
  "management_url": "https://apps.apple.com/account/subscriptions"
}
```
`tier`: `FREE|PRO`. `status`: `NONE|ACTIVE|CANCELLED|GRACE_PERIOD|BILLING_ISSUE|EXPIRED`. Free user: `{"tier":"FREE","status":"NONE", ...nulls}`.
Lifetime user: `"plan_id":"lifetime"`, `"status":"ACTIVE"`, `"will_renew":false`, `"current_period_end":null`.
Also keep `subscription_tier` in `GET /users/me/` (read-only).

## C. `POST /api/v1/subscriptions/sync/`
Called by the app right after a successful purchase/restore so the UI does not wait for the webhook. Backend fetches the subscriber from the RevenueCat REST API (`GET /v1/subscribers/{app_user_id}`, secret key, server-side only), checks the `damani_ai_pro` entitlement, and updates the tier. **Never trust client-sent tier.**

Request: empty body (or `{"source":"purchase|restore"}`).
Response `200`: same body as endpoint B.

## D. `POST /api/v1/subscriptions/revenuecat-webhook/` (existing – fix)
- Auth: RevenueCat `Authorization` header must equal the shared secret (see issue 1). `401` otherwise.
- Must be idempotent (dedupe on `event.id`), handle events listed in issue 5, return `200` only when processed or intentionally ignored, non-2xx on transient failure so RevenueCat retries.
- Updates the same data returned by endpoint B.

## E. `GET /api/v1/subscriptions/history/` (optional)
Paginated list of subscription events/invoices for the user (`event_type`, `plan_id`, `store`, `occurred_at`, `price`, `currency`).

## Error format
Use the standard app error shape: `{"detail": "...", "code": "..."}` with `401` (no/invalid token), `403` (forbidden), `404`, `429`, `5xx`.

## Frontend usage summary
| Screen | Endpoint |
|---|---|
| Paywall | RevenueCat paywall (offering `default`) |
| After purchase / restore | `POST /subscriptions/sync/` |
| Profile / settings / gating | `GET /subscriptions/me/` (and `subscription_tier` in `/users/me/`) |
| Logout | RevenueCat `logOut()` only |
