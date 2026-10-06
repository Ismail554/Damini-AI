# NDA & Document Unlock Flow - Frontend Guide

This guide details the exact sequence of API calls and UI states required to handle the "Sign NDA" flow and unlock confidential documents. 

---

## 1. The API Sequence

The backend handles document security automatically based on the presence of an NDA signature. You do not need to wait for Sponsor approval to unlock documents. As soon as the NDA is signed, the documents unlock.

### Step 1: Create Collaboration Request (If not already done)
Before an investor can sign an NDA, they must have an active "Collaboration Request" for that project.
- **Endpoint:** `POST /api/v1/projects/<project_id>/requests/`
- **Payload:** `{ "proposed_budget": "5000", "message": "I am interested" }`
- *Note: If the user already has a pending/approved request, skip this step.*

### Step 2: Sign the NDA
When the user clicks the blue **"Sign NDA to Unlock"** button (or submits a signature form):
- **Endpoint:** `POST /api/v1/projects/<project_id>/sign-nda/`
- **Method:** `POST` (Multipart Form Data if sending image, otherwise JSON is fine)
- **Payload:** 
  ```json
  {
    "digital_signature": "John Doe"
  }
  ```
- **Response (`200 OK`)**: `"NDA signed successfully. You now have access to confidential documents."`

### Step 3: Refresh the Project Details
Once Step 2 succeeds, immediately re-fetch the project details:
- **Endpoint:** `GET /api/v1/projects/<project_id>/`
- **Magic:** The backend detects that the `request.user` has `nda_signed=True` for this project. The `documents` array in the JSON response will now contain all the hidden confidential files!

---

## 2. Rendering the Unlocked UI

Once you refetch the project in Step 3 and the `documents` array is populated, you should completely remove the "Lock" screen. 

Render the documents using a Grid or List of **Document Cards**:

```json
// Example of the `documents` array returned by GET /projects/<id>/
"documents": [
  {
    "id": 1,
    "title": "Pitch Deck 2026",
    "document_type": "PITCH_DECK",
    "file_url": "https://server.com/media/projects/docs/pitch.pdf",
    "is_confidential": true
  },
  {
    "id": 2,
    "title": "Q3 Financial Projections",
    "document_type": "FINANCIALS",
    "file_url": "https://server.com/media/projects/docs/q3.xlsx",
    "is_confidential": true
  }
]
```

### UI Implementation Checklist:
1. **Remove Padlock:** Hide the Padlock and "Sign NDA" button.
2. **Map the Array:** Loop through the `documents` array.
3. **Icons:** Show a different icon based on `document_type` (e.g., a PDF icon for `PITCH_DECK`, an Excel icon for `FINANCIALS`).
4. **Action Button:** Add a "View" or "Download" button next to each document that uses a URL Launcher to open the `file_url`.
