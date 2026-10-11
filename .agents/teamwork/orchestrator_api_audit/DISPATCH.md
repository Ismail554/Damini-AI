# Dispatch Log

## 2026-10-11T05:28:05Z
You are the Project Orchestrator for the Braintech API and Contract Audit project.

## Your Identity & Workspace
- Identity: Project Orchestrator
- Working directory: d:\Ismail_flutter\julkar_vai\.agents\teamwork\orchestrator_api_audit\
- Project root: d:\Ismail_flutter\julkar_vai
- Authoritative User Request: d:\Ismail_flutter\julkar_vai\.agents\teamwork\ORIGINAL_REQUEST.md (under header `## Follow-up — 2026-10-11T05:26:22Z`)

## Mission & Scope
Perform a comprehensive API and contract audit across all backend endpoints, Flutter client repositories, request payloads, response schemas, and specification documents. Test endpoint behavior with live probes against the running backend and generate an actionable Markdown handover report documenting broken endpoints, contract mismatches, payload discrepancies, and reproduction steps for backend developers.

## Verification Resources
- Active backend base URL: `https://clubby-andy-irksomely.ngrok-free.dev` (from `.env`)
- Flutter endpoints inventory: `lib/core/constants/api_endpoints.dart`
- Client repositories & payload models: `lib/views/**/repositories/`, `lib/data/repositories/`
- Backend specification documents: `project_docs/*.md`, `AI_CHAT_API_SPEC.md`, `INVESTOR_API_SPECIFICATION.md`, `INVESTOR_NEXT_FLOW_API_SPEC.md`, `SOCIAL_AUTH_BACKEND_SPEC.md`

## Requirements to Execute
1. **R1. Endpoint Inventory & Contract Mapping**:
   Catalog every endpoint declared across `lib/core/constants/api_endpoints.dart`, client repository implementations, and backend spec documents in `project_docs/`. Map method, URL, auth requirement, client payload vs backend doc fields, client expected response vs backend response spec.
2. **R2. Live Probing & Error Verification**:
   Perform live HTTP probing against `https://clubby-andy-irksomely.ngrok-free.dev`. Probe public/unauthenticated endpoints, register/auth test users across Investor and Sponsor roles to probe protected endpoints. Capture exact HTTP status codes, headers, response timing, error payloads (400, 401, 403, 404, 500), and unhandled server exceptions.
3. **R3. Backend Developer Handover Report**:
   Synthesize all findings into `d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md` featuring:
   - Executive Summary & Health Matrix (total tested, working, broken/failing, schema mismatches)
   - Critical Issues & Blockers (500 errors, missing routes, unhandled exceptions)
   - Per-Module Breakdown (Auth, Onboarding & Profiles, Projects & Discovery, Investments, AI Advisor/Copilot, Chat/WebSockets, Notifications) with reproduction cURL, expected vs actual response, discrepancy details, and recommended backend fix
   - Payload & Response Schema Diff Table (concrete before/after JSON comparisons)

## Acceptance Criteria
- Every endpoint in `ApiEndpoints` is audited and accounted for in the report.
- Every failing or mismatched endpoint includes an executable, copy-pasteable reproduction cURL command.
- Actual live response bodies and HTTP status codes from `https://clubby-andy-irksomely.ngrok-free.dev` are captured and documented.
- Discrepancies between Flutter repository models and backend specs are explicitly itemized with field-level diffs.
- Complete report is saved to `d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md`.
