## 2026-10-08T05:31:51Z
You are Survey Explorer 1 (Data & API Layer Auditor).
Your working directory is: d:\Ismail_flutter\julkar_vai\.agents\teamwork\teamwork_preview_explorer_survey_1\
Your identity: Survey Explorer 1

MANDATORY FIRST STEP:
Read the authoritative user request at:
d:\Ismail_flutter\julkar_vai\.agents\teamwork\ORIGINAL_REQUEST.md
Also read the project architecture at:
d:\Ismail_flutter\julkar_vai\.agents\teamwork\PROJECT.md

TASK:
Conduct a comprehensive static & mock data audit (R1) and backend integration & API robustness audit (R3) across the Braintech Flutter application (d:\Ismail_flutter\julkar_vai).

INVESTIGATION SCOPE:
1. Inspect lib/data/ (all repositories, models, data sources, mock files).
2. Inspect lib/core/services/api_service.dart, network configuration, constants, interceptors.
3. Inspect all feature modules in lib/views/ (Investor, Sponsor, Auth, Profile, Notifications, Chat, AI Chat) and their associated controllers/providers/viewmodels.

CRITICAL DELIVERABLES:
1. Search and identify every hardcoded mock list, placeholder constant, Future.delayed, and stub repository.
2. Note exact file paths, line numbers, variable/function names.
3. Classify each occurrence:
   - Pure Mock (no backend endpoint integrated, purely local static data)
   - Fallback Mock (tries API call, catches error, falls back to hardcoded list/map)
   - Stub Service/Repository (returns simulated data with or without Future.delayed)
4. Inspect ApiService usage and error robustness:
   - Check error handling (ApiException, AppException, DioException / HTTP status code handling).
   - Check token expiration, refresh logic, and Authorization header injection.
   - Check offline resilience, network connectivity checks, and user-facing error messages.
5. Comprehensive Missing Endpoints Catalog:
   For EVERY unintegrated or mock-backed feature, document:
   - Feature name and Screen/View path
   - Exact HTTP method (GET, POST, PUT, PATCH, DELETE)
   - Exact URL path (e.g., /api/v1/investor/deals)
   - Request JSON payload schema (parameters, types, mandatory/optional)
   - Response JSON schema (success status, pagination, data structures)

Write your full, detailed report to:
d:\Ismail_flutter\julkar_vai\.agents\teamwork\teamwork_preview_explorer_survey_1\handoff.md
Update your progress.md regularly in your working directory.
When finished, send a message to the orchestrator summarizing key findings and providing the handoff report path.
