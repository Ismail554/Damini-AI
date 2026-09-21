
# Damani AI / Synvest: App Registration & Onboarding API Flow

This document maps the exact API endpoints and JSON payloads required to implement the unified Registration and Onboarding flow on the frontend. 

All endpoints expect the `Authorization: Bearer <access_token>` header, except for Step 1 (Registration) and Step 2 (Verify OTP).

---

## Part 1: Registration & Account Creation

### 1. Register Account
**Endpoint:** `POST /api/v1/auth/register/`
**Purpose:** Creates the user account and triggers the email verification OTP.
**Payload:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com",
  "password": "StrongPassword123!"
}
```
**Response:** `201 Created`

### 2. Verify OTP
**Endpoint:** `POST /api/v1/auth/verify-otp/`
**Purpose:** Verifies the 6-digit OTP sent to the user's email.
**Payload:**
```json
{
  "email": "john@example.com",
  "code": "123456"
}
```
**Response:** `200 OK`
*Note:* This response contains the `access` and `refresh` tokens, as well as the decoded `user` object. **You must save these tokens securely.** The `user.role` will be `"NONE"` at this stage.

---

## Part 2: Account Onboarding

### 3. Step 1 — Select Role
**Endpoint:** `POST /api/v1/profiles/set-role/`
**Purpose:** Locks in whether the user is a Sponsor or an Investor.
**Payload:**
```json
{
  "role": "INVESTOR" // or "SPONSOR"
}
```
*Note: If the user selects a role, hits "Back", and selects the other role, this endpoint will gracefully handle the switch and return a 200 OK.*

### 4. Step 2 — Select Account Type (Individual vs Company)
**Endpoint:** `PATCH /api/v1/profiles/{role}/onboarding/`
*(Replace `{role}` with `investor` or `sponsor` based on Step 3)*
**Payload:**
```json
{
  "investor_type": "COMPANY" // (Use "sponsor_type" if they are a Sponsor)
}
```
*(Options are `"COMPANY"` or `"INDIVIDUAL"`)*

---

## Part 3: Company Verification (Only if Company)

If the user selected "Company" in Step 4, they must upload their verification documents.

### 5. Upload Company Documents
**Endpoint:** `POST /api/v1/profiles/verification-documents/`
**Content-Type:** `multipart/form-data`
**Payload:**
- `document_type`: `"BUSINESS_LICENSE"` (or `"TAX_DOCUMENT"`)
- `file`: (The actual PDF/JPG file)

*Note: You will make this API call once for each document the user uploads.*

---

## Part 4: Complete Profile & Set Interests

### 6. Complete Profile Details
**Endpoint:** `PATCH /api/v1/profiles/{role}/onboarding/`
**Content-Type:** `multipart/form-data` (because of the profile photo)
**Payload:**
- `phone`: `"+1234567890"`
- `country`: `"USA"`
- `location`: `"New York"`
- `profile_photo`: (Image File)

*(If they are a Company, also include these fields):*
- `legal_company_name`: `"Acme Corp"`
- `registration_number`: `"12345678"`
- `business_address`: `"123 Wall St"`
- `company_website`: `"https://acme.com"`
- `position_title`: `"CEO"`

### 7. Fetch Available Industries (Reference Data)
**Endpoint:** `GET /api/v1/profiles/industries/`
**Purpose:** Fetch the list of industries to display as selectable pills on the "Set Interests" screen.
**Response:** `[{ "id": 1, "name": "Real Estate" }, ...]`

### 8. Set Interests
**Endpoint:** `PATCH /api/v1/profiles/{role}/onboarding/`
**Content-Type:** `application/json`
**Payload:**
```json
{
  "industries": [1, 4, 7]
}
```

---

## Part 5: Verification Pending Screen

### 9. Check Verification Status
**Endpoint:** `GET /api/v1/profiles/verification-status/`
**Purpose:** Called when the user hits the dashboard to check if they are allowed to interact with the app.
**Response:**
```json
{
  "status": "success",
  "data": {
    "verification_status": "PENDING"
  }
}
```
*(Other possible values: `"APPROVED"`, `"REJECTED"`, `"UNVERIFIED"`).*

---

### Developer Tips
- You can explore the interactive API schema to see the exact shapes, enums, and required fields by visiting **`/docs/`** or **`/swagger/`** on the backend URL.
- The `PATCH /onboarding/` endpoints gracefully accept both `application/json` and `multipart/form-data`. You can send text fields as JSON, and switch to Form Data only when uploading images.
- If you prefer, you can combine Step 4, Step 6, and Step 8 into a **single massive API call** at the very end of the flow. The API will accept it all at once!
