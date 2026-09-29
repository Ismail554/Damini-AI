# Project Creation API

This document outlines the API contract for creating a new Project as a Sponsor.

---

## Create Project

### `POST /api/v1/projects/sponsor/`
Creates a new project draft or active project under the authenticated sponsor's account.

- **Auth Required**: Yes (`Bearer <token>`)
- **Content-Type**: `multipart/form-data` (Required because of the `cover_image` upload)

### Request Payload (Form Data)

Since this endpoint accepts `multipart/form-data`, you should send these fields as form fields, not as a raw JSON body.

| Field | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `title` | `string` | **Yes** | Main project title (e.g., "Downtown Tech Hub"). |
| `location` | `string` | **Yes** | City/State (e.g., "Austin, TX"). |
| `short_description` | `string` | **Yes** | 1-2 sentence pitch for the project card. |
| `industry` | `int` | Optional | ID of the Industry. |
| `category_ids` | `array of ints` | Optional | Send multiple times or as array if supported by HTTP client. e.g. `category_ids[0]: 1`, `category_ids[1]: 2` |
| `funding_goal` | `decimal` | **Yes** | Total amount you want to raise (e.g., `1000000.00`). |
| `minimum_investment` | `decimal` | **Yes** | Minimum amount an investor can contribute. |
| `target_roi` | `decimal` | **Yes** | Target ROI percentage (e.g., `15.50` for 15.5%). |
| `timeline_months` | `int` | **Yes** | Total project duration in months. |
| `country` | `string` | Optional | Country code or name. |
| `funding_stage` | `string` | Optional | e.g. "Seed", "Series A". |
| `potential_monthly_revenue` | `decimal` | Optional | Expected monthly revenue. |
| `hold_period_months` | `int` | Optional | How long capital is locked. |
| `timeline_to_operations_months` | `int` | Optional | Months until operational. |
| `business_description` | `string` | Optional | Full detailed pitch text. |
| `current_status` | `string` | Optional | Text describing what's happening right now. |
| `next_milestones` | `string` | Optional | Text describing upcoming goals. |
| `use_of_funds` | `string` | Optional | Text breakdown of where money goes. |
| `skin_in_the_game` | `decimal` | Optional | Amount of sponsor's own money invested (Default: `0.00`). |
| `team_members_text` | `string` | Optional | Comma separated list of names. |
| `confidentiality_agreement_text`| `string` | Optional | Text for the NDA that investors must sign. |
| `status` | `string` | Optional | `"ACTIVE"`, `"DRAFT"` (Default is `"DRAFT"`). |
| `cover_image` | `file` | Optional | The banner image file for the project. |

### Expected Response (201 Created)
Returns the fully populated Project Details object (same format as `GET /api/v1/projects/{id}/`).

```json
{
  "status": "success",
  "message": "Project created successfully.",
  "data": {
    "id": 4,
    "title": "Downtown Tech Hub",
    "location": "Austin, TX",
    "status": "ACTIVE",
    "funding_goal": "1000000.00",
    "raised_amount": "0.00",
    "progress": 0.0,
    ...
  }
}
```

---

## Update Project

### `PATCH /api/v1/projects/sponsor/{id}/`
Updates an existing project.

- **Auth Required**: Yes (`Bearer <token>`)
- **Content-Type**: `multipart/form-data`

**Request Payload:** 
Accepts the exact same fields as the Create endpoint above, but all fields are **Optional**. You only need to send the fields you wish to change.

### Expected Response (200 OK)
Returns the updated fully populated Project Details object.
