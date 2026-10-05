# The Dual-Persona Lifecycle: Role Switching & Onboarding Flow

This guide outlines the exact API sequence the Flutter app must follow when a user attempts to switch between their Sponsor and Investor personas, especially if they are doing it for the very first time.

---

## 🔁 Phase 1: The Switch Request

When the user taps "Switch to Investor" (or Sponsor) in the Account Type UI, the app must initiate the context switch.

**API Call:**
`POST /api/v1/users/switch-role/`
```json
{
  "role": "INVESTOR" // or "SPONSOR"
}
```

### The Backend Response
The backend will do the heavy lifting: it changes the active role in the database and generates **fresh JWT tokens** specifically tailored to the new role.

```json
{
  "status": "success",
  "data": {
    "active_role": "INVESTOR",
    "is_onboarded": false, // CRITICAL FLAG
    "access": "eyJhbGciOiJIUzI1NiIs...",
    "refresh": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### Frontend Action:
1. Immediately overwrite your local storage with the new `access` and `refresh` tokens. Every subsequent API call MUST use this new token.
2. Check the `is_onboarded` boolean.
   - If `true`: The user has done this before. Send them straight to the Investor/Sponsor Dashboard!
   - If `false`: This is their first time. Navigate them to the Onboarding Flow.

---

## 📝 Phase 2: The Onboarding Flow

If `is_onboarded` was false, the user must fill out their profile details. Because you saved the new JWT token in Phase 1, you now have the exact permissions required to hit the onboarding endpoints.

> **⚠️ Important:** The endpoints and payloads are strictly separated by role.

### If switching to INVESTOR:
**API Call:** `PATCH /api/v1/profiles/investor/onboarding/`  
*(Requires the new INVESTOR token)*
```json
{
  "investor_type": "INDIVIDUAL",
  "company_name": "Google", // Only if Individual
  "industries": [1, 4, 7], // Array of Industry IDs
  "location": "San Francisco",
  "bio": "Seed stage angel investor."
}
```

### If switching to SPONSOR:
**API Call:** `PATCH /api/v1/profiles/sponsor/`  
*(Requires the new SPONSOR token)*
```json
{
  "sponsor_type": "COMPANY",
  "legal_company_name": "Acme Corp",
  "registration_number": "12345678",
  "business_address": "123 Main St",
  "location": "Austin, TX",
  "bio": "Building the future of AI."
}
```

### Frontend Action:
When the `PATCH` request returns `200 OK`, the onboarding is complete. Navigate the user to their new Dashboard.

---

## 💡 Summary Checklist for Frontend
- [ ] Call `POST /users/switch-role/`.
- [ ] Save the new JWT tokens from the response immediately.
- [ ] Route to Dashboard if `is_onboarded` is `true`.
- [ ] Route to Onboarding form if `is_onboarded` is `false`.
- [ ] Submit the Onboarding form to the correct `PATCH` endpoint based on their new role.
