## 2026-10-11T05:41:34Z
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

You are the Live API Probing Worker.
Read ORIGINAL_REQUEST.md at `d:\Ismail_flutter\julkar_vai\.agents\teamwork\ORIGINAL_REQUEST.md`.
Your working directory is `d:\Ismail_flutter\julkar_vai\.agents\teamwork\worker_live_probe_1\`.

Your mission is to perform live HTTP probing across all backend endpoints declared in `lib/core/constants/api_endpoints.dart` and the backend specifications against the running backend server:
`https://clubby-andy-irksomely.ngrok-free.dev`.

Input Artifacts to read:
- `d:\Ismail_flutter\julkar_vai\.agents\teamwork\spec_miner_survey_1\spec_inventory.md`
- `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_client_survey_1\client_api_inventory.md`
- `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\backend_survey.md`
- `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\openapi_schema.yaml`

Probing Requirements & Constraints:
1. Target: `https://clubby-andy-irksomely.ngrok-free.dev`
2. Every request MUST include header: `ngrok-skip-browser-warning: 69420` (or `true`) and `Content-Type: application/json` / `Accept: application/json`.
3. Verified Dual-Role Credentials to use:
   - Email: `ismailshuvo555@gmail.com`
   - Password: `586908sH`
   - Role switching endpoint: `POST /api/v1/users/switch-role/` with body `{"role": "INVESTOR"}` or `{"role": "SPONSOR"}`.
4. Develop and execute an automated probe test suite (using a Python script or PowerShell in your working directory) that systematically tests:
   - Public Endpoints: `/api/v1/banners/`, `/api/v1/projects/`, unauthenticated `/api/v1/profiles/industries/` (verify 401), etc.
   - Auth Endpoints: `POST /api/v1/auth/login/`, `POST /api/v1/auth/token/refresh/`, `POST /api/v1/auth/register/` (verify email OTP behavior), `POST /api/v1/auth/verify-otp/`, `POST /api/v1/auth/forgot-password/`, `POST /api/v1/auth/reset-password/`, `POST /api/v1/auth/google/`, `POST /api/v1/auth/apple/`.
   - Investor Role Endpoints (switched to INVESTOR): `GET /api/v1/users/me/`, `GET /api/v1/profiles/industries/`, `PATCH /api/v1/profiles/investor/onboarding/`, `GET /api/v1/projects/?category=&is_featured=true&is_trending=true`, `GET /api/v1/projects/discover/` (test if 404/routed), `GET /api/v1/projects/{id}/`, `POST /api/v1/projects/{id}/save/`, `GET /api/v1/projects/saved/`, `POST /api/v1/projects/{id}/sign-nda/`, `POST /api/v1/projects/{id}/requests/`, `GET /api/v1/investor/investments/`, `GET /api/v1/profiles/{id}/`, `POST /api/v1/profiles/{id}/save/`, `GET /api/v1/profiles/saved/`, `GET /api/v1/ai/chat/initial/`, `POST /api/v1/ai/chat/conversations/{id}/messages/`, `DELETE /api/v1/ai/chat/conversations/{id}/clear/`, `GET /api/v1/chat/conversations/`, `POST /api/v1/chat/conversations/start/`, `GET /api/v1/notifications/`, `POST /api/v1/notifications/read/`, `POST /api/v1/notifications/mark-all-read/`, `DELETE /api/v1/notifications/clear-all/`.
   - Sponsor Role Endpoints (switched to SPONSOR): `GET /api/v1/users/me/`, `PATCH /api/v1/profiles/sponsor/`, `GET /api/v1/profiles/sponsor/nda/`, `POST /api/v1/profiles/sponsor/nda/`, `GET /api/v1/projects/sponsor/`, `POST /api/v1/projects/sponsor/` (create draft), `PATCH /api/v1/projects/sponsor/{id}/`, `GET /api/v1/projects/sponsor/requests/`, `POST /api/v1/projects/sponsor/requests/{id}/approve/`, `POST /api/v1/projects/sponsor/requests/{id}/reject/`, `POST /api/v1/projects/sponsor/requests/{id}/fund-received/`, `POST /api/v1/projects/{id}/confirm-investors/`, `POST /api/v1/projects/{id}/terminate/`, `GET /api/v1/chat/conversations/{id}/header/`, `POST /api/v1/chat/conversations/{id}/leave/`, `POST /api/v1/chat/conversations/{id}/report/`, `POST /api/v1/users/change-password/`, `POST /api/v1/users/delete-account/`.

5. For EVERY tested endpoint, record:
   - Method, Endpoint URL, Auth requirement / role
   - Actual HTTP status code received (200, 201, 400, 401, 403, 404, 500)
   - Response latency (ms)
   - Actual response body (JSON payload or HTML error page / traceback)
   - Working vs Broken vs Schema Mismatch status
   - An exact, copy-pasteable, executable cURL command with all required headers and body payload.

6. Output Deliverables:
   - Save full raw test log and comprehensive markdown matrix to:
     `d:\Ismail_flutter\julkar_vai\.agents\teamwork\worker_live_probe_1\live_probing_results.md`
   - Write standard handoff report to:
     `d:\Ismail_flutter\julkar_vai\.agents\teamwork\worker_live_probe_1\handoff.md`
   - Send completion message to orchestrator.
