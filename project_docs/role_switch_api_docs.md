# Account Role Switch API Specification

This document outlines the API implementation for switching between **Sponsor** and **Investor** roles on the Braintekh platform.

---

## 1. Architecture Overview (Dual-Persona)

The backend utilizes a **Dual-Persona Architecture**:
- Users only have **one** login (one set of credentials, one `User` entity).
- A single user can have both an `InvestorProfile` and a `SponsorProfile` linked to their account.
- The `active_role` controls which permissions they have and what data they see.
- Switching roles does **not** require the user to log out and log back in. It simply flips their active context and re-issues fresh JWT tokens.

---

## 2. Switch Role Endpoint

Call this endpoint when the user taps the "Switch" button in the Account Type UI.

**Endpoint:** `POST /api/v1/users/switch-role/`  
**Authentication:** Required (`Bearer <access_token>`)  
**Content-Type:** `application/json`

### Request Payload
```json
{
  "role": "SPONSOR"
}
```
*(Allowed values: `"SPONSOR"` or `"INVESTOR"`)*

---

### Scenario A: Success (Profile Exists)
If the user already has the requested profile set up, the backend will instantly flip their active role and return fresh JWT tokens.

**Status Code:** `200 OK`
```json
{
  "status": "success",
  "message": "Switched to SPONSOR mode successfully.",
  "data": {
    "active_role": "SPONSOR",
    "is_onboarded": true,
    "verification_status": "APPROVED",
    "account_type": "COMPANY",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 42,
      "email": "user@example.com",
      "first_name": "Jane",
      "last_name": "Doe",
      "role": "SPONSOR",
      "push_notifications_enabled": true
    }
  }
}
```
*Frontend Action: Update local auth state with the new `access` and `refresh` tokens, and route the user to the Sponsor Dashboard.*

---

### Scenario B: Profile Missing (First-time switch)
If an Investor tries to switch to a Sponsor (or vice versa) for the **very first time**, they will not have that profile in the database yet. The API will safely block the switch and prompt you to run them through onboarding.

**Status Code:** `400 Bad Request`
```json
{
  "status": "error",
  "message": "Sponsor profile does not exist. Please complete Sponsor onboarding.",
  "data": {
    "error_code": "PROFILE_MISSING"
  }
}
```
*Frontend Action: Detect the `PROFILE_MISSING` error code and instantly redirect the user to the Sponsor (or Investor) Onboarding Screens to finish setting up their new persona.*
