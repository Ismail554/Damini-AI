# Handoff Report: Flutter Client API Surface Survey

**Agent**: `explorer_client_survey_1`  
**Date**: 2026-10-11  
**Working Directory**: `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_client_survey_1\`  
**Handoff Type**: Hard (Task Complete)

---

## 1. Observation

1. **`ApiEndpoints` Inventory**:
   - `lib/core/constants/api_endpoints.dart` defines 65 total members:
     - 1 dynamic `baseUrl` getter (line 4-12) evaluating `dotenv.env['BASE_URL']` with fallback `"https://clubby-andy-irksomely.ngrok-free.dev"`.
     - 44 static constant string endpoints (`static const String ...`).
     - 19 static arrow functions parameterized by IDs or roles (`static String ...(...) => ...`).
     - 1 static block function `chatWebSocket` (line 109-114) producing a WebSocket connection URI.
   - All 65 declarations and their paths have been itemized in `client_api_inventory.md`.

2. **Endpoint Usage & Call Sites**:
   - 60 of the 61 non-base endpoint definitions have active call sites in the Flutter codebase.
   - Exactly **1 endpoint is completely orphaned**:
     - `ApiEndpoints.discoverProjects` (`/api/v1/projects/discover/`, line 61): 0 references across the entire codebase.
     - In `lib/views/investor/discover/repositories/discover_repository.dart:68`, `DiscoverRepositoryImpl.getDiscoverDeals` calls `ApiEndpoints.projects` (`/api/v1/projects/`) instead of `discoverProjects`.
   - **3 endpoints are invoked strictly outside the repository layer**:
     - `ApiEndpoints.refreshToken` (`/api/v1/auth/token/refresh/`): Called exclusively in `AuthInterceptor._refreshToken` at `lib/core/services/auth_interceptor.dart:134`.
     - `ApiEndpoints.logout` (`/api/v1/auth/logout/`): Called exclusively in `SessionProvider.logout` at `lib/views/auth/session/controllers/session_provider.dart:109`.
     - `ApiEndpoints.chatWebSocket`: Called exclusively in `ChatWebSocketService.connect` at `lib/core/services/chat_websocket_service.dart:40`.

3. **Mock Data Remnants & Stub Repositories**:
   - `lib/data/repositories/opportunity_repository.dart:10-105`: `OpportunityRepositoryImpl` contains 0 network calls. It serves `_mockOpportunities` through `Future.delayed(Duration(milliseconds: 800))` with local `SharedPreferences` persistence.
   - `lib/views/home/repositories/home_repository.dart:5-10`: `HomeRepositoryImpl.getUnreadNotificationCount` is a stub returning hardcoded `0`.
   - `lib/views/sponsor/group_chat/repositories/group_chat_repository.dart:9-37`: `GroupChatRepositoryImpl` returns hardcoded `const []` for initial messages and AI suggestions, and instantiates local synthetic messages without backend synchronization.
   - `lib/views/sponsor/nda/repositories/nda_repository.dart:42-45, 105-111`: `fetchSponsorNda()` falls back to `NdaAgreementModel.mockData()` on error. `submitSignature()` unconditionally returns `true` without executing an HTTP request.
   - `lib/views/sponsor/public_view/repositories/project_public_repository.dart:61-94`: If `id` starts with `'pub_'` or `'draft_'` or if network retrieval fails, returns `ProjectPublicViewModel.mockData()`.
   - `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart:94-100, 169-200, 248-285, 333-364`: Every getter (`getCategories`, `getBanners`, `getFeaturedOpportunities`, `getTrendingProjects`) catches exceptions and falls back to hardcoded mock lists.
   - `lib/views/investor/discover/repositories/discover_repository.dart:54-60, 108-140`: Falls back to 5 mock deals (`deal_trending_1`..`5`) and 5 mock categories.
   - `lib/views/investor/investment_history/repositories/investment_history_repository.dart:79-120`: Falls back to mock portfolio summary (`$560,000`, etc.) and 4 mock investment records (`inv_hist_1`..`4`).
   - `lib/views/investor/saved/repositories/investor_saved_repository.dart:67-120`: Falls back to 4 mock saved projects (`inv_saved_1`..`4`).
   - `lib/views/investor/chat/repositories/investor_chat_repository.dart:61-90`: Falls back to 3 mock conversations (`chat_1`..`3`).
   - `lib/views/sponsor/chat/repositories/chat_repository.dart:107-140, 201-210`: Methods `fetchChats()` and `fetchChatMessages()` bypass the network entirely, returning hardcoded mock lists (`ahmad_1`, `dth_1`, `marcus_1`, `elena_1`, and `msg_default_1`).

---

## 2. Logic Chain

1. **Premise 1**: All endpoint constant declarations in `lib/core/constants/api_endpoints.dart` define the intended client API contract.
2. **Premise 2**: A comprehensive search across all 38 repositories, controllers, services, and interceptors reveals exact usage, payload construction, header requirements, and unwrapping patterns.
3. **Step 1**: Parsing `api_endpoints.dart` identified 65 declarations representing 53 distinct URI paths.
4. **Step 2**: Cross-referencing against the entire `lib/` tree identified that `ApiEndpoints.discoverProjects` (`/api/v1/projects/discover/`) is never referenced. Comparing this with `DiscoverRepositoryImpl` showed that the repository calls `ApiEndpoints.projects` (`/api/v1/projects/`), creating an orphaned route in the constant class.
5. **Step 3**: Examining repository catch blocks and implementation bodies revealed two classes of mock remnants:
   - *Fallback on failure*: Repositories attempt network calls, but catch blocks swallow errors and return hardcoded lists rather than surfacing network or contract failures to the UI layer (masking backend 404/500 errors).
   - *Hardcoded stubs*: Repositories never initiate HTTP requests (`OpportunityRepositoryImpl`, `HomeRepositoryImpl`, `GroupChatRepositoryImpl`, and portions of `ChatRepository`).
6. **Step 4**: Itemizing request payloads revealed significant disparities in formatting:
   - Some models use JSON (`toJson()`), e.g., `SignupRequestModel`, `LoginRequestModel`, `OtpVerificationRequestModel`.
   - Others use multipart `FormData`, e.g., `CreateProjectRequestModel.toFormData()` which formats numbers with 2 decimals, formats categories as indexed keys (`category_ids[0]`), and uploads `cover_image`.
   - Role onboarding endpoints dynamically switch payloads based on whether role is `'investor'` or `'sponsor'` (e.g. `company_name` vs `legal_company_name`).

---

## 3. Caveats

1. **Runtime Verification**: This audit is a static code survey of the Flutter client. It does not probe live endpoints or verify if the backend currently accepts the client's payload formatting (e.g., indexed `category_ids[0]` in `FormData`).
2. **Third-Party Integrations**: Firebase FCM device token registration and Google/Apple OAuth token acquisition depend on native platform configurations that were not verified at runtime.
3. **WebSockets**: The WebSocket connection URL builder in `ApiEndpoints.chatWebSocket` assumes an ngrok / Daphne server supporting WS upgrade; protocol compatibility was verified from client code only.

---

## 4. Conclusion

The Flutter client's API surface is comprehensively cataloged in `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_client_survey_1\client_api_inventory.md`. 

Key takeaways:
- Exactly 1 orphaned endpoint exists (`ApiEndpoints.discoverProjects`).
- 3 endpoints operate outside repositories (`refreshToken`, `logout`, `chatWebSocket`).
- 12 repositories contain mock data fallbacks, stub methods, or simulated delays.
- A critical UI masking risk exists: because multiple repositories (`investor_dashboard_repository`, `discover_repository`, `investment_history_repository`, `investor_saved_repository`, `investor_chat_repository`, `nda_repository`) swallow network errors and return mock lists, backend bugs or broken contracts often present as "working" mock data in the app UI rather than triggering error states.

---

## 5. Verification Method

To verify these findings:

1. **Verify Orphaned Endpoint**:
   Inspect grep search results for `ApiEndpoints.discoverProjects`:
   ```powershell
   Select-String -Path (Get-ChildItem -Path lib -Recurse -Filter *.dart) -Pattern "discoverProjects"
   ```
   *Expected output*: Only matches line 61 in `lib/core/constants/api_endpoints.dart`.

2. **Verify Mock Fallbacks**:
   Inspect the following files:
   - `lib/views/investor/investment_history/repositories/investment_history_repository.dart:79-86`
   - `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart:169-200, 248-285, 333-364`
   - `lib/views/investor/discover/repositories/discover_repository.dart:108-140`
   - `lib/views/investor/saved/repositories/investor_saved_repository.dart:67-120`
   - `lib/data/repositories/opportunity_repository.dart:13-66`
   - `lib/views/sponsor/chat/repositories/chat_repository.dart:107-140`

3. **Verify Survey Output**:
   Inspect `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_client_survey_1\client_api_inventory.md`.
