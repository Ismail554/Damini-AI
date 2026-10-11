# Original User Request

## Initial Request — 2026-10-08T05:09:16Z

Conduct a comprehensive end-to-end audit of the entire Braintech Flutter application (d:\Ismail_flutter\julkar_vai), identifying all static/mock data remnants, broken or incomplete UX/navigation flows, missing backend API integrations, and production readiness gaps across both Investor and Sponsor roles.

Working directory: d:\Ismail_flutter\julkar_vai
Integrity mode: development

## Requirements

### R1. Comprehensive Static & Mock Data Audit
Audit all feature modules (lib/views/ and lib/data/) to identify all hardcoded mock lists, placeholder constants, simulated delays (Future.delayed), and stub repositories. Catalog every occurrence with exact file paths and missing backend endpoints.

### R2. End-to-End User Flow & Navigation Verification
Audit all navigation paths across AppRouter (lib/core/routing/app_router.dart), role selection, authentication, onboarding, home dashboard tabs, AI chat, sponsor project creation, and deal flow lifecycle. Ensure no dead-ends, unhandled back button presses, or broken route parameters.

### R3. Backend Integration & API Robustness Audit
Inspect all repositories, providers, and services using ApiService (lib/core/services/api_service.dart) to ensure proper error handling (ApiException, AppException), token expiration / refresh logic, offline resilience, and schema compliance with backend endpoints.

### R4. UX / UI Consistency & Edge Case Audit
Review loading spinners, shimmer effects, empty states, error snackbars (CustomSnackBar), theme compliance (AppThemeColors dark/light modes), responsive scaling (flutter_screenutil), and keyboard overflow handling across all screens.

### R5. Production Readiness & Quality Assurance Report
Generate a detailed action plan and remediation checklist covering code health, static analysis results (dart analyze), unit/widget test coverage, security considerations (credentials in .env, secure storage), and production deployment readiness.

## Acceptance Criteria

### Static Data & Backend Integration
- [ ] Every repository across lib/views/ (Investor, Sponsor, Auth, Profile, Notifications, Chat, AI Chat) is audited for real API integration vs fallback mocks.
- [ ] Any remaining unintegrated endpoints are documented with exact HTTP methods, URLs, request/response JSON contracts.

### Flow & Navigation Integrity
- [ ] All route paths in AppRouter verified against screen invocations and bottom navigation bar tabs.
- [ ] Investor -> Sponsor role switching flow and permissions verified.

### Code Health & Verification
- [ ] dart analyze passes with zero fatal errors or unresolved lint warnings.
- [ ] Automated test suite executed and audited for coverage gaps.
- [ ] Final executive audit report provided with prioritized remediation steps.


## Follow-up — 2026-10-11T05:26:22Z

Perform a comprehensive API and contract audit across all backend endpoints, Flutter client repositories, request payloads, response schemas, and specification documents. Test endpoint behavior with live probes against the running backend and generate an actionable Markdown handover report documenting broken endpoints, contract mismatches, payload discrepancies, and reproduction steps for backend developers.

Working directory: d:\Ismail_flutter\julkar_vai
Integrity mode: development

## Verification Resources
- Active backend base URL: `https://clubby-andy-irksomely.ngrok-free.dev` (from `.env`)
- Flutter endpoints inventory: `lib/core/constants/api_endpoints.dart`
- Client repositories & payload models: `lib/views/**/repositories/`, `lib/data/repositories/`
- Backend specification documents: `project_docs/*.md`, `AI_CHAT_API_SPEC.md`, `INVESTOR_API_SPECIFICATION.md`, `INVESTOR_NEXT_FLOW_API_SPEC.md`, `SOCIAL_AUTH_BACKEND_SPEC.md`

## Requirements

### R1. Endpoint Inventory & Contract Mapping
Catalog every endpoint declared across `lib/core/constants/api_endpoints.dart`, client repository implementations, and backend spec documents in `project_docs/`. For each endpoint, map:
- HTTP method, URL path, and authentication requirement (public, token auth, role-specific: investor/sponsor)
- Client-sent payload fields vs backend-documented fields (including case formatting: snake_case vs camelCase)
- Client-expected response structure vs backend response specification (`status`, `data`, `message`, paginated list, nested objects)

### R2. Live Probing & Error Verification
Perform live HTTP probing against the running backend (`https://clubby-andy-irksomely.ngrok-free.dev`):
- Probe public and unauthenticated endpoints (e.g. banners, industries, public projects, auth endpoints)
- Dynamically register temporary test users or authenticate to test protected endpoints across roles (Investor, Sponsor)
- Capture exact HTTP status codes, headers, response timing, error payloads (400, 401, 403, 404, 500), and unhandled server exceptions (HTML traceback pages, Daphne connection drops)

### R3. Backend Developer Handover Report (`BACKEND_API_AUDIT_REPORT.md`)
Synthesize all findings into a structured, developer-ready Markdown report at `d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md` featuring:
- **Executive Summary & Health Matrix**: Total endpoints tested, count of fully working endpoints, count of broken/failing endpoints, count of contract/schema mismatches
- **Critical Issues & Blockers**: High-priority bugs blocking Flutter app functionality (e.g. 500 errors, missing routes, unhandled exceptions)
- **Per-Module Breakdown**: Grouped by domain (Auth, Onboarding & Profiles, Projects & Discovery, Investments, AI Advisor/Copilot, Chat/WebSockets, Notifications):
  - Endpoint URL & Method
  - Current Status (Working / Broken / Schema Mismatch / Unimplemented)
  - Reproduction cURL command with exact headers and payload
  - Expected Behavior vs Actual Received Response (status code and JSON body)
  - Specific discrepancy details (e.g. missing fields, type errors, null safety traps)
  - Recommended backend fix
- **Payload & Response Schema Diff Table**: Concrete before/after JSON comparisons for any mismatched fields

## Acceptance Criteria

### Audit Scope & Verification
- [ ] Every endpoint in `ApiEndpoints` is audited and accounted for in the report.
- [ ] Every failing or mismatched endpoint includes an executable, copy-pasteable reproduction cURL command.
- [ ] Actual live response bodies and HTTP status codes from `https://clubby-andy-irksomely.ngrok-free.dev` are captured and documented for verified endpoints.
- [ ] Discrepancies between Flutter repository models and backend specs are explicitly itemized with field-level diffs.
- [ ] Complete report is saved to `d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md` and formatted cleanly for direct handover to the backend team.
