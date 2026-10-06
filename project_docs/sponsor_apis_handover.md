# Remaining Sponsor APIs — Backend Integration Handover

This document confirms that all the remaining backend API features you requested for the Sponsor Role have been fully implemented and are ready for integration.

---

## 1. Sponsor NDA Management 
**Status: ✅ Implemented**

You can now use these endpoints instead of the mock data to manage the Sponsor's confidentiality terms and attachments.

### `GET /api/v1/profiles/sponsor/nda/`
Retrieves the authenticated sponsor's active NDA configuration.
- **Headers:** `Authorization: Bearer <token>`
- **Response Format:**
```json
{
  "status": "success",
  "data": {
    "title": "Non-Disclosure Agreement",
    "disclosing_party": "Acme Holdings LLC",
    "effective_date": "2026-10-06",
    "confidentiality_terms": "This Non-Disclosure Agreement governs...",
    "pitch_deck_file": {
      "file_name": "Pitch_Deck_Financials_v3.pdf",
      "file_url": "https://<host>/media/sponsor_ndas/Pitch_Deck_Financials_v3.pdf",
      "file_size": "4.1 MB"
    },
    "custom_clauses": []
  }
}
```

### `POST /api/v1/profiles/sponsor/nda/`
Upload a pitch deck and update NDA terms.
- **Content-Type:** `multipart/form-data`
- **Payload fields:**
  - `confidentiality_terms` (String, Optional)
  - `pitch_deck` (File PDF < 25MB, Optional)
  - `custom_clauses` (Valid JSON Array String, Optional)

---

## 2. Account Deletion Flow
**Status: ✅ Implemented**

This is a critical, App Store-mandated feature that soft-deletes the user and anonymizes their email securely. 

### `POST /api/v1/users/delete-account/`
- **Headers:** `Authorization: Bearer <token>`
- **Content-Type:** `application/json`
- **Request Body:**
```json
{
  "password": "UserCurrentPassword123!"
}
```
- **Backend Logic Handled Automatically:**
  - The password is mathematically verified.
  - The account is soft-deleted and email is anonymized (`deleted_<uuid>_email`).
  - Active Firebase Push Notification tokens are cleared.
  - **Sponsor specific:** All `ACTIVE` projects owned by the sponsor are instantly changed to `TERMINATED` with the reason `"Account deleted by sponsor."`.

---

## 3. Company Verification (Uploaded Documents)
**Status: ✅ Implemented**

We slightly tweaked the existing `GET /api/v1/profiles/verification-status/` endpoint to also return the actual uploaded documents so you can display them on the Profile page!

### `GET /api/v1/profiles/verification-status/`
- **Updated Response Format:**
```json
{
  "status": "success",
  "data": {
    "role": "SPONSOR",
    "status": "PENDING",
    "verification_status": "PENDING",
    "company_name": "Acme Holdings LLC",
    "registration_number": "REG-88921-X",
    "address": "100 Montgomery St, Suite 400, San Francisco, CA",
    "website": "https://acme.com",
    "documents": [
        {
          "id": 12,
          "document_type": "BUSINESS_LICENSE",
          "file": "https://<host>/media/documents/2026/10/license.pdf",
          "created_at": "2026-10-06T15:30:00Z"
        }
    ],
    "rejection_reason": null
  }
}
```

---

## 4. Single Project Details Response Enhancement
**Status: ✅ Implemented**

The context flags you requested for the `GET /api/v1/projects/<id>/` endpoint are fully integrated. 
(Note: we named `nda_requirement.user_has_signed` as `nda_signed`, and `collaboration_request.status` as `my_request_status` to fit the backend serializers, but they function identically!).

**Response contains:**
```json
{
  "id": 3,
  "title": "Downtown Tech Hub",
  "is_saved": true,
  "nda_signed": true,
  "my_request_status": "APPROVED",
  "...": "..."
}
```

**You are fully unblocked to integrate these features.**
