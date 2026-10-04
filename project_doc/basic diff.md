# Braintekh: Sponsor vs. Investor Architecture Guide

This document provides a highly detailed breakdown of the two primary user roles on the Braintekh platform: **Sponsors** and **Investors**. 

While both roles share some underlying database similarities (like authentication and basic profile fields), their **business logic, workflows, and permissions are completely opposite**. 

---

## 1. High-Level Summary
- **Sponsor (The Creator):** The person or company raising money. They create projects, upload financial documents, and manage incoming requests from investors.
- **Investor (The Backer):** The person or company looking to invest money. They browse projects, sign NDAs, and request to collaborate with Sponsors.

---

## 2. Core Functionalities by Role

### 👨‍💼 Sponsor Functionalities
The Sponsor dashboard is all about **Project Management and Deal Flow**.
1. **Create & Edit Projects:** They fill out large forms (funding goals, ROI, timelines) to publish projects to the platform.
2. **Manage NDAs:** They receive "Collaboration Requests" from Investors.
3. **Approve/Reject Investors:** When an Investor requests to see the full project details, the Sponsor reviews the Investor's profile and clicks "Approve" or "Reject".
4. **Fund Management:** Once a deal is finalized offline, the Sponsor clicks "Fund Received" on the dashboard, which automatically updates the project's `raised_amount` and progress bar.
5. **Group Chat Management:** Sponsors own the group chats for their projects and have the authority to kick (remove) participants from the chat.

### 💰 Investor Functionalities
The Investor dashboard is all about **Discovery and Due Diligence**.
1. **Browse Projects:** They view the public feed of projects (filtered by category, industry, etc.).
2. **Request Collaboration (Sign NDA):** To see sensitive project documents (financials, cap tables), they must hit "Request to Collaborate" and agree to the Sponsor's confidentiality terms.
3. **View Private Documents:** Once approved by the Sponsor, the Investor unlocks the "Documents" tab for that specific project.
4. **Track Contributions:** They can see their active investments and pending collaboration requests.
5. **Set Preferences:** They can select specific `Industries` they are interested in (e.g., Real Estate, AI) to curate their feed.

---

## 3. Database Fields & Differences

Both profiles live in the `profiles/models.py` file. They share a lot of fields because both roles require Identity/Company Verification (KYC/KYB), but there are a few critical differences.

### Shared Fields (Both Roles)
Because both roles can either be an `INDIVIDUAL` or a `COMPANY`, they share these exact fields:
- `legal_company_name`, `registration_number`, `business_address`, `company_website`
- `phone`, `country`, `location`
- `position_title`, `bio`, `profile_photo`
- `verification_status` (Pending, Approved, Rejected)

### Differences in Fields
| Feature | Sponsor Profile | Investor Profile |
| :--- | :--- | :--- |
| **Type Flag** | `sponsor_type` (Individual / Company) | `investor_type` (Individual / Company) |
| **Company Name Override** | N/A | Has a `company_name` field specifically for Individual investors who still want to display where they work. |
| **Preferences** | N/A | Has a many-to-many `industries` array. Investors use this to select what type of projects they want to see. Sponsors do not have this on their profile (they assign industries directly to their *Projects*). |

---

## 4. API Endpoints Segregation

To prevent bugs, the backend strictly segregates APIs by role. 
If an Investor tries to call a Sponsor API, the backend throws a `403 Forbidden` error.

**Sponsor-Only APIs (Requires `sponsor_profile`):**
- `POST /api/v1/projects/sponsor/` (Create a project)
- `GET /api/v1/projects/sponsor/requests/` (View who wants to invest)
- `POST /api/v1/projects/sponsor/requests/{id}/approve/`
- `POST /api/v1/projects/sponsor/requests/{id}/reject/`
- `POST /api/v1/projects/sponsor/requests/{id}/fund-received/`
- `DELETE /chat/conversations/{id}/participants/{user_id}/` (Kick users from chat)

**Investor-Only APIs (Requires `investor_profile`):**
- `POST /api/v1/projects/investor/{project_id}/collaborate/` (Sign NDA)
- `GET /api/v1/projects/investor/requests/` (Track status of sent requests)

**Shared APIs:**
- `GET /api/v1/projects/public/` (Feed)
- `GET /api/v1/projects/public/{id}/` (Details)
- Chat messaging, Notifications, and Profile settings.
