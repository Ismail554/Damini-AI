# Braintekh: Deep Dive — Sponsor vs. Investor Architecture

This document provides an exhaustive, granular breakdown of the two primary user roles on the Braintekh platform: **Sponsors** and **Investors**. 

This guide is written specifically for Frontend Developers to eliminate any ambiguity around state management, API usage, UI rendering, and database structure.

---

## 1. Core Philosophy & App Routing

From the moment a user logs in, the app essentially splits into two completely different applications. You should route them to entirely different Dashboard layouts based on the `user.role` returned from the `/api/v1/users/me/` endpoint.

- **Sponsor (The Creator / Fundraiser):** 
  - **Goal:** Raise capital, pitch projects, and vet investors.
  - **UX Expectation:** Needs complex forms, metric dashboards, and applicant management tables. They own the data.
- **Investor (The Backer / L.P.):** 
  - **Goal:** Deploy capital, discover deals, and conduct due diligence.
  - **UX Expectation:** Needs feed scrolling, search filters, document viewers, and portfolio tracking. They consume the data.

---

## 2. Onboarding Flow & Registration Differences

Both roles go through KYC (Know Your Customer) or KYB (Know Your Business) verification, but their onboarding flows differ slightly in the UI.

### 🏢 Both Roles (The Shared Flow)
Whether they pick Sponsor or Investor, they must choose if they are an **Individual** or a **Company**.
- If **Company**: The frontend must collect `legal_company_name`, `registration_number`, `business_address`, and `company_website`.
- If **Individual**: Those company-specific fields should be hidden or optional.
- Both roles must upload a profile photo, provide their location (`country`, `location`), and write a bio.

### 🔍 Investor-Specific Onboarding Step
Investors have an extra step in their onboarding flow that Sponsors do not: **Preferences**.
- Investors must be presented with a list of `Industries` (fetched from `GET /api/v1/profiles/industries/`).
- They select multiple industries they are interested in (e.g., Tech, Real Estate, Healthcare).
- This is sent as an array of IDs in the `industries` field during profile creation.

---

## 3. The Data Dictionary: Profile Fields

Both profiles live in the database under `profiles/models.py`. Here is exactly what the JSON responses look like and where they differ.

### Sponsor Profile JSON
```json
{
  "id": 1,
  "sponsor_type": "COMPANY", // Or "INDIVIDUAL"
  "legal_company_name": "Acme Corp",
  "registration_number": "123456789",
  "business_address": "123 Main St, TX",
  "company_website": "https://acme.com",
  "phone": "+1234567890",
  "country": "USA",
  "location": "Austin, TX",
  "position_title": "CEO",
  "bio": "Building the future of AI.",
  "profile_photo": "https://storage.com/photo.jpg",
  "verification_status": "APPROVED" // Cannot publish projects until APPROVED
}
```

### Investor Profile JSON
```json
{
  "id": 2,
  "investor_type": "INDIVIDUAL", // Or "COMPANY"
  "company_name": "Google", // UNIQUE TO INVESTOR: Individuals can list where they work.
  "legal_company_name": "", 
  "registration_number": "",
  "business_address": "",
  "company_website": "",
  "phone": "+1987654321",
  "country": "USA",
  "location": "San Francisco, CA",
  "position_title": "Product Manager",
  "bio": "Looking for seed stage AI startups.",
  "profile_photo": "https://storage.com/photo2.jpg",
  "verification_status": "APPROVED",
  "industries": [
    {"id": 1, "name": "Artificial Intelligence"},
    {"id": 4, "name": "SaaS"}
  ] // UNIQUE TO INVESTOR: Used for feed curation.
}
```

---

## 4. The Collaboration State Machine (The Deal Flow)

The core mechanic of Braintekh is the "Collaboration Request" (NDA signing). The frontend must handle this state strictly.

### Step 1: The Public View (Investor Action)
- Investor views a project feed (`GET /api/v1/projects/public/`).
- Sensitive fields (Documents, Financials) are **null** or hidden.
- Investor clicks "Request to Collaborate" (`POST /api/v1/projects/investor/{id}/collaborate/`).
- State: `status = "PENDING"`.

### Step 2: The Review View (Sponsor Action)
- Sponsor receives a notification and opens their dashboard (`GET /api/v1/projects/sponsor/requests/`).
- Sponsor views the Investor's profile.
- Sponsor clicks "Approve" (`POST /api/v1/projects/sponsor/requests/{id}/approve/`) OR "Reject" (`.../reject/`).
- State: `status = "APPROVED"` or `"REJECTED"`.

### Step 3: The Private View (Investor Action)
- If approved, the Investor reloads the project details.
- The API now returns the sensitive `documents` array.
- The Investor conducts offline due diligence and sends money offline.

### Step 4: The Funding View (Sponsor Action)
- Once the wire transfer clears offline, the Sponsor goes to the Collaboration Request and clicks "Fund Received" (`POST /api/v1/projects/sponsor/requests/{id}/fund-received/`).
- Payload: `{"amount": "50000.00"}`
- **Backend Magic:** The backend automatically adds 50,000 to the project's total `raised_amount` and recalculates the progress bar. The frontend just needs to refresh the project details.

---

## 5. API Endpoint Segregation (Security)

To prevent bugs, the backend strictly segregates APIs by role using Permission Classes. If an Investor tries to call a Sponsor API, the backend throws a `403 Forbidden` error. 

**Frontend Dev Tip:** Ensure your network interceptors gracefully handle 403s and log the user out if they somehow cross boundaries.

### 🏢 Sponsor-Only APIs 
*(Requires the user to have a `sponsor_profile`)*
- `POST /api/v1/projects/sponsor/` (Create a project with `multipart/form-data`)
- `PATCH /api/v1/projects/sponsor/{id}/` (Edit their own project)
- `GET /api/v1/projects/sponsor/requests/` (View who wants to invest)
- `POST /api/v1/projects/sponsor/requests/{id}/approve/`
- `POST /api/v1/projects/sponsor/requests/{id}/reject/`
- `POST /api/v1/projects/sponsor/requests/{id}/fund-received/`
- `DELETE /api/v1/notifications/chat/conversations/{id}/participants/{user_id}/` (Sponsors own the group chats and can kick users)

### 💰 Investor-Only APIs 
*(Requires the user to have an `investor_profile`)*
- `POST /api/v1/projects/investor/{project_id}/collaborate/` (Sign NDA)
- `GET /api/v1/projects/investor/requests/` (Track status of sent requests)
- `POST /api/v1/projects/investor/{project_id}/save/` (Bookmark a project)

### 🤝 Shared APIs 
*(Accessible by both)*
- `GET /api/v1/projects/public/` (Feed)
- `GET /api/v1/projects/public/{id}/` (Details - automatically redacts data if user is not an approved investor)
- Chat Messaging (WebSockets)
- Notifications
- Profile settings and Password changes

---

## 6. Null-Safety & Edge Cases for Frontend

1. **Calculated Fields:** In the `GET /api/v1/projects/public/{id}/` endpoint, fields like `progress` (percentage), `investors_count`, and `pending_review_amount` are calculated dynamically by the backend. The frontend should never calculate these; always trust the backend response.
2. **Redacted Data:** If an Investor views a project they haven't been approved for, the `documents` array and `contributions` array will be completely missing or empty. Do not crash; render a "Sign NDA to view" overlay.
3. **Drafts:** Sponsors can save project Drafts locally on the device (`SharedPreferences` / `CoreData`). Do not send Drafts to the backend until the Sponsor hits "Publish".
