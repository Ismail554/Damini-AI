# Account Switch & Onboarding Flow — Comprehensive Audit & Backend Fix Report

**Date:** October 5, 2026  
**Status:** Action Required from Backend Developer  
**Affected Features:** Dual-Persona Role Switch (`Investor` ↔ `Sponsor`), Onboarding Flow, Profile Editing  

---

## 1. Executive Summary & Root Cause Analysis

### The Error Encountered:
```
❌ API ERROR
Endpoint    : PATCH /api/v1/profiles/sponsor/
Body Payload: {"phone":"","country":"","location":"","position_title":"","bio":"","legal_company_name":"Global Ventures LLC","registration_number":"","business_address":"","company_website":""}
Status Code : 403 Forbidden
Error Body  : {"status":"error","message":"This endpoint is available to sponsors only."}
```

### Why did this happen?
1. The user was operating in an **Investor** session (`Authorization: Bearer <Investor_Token>`).
2. When the app attempted to update or create Sponsor profile details via `PATCH /api/v1/profiles/sponsor/` (or `/onboarding/`), the backend's role-based permission class (`IsSponsorOnly`) inspected the incoming JWT token / active DB role.
3. Because the token belongs to an `INVESTOR`, the backend rejected the request with `403 Forbidden`.

---

## 2. The Core Flow Disconnects ("Mispointed" Items)

### Disconnect #1: The "Chicken-and-Egg" Deadlock in Role Switching

There is an architectural deadlock between `switch-role` and the onboarding endpoints:

```
[User is INVESTOR]
       │
       ▼ Tap "Switch to Sponsor"
[POST /api/v1/users/switch-role/ {"role": "SPONSOR"}]
       │
       ▼ Backend response:
400 Bad Request {"error_code": "PROFILE_MISSING"} (NO TOKENS RETURNED!)
       │
       ▼ Frontend follows backend instructions:
Redirect user to Sponsor Onboarding Screen
       │
       ▼ User fills Sponsor details & taps Save:
[PATCH /api/v1/profiles/sponsor/onboarding/]
       │  (Carrying OLD Investor token because backend gave no new tokens!)
       ▼
403 Forbidden: "This endpoint is available to sponsors only."  <--- DEADLOCK!
```

- **The paradox:**
  - The user **cannot get a Sponsor token** because the backend blocks `switch-role` until a Sponsor profile exists.
  - The user **cannot create a Sponsor profile** because the backend blocks the onboarding endpoint unless the user already has a Sponsor token.
  - Neither the user nor the frontend can break this cycle.

---

### Disconnect #2: Backend Specification vs. Live Server Reality

In `project_docs/role_switch_flow.md` (written by the backend team), the documented specification was:

> *"The backend will do the heavy lifting: it changes the active role in the database and generates **fresh JWT tokens** specifically tailored to the new role."*

```json
// Documented in role_switch_flow.md:
POST /api/v1/users/switch-role/
Response 200 OK:
{
  "status": "success",
  "data": {
    "active_role": "SPONSOR",
    "is_onboarded": false,
    "access": "eyJhbGciOiJIUzI1Ni...",
    "refresh": "eyJhbGciOiJIUzI1Ni..."
  }
}
```

**However, the live server does NOT do this:**
- The live server returns `400 Bad Request` with `{"error_code": "PROFILE_MISSING"}` and **no tokens**.
- If the backend actually implements the `200 OK` + fresh tokens + `is_onboarded: false` response as documented in `role_switch_flow.md`, the entire deadlock vanishes!

---

### Disconnect #3: Profile Picture & Profile Data Update Endpoints (Confirmed by Backend)

The backend confirmed:
1. `PATCH /api/v1/users/me/`: Core settings **only** (`first_name`, `last_name`, `push_notifications_enabled`). The nested `profile` object is strictly read-only on `/users/me/`.
2. **Profile Photo & Profile Data Updates**: Must target role-specific endpoints:
   - **INVESTOR**: `PATCH /api/v1/profiles/investor/onboarding/`
   - **SPONSOR**: `PATCH /api/v1/profiles/sponsor/`
   - Both accept `multipart/form-data` with `profile_photo` file and role fields.

---

### Disconnect #4: Empty Strings in Payloads (`""`)

In the error log:
`{"phone":"","country":"","location":"","position_title":"","bio":"","legal_company_name":"Global Ventures LLC",...}`

Empty text fields were being transmitted as empty strings `""` rather than omitted.
- **Frontend Action Taken:** The frontend model `toPatchPayload({String? role})` now automatically filters out empty strings and whitespace, ensuring only fields with actual values are sent.

---

### Disconnect #5: Frontend `EditProfileView` Role-Awareness & Provider Sync

In the mobile app, `EditProfileView` was previously hardcoded to use `sponsorEditProfileProvider` (`PATCH /api/v1/profiles/sponsor/`).
- **Frontend Action Taken:**
  - `SponsorEditProfileRepository` now checks active role:
    - If `INVESTOR` → calls `PATCH /api/v1/profiles/investor/onboarding/` (with `profile_photo` & investor fields).
    - If `SPONSOR` → calls `PATCH /api/v1/profiles/sponsor/` (with `profile_photo` & sponsor fields).
  - Updates `first_name` and `last_name` via `PATCH /api/v1/users/me/`.
  - Refreshes both `investorProfileProvider`, `sponsorProfileProvider`, and `personalInfoProvider` so the new photo is visible everywhere in the UI immediately.

---

## 3. What We Need From the Backend Developer

Please implement **Option A** (Strongly Recommended & already described in your own `role_switch_flow.md`) or **Option B**.

---

### Option A (Recommended): Return Fresh Tokens on Switch Even If Un-onboarded

When `POST /api/v1/users/switch-role/` is called:
1. Update `user.active_role = requested_role` in DB (or create a draft/skeleton profile row).
2. Generate fresh JWT tokens (`access` and `refresh`) with the new role embedded in the claims.
3. Return `200 OK` with `is_onboarded: false` and the tokens:

```json
// POST /api/v1/users/switch-role/
// Payload: {"role": "SPONSOR"}
// Response: 200 OK
{
  "status": "success",
  "message": "Role switched to SPONSOR. Please complete onboarding.",
  "data": {
    "active_role": "SPONSOR",
    "is_onboarded": false,
    "verification_status": "NOT_SUBMITTED",
    "access": "<fresh_jwt_access_token_with_role_SPONSOR>",
    "refresh": "<fresh_jwt_refresh_token>"
  }
}
```

**Why this is ideal:**
- Frontend saves the new tokens immediately.
- When navigating to `/role-onboarding`, all onboarding `PATCH` calls carry the `SPONSOR` token.
- Backend permission checks pass without any 403 errors.

---

### Option B (Alternative): Relax Onboarding Permissions & Auto-Switch

If the backend architecture strictly prevents issuing tokens before profile creation:
1. Update permission classes on `PATCH /api/v1/profiles/sponsor/onboarding/` (and `/investor/onboarding/`) so that **any authenticated user** (`IsAuthenticated`) can access them to create their target profile, even if their `active_role` is currently different.
2. In the onboarding completion step, automatically update `user.active_role` to the target role and return the new JWT tokens in that response:

```json
// PATCH /api/v1/profiles/sponsor/onboarding/
// Response: 200 OK
{
  "status": "success",
  "message": "Sponsor profile created successfully.",
  "data": {
    "is_onboarded": true,
    "access": "<fresh_jwt_access_token>",
    "refresh": "<fresh_jwt_refresh_token>"
  }
}
```

---

## 4. Frontend Resilience Updates Already Applied

To ensure full compatibility once backend adjustments are made, the Flutter app has been updated with:
1. **Empty String Stripping:** All PATCH payloads now omit keys with empty string values (`""`).
2. **Role-Aware Profile Editing:** `EditProfileView` now respects `auth.userRole`, routing updates to `/api/v1/profiles/investor/` or `/api/v1/profiles/sponsor/` appropriately.
3. **Endpoint Fallback:** `OnboardingRepository` now tries `PATCH /api/v1/profiles/{role}/onboarding/` first; if a `404 Not Found` occurs, it automatically falls back to `PATCH /api/v1/profiles/{role}/`.
4. **Final Session Synchronization:** `VerificationPendingScreen` ensures `setRole(role)` and token refresh are triggered when the user taps "Go to Dashboard".
5. **Static Analysis:** `flutter analyze` passes with **0 errors**.

---

## 5. Quick Copy-Paste Message for Backend Developer

> "Hey! We reviewed the account switch & onboarding flow and identified the root cause of the `403 Forbidden` error on `PATCH /api/v1/profiles/sponsor/`:
>
> 1. When an Investor calls `POST /api/v1/users/switch-role/` to switch to Sponsor, the backend returns `400 Bad Request` with `{"error_code": "PROFILE_MISSING"}` and **does not issue fresh JWT tokens**.
> 2. The app redirects to Sponsor onboarding, but every API call (`PATCH /api/v1/profiles/sponsor/onboarding/`) still carries the old `INVESTOR` token.
> 3. The backend's `IsSponsorOnly` permission blocks the call with `403 Forbidden`. The user is stuck in a deadlock.
>
> **The Fix:**  
> Please update `POST /api/v1/users/switch-role/` to return `200 OK` with `is_onboarded: false` along with **fresh `access` and `refresh` tokens for the new role** (as outlined in `role_switch_flow.md`). Once that's active, the client will immediately use the new token and onboarding will succeed without permission errors! Full details are in `project_docs/account_switch_and_onboarding_audit_report.md`."
