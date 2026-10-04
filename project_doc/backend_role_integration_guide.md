# Braintekh: Backend Role Integration Guide (Sponsor vs Investor)

Integration reference for Flutter client connecting to Braintekh backend.

---

## 1. Role Core Concept

| Concept | Sponsor (`sponsor_profile`) | Investor (`investor_profile`) |
| :--- | :--- | :--- |
| **Role Type** | Fundraiser / Creator | Backer / LP |
| **Primary Goal** | Post deals, review NDAs, record wire funds | Browse feed, sign NDAs, inspect docs, commit funds |
| **Data Ownership** | Owns project data & chat participants | Consumes public/approved project data |
| **Root Routing** | `/sponsor-dashboard` | `/investor-dashboard` |

App root route determined by `user.role` from `GET /api/v1/users/me/`.

---

## 2. Model & Data Dictionary (`profiles/models.py`)

### 2.1 Shared Profile Fields
Both roles support `INDIVIDUAL` or `COMPANY`.
- `phone` (string)
- `country` (string)
- `location` (string)
- `position_title` (string)
- `bio` (string)
- `profile_photo` (URL string)
- `verification_status` (`PENDING`, `APPROVED`, `REJECTED`)
- Company-only: `legal_company_name`, `registration_number`, `business_address`, `company_website`

### 2.2 Role-Specific Fields

```
SponsorProfile
├── sponsor_type: "INDIVIDUAL" | "COMPANY"
└── (Note: Industries belong to Project model, not profile)

InvestorProfile
├── investor_type: "INDIVIDUAL" | "COMPANY"
├── company_name: string (Optional employer display for individual investors)
└── industries: List<Industry> (M2M filter preferences for feed)
```

---

## 3. API Endpoint Matrix & Permission Guards

Backend throws **`403 Forbidden`** if caller role does not match required profile.

### 3.1 Sponsor-Only (`sponsor_profile` required)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/projects/sponsor/` | Create project (`multipart/form-data`) |
| `PATCH` | `/api/v1/projects/sponsor/{id}/` | Update project details |
| `GET` | `/api/v1/projects/sponsor/requests/` | List incoming collaboration/NDA requests |
| `POST` | `/api/v1/projects/sponsor/requests/{id}/approve/` | Approve investor request |
| `POST` | `/api/v1/projects/sponsor/requests/{id}/reject/` | Reject investor request |
| `POST` | `/api/v1/projects/sponsor/requests/{id}/fund-received/` | Post offline wire (`{"amount": "50000.00"}`) |
| `DELETE` | `/api/v1/notifications/chat/conversations/{id}/participants/{user_id}/` | Remove chat participant |

### 3.2 Investor-Only (`investor_profile` required)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/projects/investor/{project_id}/collaborate/` | Sign NDA / request access |
| `GET` | `/api/v1/projects/investor/requests/` | List sent collaboration requests & status |
| `POST` | `/api/v1/projects/investor/{project_id}/save/` | Bookmark project |

### 3.3 Shared Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/users/me/` | Current user & role flag |
| `GET` | `/api/v1/profiles/industries/` | Industry list for onboarding/filtering |
| `GET` | `/api/v1/projects/public/` | Public discovery feed |
| `GET` | `/api/v1/projects/public/{id}/` | Project details (redacts private docs if unapproved) |
| `WS` | `/chat/` | Project chat sockets |

---

## 4. Deal Flow State Machine

```
[Investor] POST .../projects/investor/{id}/collaborate/
   │
   ▼
[Status: PENDING]
   │
   ├────────► [Sponsor] POST .../requests/{id}/reject/  ──► [Status: REJECTED]
   │
   ▼
[Sponsor] POST .../requests/{id}/approve/ ──► [Status: APPROVED]
   │
   ▼
[Investor] GET .../projects/public/{id}/  ──► unlocks `documents` list
   │
   ▼
(Offline Due Diligence & Bank Wire Transfer)
   │
   ▼
[Sponsor] POST .../requests/{id}/fund-received/ {"amount": "..."}
   │
   ▼
Backend recalculates `raised_amount` + `progress` % automatically
```

---

## 5. Flutter Integration Rules

1. **Routing Guard**:
   - Parse `user.role` after login.
   - Separate route stacks for Sponsor vs Investor to avoid accidental 403 hits.
2. **Null Safety & Redacted Fields**:
   - In `GET /api/v1/projects/public/{id}/`, `documents` and `contributions` return `null` or `[]` when unauthorized.
   - Do not force unwrap (`!`). Show NDA prompt when `documents` absent.
3. **Computed Metrics**:
   - `progress` (%), `investors_count`, `pending_review_amount` are backend-calculated. Never calculate client-side.
4. **Draft Handling**:
   - Sponsor project drafts stored locally (`SharedPreferences`/Hive/SQLite). Push to backend only on explicit "Publish".
5. **Verification Block**:
   - Sponsors with `verification_status != "APPROVED"` cannot publish projects. Guard publish button in UI.
