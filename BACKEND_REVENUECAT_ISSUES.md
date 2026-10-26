# RevenueCat / Subscription – Backend Issues

Base URL: `https://api.damani.app`
Found by probing the live API and the OpenAPI schema.

## Frontend contract (what the app does)
- RevenueCat `appUserID` = the user's **email** (from `GET /api/v1/users/me/`). The app calls `Purchases.logIn(email)` before purchase.
- Entitlement id: `pro_access`.
- The app expects `subscription_tier` (`FREE` / `PRO`) in `GET /api/v1/users/me/`, updated by the RevenueCat webhook.
- On logout the app calls `Purchases.logOut()`.

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

**Fix:** Configure an Authorization header value in the RevenueCat dashboard (Webhooks) and verify it server-side with a constant-time compare. Return 401/403 on mismatch. Update the schema (`security`) accordingly.

## 2. CRITICAL – Client can self-upgrade
`PATCH /api/v1/users/me/` (`PatchedUserDetailsRequest`) includes `subscription_tier` (enum FREE/PRO) and it is not read-only.

**Fix:** Mark `subscription_tier` read-only in all user serializers. Only the webhook may change it.

## 3. Duplicate webhook endpoints
- `/api/v1/subscriptions/revenuecat-webhook/`
- `/api/v1/users/revenuecat-webhook/`

Same behaviour. **Fix:** keep one, remove or redirect the other, and tell us which URL is configured in RevenueCat.

## 4. User matching by email only → purchases dropped
Unknown users get `200 ignored`. Purchases made under `$RCAnonymousID:...` are lost silently.

**Fix:**
- Handle `app_user_id`, `original_app_user_id`, `aliases`, and `TRANSFER` events.
- Log/alert on unmatched events and return non-2xx (or store for retry) so RevenueCat retries.
- Recommended: use the backend **user ID** (UUID) as the RevenueCat app user id instead of email (emails change and are PII). Tell frontend if you switch; we will change `logIn(...)`.

## 5. Event handling contract undocumented
The schema has no request/response schema for the webhook. Please confirm and document:
- Entitlement id `pro_access` and the product ids.
- Handled events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`, `PRODUCT_CHANGE`, `UNCANCELLATION`, `TRANSFER`.
- `EXPIRATION` downgrades to `FREE`; `CANCELLATION` keeps PRO until the period end.
- Idempotency (dedupe on event `id`) and out-of-order events (use `event_timestamp_ms`).
- Sandbox vs production events (`environment`).

## 6. Docs mismatch – reports endpoint
`FRONTEND_COMPLIANCE_AND_UPDATES_GUIDE.md` says `POST /api/v1/core/reports/` → **404**.
Live endpoints: `/api/v1/reports/` (401 without auth) and `/api/v1/moderation/report/`.
The app now uses `/api/v1/reports/` with fallback to the moderation path. Please correct the guide and confirm the canonical endpoint.

---

## Needed from backend / product (not code)
- Real RevenueCat **public SDK keys** (Google `goog_...`, Apple `appl_...`). `.env` currently has placeholders.
- Store products + offering + entitlement `pro_access` configured in the RevenueCat dashboard.
- Webhook URL + auth header set in the RevenueCat dashboard.

---

# Required Subscription APIs (to be built / confirmed)

All endpoints under `/api/v1/subscriptions/`. Auth: `Authorization: Bearer <jwt>` unless noted. Prices/purchase itself stay in RevenueCat + stores; backend is the source of truth for **tier/entitlement state**.

## A. `GET /api/v1/subscriptions/plans/`
List available plans so the app can render the paywall (the app currently hardcodes "$229/yr", "$22/mo"). Store price strings still come from RevenueCat offerings; this supplies marketing/config.

Response `200`:
```json
{
  "plans": [
    {
      "id": "pro_yearly",
      "name": "Pro Yearly",
      "billing_period": "YEARLY",
      "price": 229.00,
      "currency": "USD",
      "revenuecat_product_id": "pro_yearly",
      "entitlement": "pro_access",
      "is_best_value": true,
      "trial_days": 0,
      "features": ["Unlimited projects", "Priority support"]
    },
    {
      "id": "pro_monthly",
      "name": "Pro Monthly",
      "billing_period": "MONTHLY",
      "price": 22.00,
      "currency": "USD",
      "revenuecat_product_id": "pro_monthly",
      "entitlement": "pro_access",
      "is_best_value": false,
      "trial_days": 0,
      "features": ["Unlimited projects"]
    }
  ]
}
```

## B. `GET /api/v1/subscriptions/me/`
Current user's subscription status (drives Pro badge, gating, "manage" UI).

Response `200`:
```json
{
  "tier": "PRO",
  "status": "ACTIVE",
  "plan_id": "pro_yearly",
  "entitlement": "pro_access",
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
Also keep `subscription_tier` in `GET /users/me/` (read-only).

## C. `POST /api/v1/subscriptions/sync/`
Called by the app right after a successful purchase/restore so the UI does not wait for the webhook. Backend fetches the subscriber from the RevenueCat REST API (`GET /v1/subscribers/{app_user_id}`, secret key, server-side only) and updates the tier. **Never trust client-sent tier.**

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
| Paywall | `GET /subscriptions/plans/` + RevenueCat offerings |
| After purchase / restore | `POST /subscriptions/sync/` |
| Profile / settings / gating | `GET /subscriptions/me/` (and `subscription_tier` in `/users/me/`) |
| Logout | RevenueCat `logOut()` only |
