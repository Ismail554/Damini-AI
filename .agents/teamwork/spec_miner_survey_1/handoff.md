# Specification Mining Handoff Report: Backend API Contracts & Inventory

**Agent ID:** `spec_miner_survey_1`  
**Role:** Specification Miner Subagent  
**Timestamp:** 2026-10-11T05:36:00Z  
**Primary Deliverable:** `d:\Ismail_flutter\julkar_vai\.agents\teamwork\spec_miner_survey_1\spec_inventory.md`

---

## 1. Observation

A full survey was conducted across all backend specification files in `project_docs/`, the project root, `project_doc/`, `docs/`, and client contract constants in `lib/core/constants/api_endpoints.dart`:

1. **Root Specifications**:
   - `INVESTOR_API_SPECIFICATION.md` (479 lines): Catalogs Investor lifecycle, Promotional Banners (`GET /api/v1/banners/?role=investor`), Industry filters (`GET /api/v1/profiles/industries/`), Featured/Trending feed (`GET /api/v1/projects/?category={cat}&is_featured=true&is_trending=true`), Saved deals (`GET /api/v1/projects/saved/`), Deal room details (`GET /api/v1/projects/{id}/`), NDA signing (`POST /api/v1/projects/{id}/sign-nda/`), Collaboration request (`POST /api/v1/projects/{id}/requests/`), and Investment history (`GET /api/v1/investor/investments/`).
   - `INVESTOR_NEXT_FLOW_API_SPEC.md` (178 lines): Catalogs post-collaboration deal lifecycle: Sponsor list requests (`GET /api/v1/projects/sponsor/requests/`), Approve request (`POST /api/v1/projects/sponsor/requests/{request_id}/approve/`), Reject request (`POST /api/v1/projects/sponsor/requests/{request_id}/reject/`), Fund received (`POST /api/v1/projects/sponsor/requests/{request_id}/fund-received/`), and Confirm syndicate (`POST /api/v1/projects/{project_id}/confirm-investors/`).
   - `AI_CHAT_API_SPEC.md` (256 lines): Catalogs AI Copilot endpoints: Initial state (`GET /api/v1/ai/chat/initial/`), Send message (`POST /api/v1/ai/chat/conversations/{id}/messages/`), History (`GET /api/v1/ai/chat/conversations/{id}/messages/`), and Clear (`DELETE /api/v1/ai/chat/conversations/{id}/clear/`).
   - `SOCIAL_AUTH_BACKEND_SPEC.md` (744 lines): Full DRF implementation reference for `POST /api/v1/auth/google/` and `POST /api/v1/auth/apple/`, token verification with Google/Apple JWKS, account linking by email, and dual-role lifecycle where new users receive `role: "NONE"`.
   - `AUDIT_PRODUCTION_READINESS_REPORT.md` (157 lines): Identifies missing auth endpoints: `POST /api/v1/auth/forgot-password/`, `POST /api/v1/auth/reset-password/`, `POST /api/v1/users/change-password/`, `POST /api/v1/users/delete-account/`, and `GET/POST /api/v1/profiles/sponsor/nda/`.

2. **`project_docs/` Directory (17 documents)**:
   - `account_switch_api_spec.md` (278 lines) & `role_switch_api_docs.md` (79 lines): Document `POST /api/v1/users/switch-role/` and `/api/v1/profiles/switch-role/`.
   - `account_switch_and_onboarding_audit_report.md` (199 lines): Verbatim log of live server failure:
     `Status Code: 403 Forbidden` on `PATCH /api/v1/profiles/sponsor/` caused by token deadlock when `POST /api/v1/users/switch-role/` returns `400 Bad Request` `{"error_code": "PROFILE_MISSING"}` with no new tokens.
   - `api_onboarding_flow.md` (139 lines): Multi-step registration (`POST /api/v1/auth/register/`, `POST /api/v1/auth/verify-otp/`), role selection (`POST /api/v1/profiles/set-role/`), onboarding profile patch (`PATCH /api/v1/profiles/{role}/onboarding/`), document upload (`POST /api/v1/profiles/verification-documents/`), and status check (`GET /api/v1/profiles/verification-status/`).
   - `chat_api_and_socket_spec.md` (516 lines): Direct and group chat APIs (`POST .../conversations/start/`, `GET .../conversations/`, `GET .../messages/`, `POST .../upload/`, `POST .../read/`) and WebSocket protocol (`wss://.../ws/chat/{conversation_id}/?token=...`).
   - `group_chat_app_bar_api_spec.md` (338 lines) & `group_chat_app_bar_implementation_notes.md` (46 lines): Live deployed endpoints: `GET .../header/`, `POST .../confirm-investors/`, `DELETE .../participants/{user_id}/`, `POST .../leave/`, and `POST .../report/`.
   - `project_creation_api.md` (80 lines): `POST /api/v1/projects/sponsor/` and `PATCH /api/v1/projects/sponsor/{id}/` accepting multipart form data.
   - `project_termination_api_spec.md` (182 lines): `POST /api/v1/projects/<id>/terminate/` and `GET /api/v1/projects/sponsor/?status=TERMINATED`.
   - `save_profile_api_spec.md` (371 lines): `POST /api/v1/profiles/<id>/save/`, `GET /api/v1/profiles/saved/`, and `GET /api/v1/profiles/<id>/`.
   - `sponsor_apis_handover.md` (118 lines) & `sponsor_remaining_apis_spec.md` (256 lines): Sponsor NDA management (`GET/POST /api/v1/profiles/sponsor/nda/`) and account deletion (`POST /api/v1/users/delete-account/`).

3. **`docs/` and `project_doc/` Directories**:
   - `docs/ai_feature_backend_request.md` (398 lines): 4 endpoints for Damani Advisor project creation wizard (`POST .../ai/projects/conversations/`, `POST .../messages/`, `GET .../`, `DELETE .../`).
   - `project_doc/backend_role_integration_guide.md` & `sponsor_vs_investor.md`: Document role-segregated route variants (`POST /api/v1/projects/investor/{id}/collaborate/`, `GET /api/v1/projects/public/`).

4. **Client Interfaces**:
   - `lib/core/constants/api_endpoints.dart`: 50+ endpoint constants declared, including in-app notifications (`/api/v1/notifications/`, `/read/`, `/mark-all-read/`, `/device-token/`, `/clear-all/`).

---

## 2. Logic Chain

1. **Step 1: Document Reconciliation**: Across the 22 examined markdown documents, endpoint definitions fall into 7 clear architectural domains:
   - Authentication & Identity
   - Profile, Roles & Onboarding
   - Projects, Discovery & Deal Rooms
   - Deals, NDA & Investment History
   - Sponsor Project Administration
   - AI Features (Investment Copilot & Damani Advisor)
   - Real-Time Chat & Push Notifications
2. **Step 2: Schema Envelope Analysis**: Comparing `INVESTOR_API_SPECIFICATION.md` (`"success": true`), `api_onboarding_flow.md` (`"status": "success"`), `AI_CHAT_API_SPEC.md` (`"success": true`), and `project_docs/AI_CHAT_API_SPEC.md` (`"status": "success"`), reveals that the backend uses mixed envelopes across modules. Client models must be resilient to both `"status": "success"` and `"success": true`.
3. **Step 3: Route Discrepancies**:
   - Role switch is referred to as `POST /api/v1/profiles/switch-role/` in `account_switch_api_spec.md`, but `POST /api/v1/users/switch-role/` in `role_switch_api_docs.md` and `api_endpoints.dart`.
   - Sponsor onboarding is referred to as `PATCH /api/v1/profiles/sponsor/onboarding/` in `api_onboarding_flow.md`, but `PATCH /api/v1/profiles/sponsor/` in `role_switch_flow.md`.
   - Project discovery is referred to as `GET /api/v1/projects/?...` in `INVESTOR_API_SPECIFICATION.md`, `GET /api/v1/projects/discover/` in `api_endpoints.dart`, and `GET /api/v1/projects/public/` in `backend_role_integration_guide.md`.
4. **Step 4: Deadlock Discovery**: In `account_switch_and_onboarding_audit_report.md`, the live server returned `400 Bad Request` with `{"error_code": "PROFILE_MISSING"}` on `POST /api/v1/users/switch-role/` without issuing new tokens. This directly contradicted `role_switch_flow.md` line 27-30 (`"The backend will do the heavy lifting... generates fresh JWT tokens... is_onboarded: false"`).
5. **Step 5: Synthesizing the Complete Catalog**: Every endpoint was mapped into `spec_inventory.md` with exact HTTP methods, parameter names, casing (strictly `snake_case`), success shapes, error status codes, and edge case rules.

---

## 3. Caveats

- **Live Staging Availability**: Live endpoint probing is delegated to subsequent subagents (Milestones M2 and M3). This report catalogs specifications, contracts, and documented historical behaviors.
- **Route Aliasing**: Some routes have alternative path conventions (e.g. `/api/v1/users/switch-role/` vs `/api/v1/profiles/switch-role/`). Both are documented in the inventory so live probe agents can test both paths.

---

## 4. Conclusion

1. **100% of Backend Specification Documents Cataloged**: All 22 markdown specification files across root, `project_docs/`, `project_doc/`, and `docs/` have been surveyed, analyzed, and cataloged into `d:\Ismail_flutter\julkar_vai\.agents\teamwork\spec_miner_survey_1\spec_inventory.md`.
2. **75 Distinct Feature Endpoints and 15 Critical Edge Cases Mapped**: Covering all required fields, casing conventions, success JSON shapes, error responses, and architectural quirks.
3. **High-Impact Discrepancies Flagged**: Discrepancies between doc versions regarding route paths, response envelopes, role-switch token deadlocks, and Damani Advisor draft field names are clearly highlighted for the orchestrator and probing agents.

---

## 5. Verification Method

To independently verify this inventory:
1. **Inspect Artifact File**:
   `view_file` on `d:\Ismail_flutter\julkar_vai\.agents\teamwork\spec_miner_survey_1\spec_inventory.md`. Confirm the presence of the `## Features Discovered` table, `## Edge Cases` table, 7 detailed module breakdowns, and the discrepancy section.
2. **Cross-Check Core Files**:
   - Verify `INVESTOR_API_SPECIFICATION.md` (lines 63-446) against Section 3 and 4 of `spec_inventory.md`.
   - Verify `SOCIAL_AUTH_BACKEND_SPEC.md` (lines 140-274) against Section 1 of `spec_inventory.md`.
   - Verify `docs/ai_feature_backend_request.md` (lines 65-240) against Section 5.2 of `spec_inventory.md`.
   - Verify `project_docs/chat_api_and_socket_spec.md` (lines 125-475) against Section 6 of `spec_inventory.md`.
