# Handoff Report — Endpoint Inventory Parity Verification

## 1. Observation

### Observation 1: Total Declarations in `lib/core/constants/api_endpoints.dart`
An AST parse of `lib/core/constants/api_endpoints.dart` reveals exactly **65 member declarations** in `ApiEndpoints`:
- **1 Getter:** `static String get baseUrl` (lines 4–12)
- **36 Constant Strings:**
  - `register` (line 13: `"/api/v1/auth/register/"`)
  - `verifyOtp` (line 14: `"/api/v1/auth/verify-otp/"`)
  - `resendOtp` (line 15: `"/api/v1/auth/resend-otp/"`)
  - `refreshToken` (line 16: `"/api/v1/auth/token/refresh/"`)
  - `login` (line 17: `"/api/v1/auth/login/"`)
  - `logout` (line 18: `"/api/v1/auth/logout/"`)
  - `googleLogin` (line 19: `"/api/v1/auth/google/"`)
  - `appleLogin` (line 20: `"/api/v1/auth/apple/"`)
  - `forgotPassword` (line 21: `"/api/v1/auth/forgot-password/"`)
  - `resetPassword` (line 22: `"/api/v1/auth/reset-password/"`)
  - `changePassword` (line 23: `"/api/v1/users/change-password/"`)
  - `setRole` (line 26: `"/api/v1/profiles/set-role/"`)
  - `switchRole` (line 27: `"/api/v1/users/switch-role/"`)
  - `verificationDocuments` (line 30: `"/api/v1/profiles/verification-documents/"`)
  - `industries` (line 32: `"/api/v1/profiles/industries/"`)
  - `verificationStatus` (line 33: `"/api/v1/profiles/verification-status/"`)
  - `currentUser` (line 41: `"/api/v1/users/me/"`)
  - `deleteAccount` (line 42: `"/api/v1/users/delete-account/"`)
  - `sponsorNda` (line 43: `"/api/v1/profiles/sponsor/nda/"`)
  - `sponsorProjects` (line 44: `"/api/v1/projects/sponsor/"`)
  - `savedProjects` (line 45: `"/api/v1/projects/saved/"`)
  - `savedProfiles` (line 46: `"/api/v1/profiles/saved/"`)
  - `sponsorCollaborationRequests` (line 49: `"/api/v1/projects/sponsor/requests/"`)
  - `banners` (line 59: `"/api/v1/banners/"`)
  - `projects` (line 60: `"/api/v1/projects/"`)
  - `discoverProjects` (line 61: `"/api/v1/projects/discover/"`)
  - `investorInvestments` (line 62: `"/api/v1/investor/investments/"`)
  - `aiProjectConversations` (line 73: `"/api/v1/ai/projects/conversations/"`)
  - `aiChatInitial` (line 81: `"/api/v1/ai/chat/initial/"`)
  - `startConversation` (line 88: `"/api/v1/notifications/chat/conversations/start/"`)
  - `conversations` (line 90: `"/api/v1/notifications/chat/conversations/"`)
  - `chatUpload` (line 94: `"/api/v1/notifications/chat/upload/"`)
  - `getNotifications` (line 115: `"/api/v1/notifications/"`)
  - `markAllRead` (line 117: `"/api/v1/notifications/mark-all-read/"`)
  - `deviceToken` (line 118: `"/api/v1/notifications/device-token/"`)
  - `clearAllNotifications` (line 120: `"/api/v1/notifications/clear-all/"`)
- **28 Dynamic Methods:**
  - `onboarding(role)` (line 28)
  - `profileByRole(role)` (line 37)
  - `saveProfile(userId)` (line 47)
  - `userPublicProfile(userId)` (line 48)
  - `sponsorProjectRequests(id)` (line 51)
  - `approveCollaborationRequest(id)` (line 53)
  - `rejectCollaborationRequest(id)` (line 55)
  - `fundReceivedCollaborationRequest(id)` (line 57)
  - `projectDetails(id)` (line 63)
  - `saveProject(id)` (line 64)
  - `signNda(id)` (line 65)
  - `createCollaborationRequest(id)` (line 66)
  - `confirmInvestors(projectId)` (line 68)
  - `terminateProject(id)` (line 70)
  - `aiProjectMessages(conversationId)` (line 75)
  - `aiProjectConversation(conversationId)` (line 77)
  - `aiChatMessages(conversationId)` (line 82)
  - `aiChatClear(conversationId)` (line 84)
  - `conversationMessages(conversationId)` (line 92)
  - `markConversationRead(conversationId)` (line 96)
  - `removeParticipant(conversationId, userId)` (line 98)
  - `conversationHeader(conversationId)` (line 100)
  - `conversationConfirmInvestors(conversationId)` (line 102)
  - `leaveConversation(conversationId)` (line 104)
  - `reportConversation(conversationId)` (line 106)
  - `chatWebSocket(conversationId, token)` (line 109)
  - `markRead(id)` (line 116)
  - `deleteNotification(id)` (line 119)

### Observation 2: Report Coverage Parity Verification Command
The empirical test script `test/verify_parity_runner.py` was executed:
```bash
python test/verify_parity_runner.py
```
**Tool Execution Result:** Exited with code 0.
- Total declarations extracted: `65`
- Total successfully verified in `BACKEND_API_AUDIT_REPORT.md`: `65`
- Total missing from audit report: `0`
- Verbatim stdout:
  ```
  SUCCESS: 100% of ApiEndpoints constants & methods are accounted for!
  ```
The machine-readable inventory was exported to `test/parity_verification_results.json`.

### Observation 3: Orphaned Status of `discoverProjects`
Command executed:
```bash
git grep 'discoverProjects'
```
**Output:**
```
lib/core/constants/api_endpoints.dart:  static const String discoverProjects = "/api/v1/projects/discover/";
```
Command executed:
```bash
git grep 'projects/discover' lib/
```
**Output:**
```
lib/core/constants/api_endpoints.dart:  static const String discoverProjects = "/api/v1/projects/discover/";
```
In `lib/views/investor/discover/repositories/discover_repository.dart` (lines 67–70):
```dart
final response = await _apiService.get(
  ApiEndpoints.projects,
  requireAuth: true,
);
```
`DiscoverRepositoryImpl` calls `ApiEndpoints.projects` (`/api/v1/projects/`), NEVER `ApiEndpoints.discoverProjects`.

### Observation 4: Verification of 12 Mock Fallback Repositories
Direct source code inspection of all 12 repositories reported in Issue 8 of `BACKEND_API_AUDIT_REPORT.md`:

1. **`InvestmentHistoryRepositoryImpl`** (`lib/views/investor/investment_history/repositories/investment_history_repository.dart`):
   - Lines 76–144: In `catch (_) {}`, silently falls back to 4 hardcoded fake investments (`inv_hist_1` to `inv_hist_4`) and a fake portfolio summary (`totalInvested: "$560,000"`).
2. **`InvestorDashboardRepositoryImpl`** (`lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart`):
   - Lines 94–100: Falls back to 5 hardcoded category items.
   - Lines 169–200: Falls back to 3 fake banners on `banners` error.
   - Lines 248–285: Falls back to 4 fake featured opportunities.
   - Lines 328–365: Falls back to fake trending projects.
3. **`DiscoverRepositoryImpl`** (`lib/views/investor/discover/repositories/discover_repository.dart`):
   - Lines 54–60: Falls back to 5 fake categories.
   - Lines 108–241: Falls back to 8 hardcoded mock deals (`deal_trending_1`..`3`, `deal_1`..`5`).
4. **`InvestorSavedRepositoryImpl`** (`lib/views/investor/saved/repositories/investor_saved_repository.dart`):
   - Lines 67–121: Falls back to 4 hardcoded fake saved projects (`inv_saved_1`..`4`).
5. **`InvestorChatRepositoryImpl`** (`lib/views/investor/chat/repositories/investor_chat_repository.dart`):
   - Lines 61–91: Falls back to 3 hardcoded fake chats (`chat_1`..`3`).
6. **`ChatRepository`** (`lib/views/sponsor/chat/repositories/chat_repository.dart`):
   - Lines 107–162: Contains `fetchChats()` returning 5 hardcoded fake sponsor chats (`ahmad_1`, `dth_1`, etc.).
   - Lines 164–210: Contains `fetchMessagesForChat()` returning hardcoded mock messages (`msg_1`..`4`).
7. **`NdaRepository`** (`lib/views/sponsor/nda/repositories/nda_repository.dart`):
   - Lines 42–45: `catch (_) { return NdaAgreementModel.mockData(disclosingParty); }`.
   - Lines 105–111: `submitSignature(...) async => true` (stub).
8. **`ProjectPublicRepository`** (`lib/views/sponsor/public_view/repositories/project_public_repository.dart`):
   - Line 93: `catch (_) { ... return ProjectPublicViewModel.mockData(); }`.
9. **`SponsorProfileRepository`** (`lib/views/sponsor/profile/repositories/sponsor_profile_repository.dart`):
   - Lines 42–50: `catch (_) { return const SponsorProfileData(name: "Member", title: "Sponsor Partner", ...); }`.
10. **`OpportunityRepositoryImpl`** (`lib/data/repositories/opportunity_repository.dart`):
    - Lines 13–66: Static `_mockOpportunities` array.
    - Line 77: `await Future.delayed(const Duration(milliseconds: 800));` with 0 network calls.
11. **`HomeRepositoryImpl`** (`lib/views/home/repositories/home_repository.dart`):
    - Lines 5–10: Pure stub returning `0` unread notification count.
12. **`GroupChatRepositoryImpl`** (`lib/views/sponsor/group_chat/repositories/group_chat_repository.dart`):
    - Lines 9–37: Pure stub returning `const []` for initial messages and suggestions, and local synthetic `GroupChatMessage` on send.

---

## 2. Logic Chain

1. **Premise 1:** The Flutter client's entire API contract surface is defined in `lib/core/constants/api_endpoints.dart`. An audit report claiming comprehensive coverage must account for every member of this class.
2. **Step 1 (AST Extraction):** We parsed `api_endpoints.dart` into 1 getter, 36 constants, and 28 methods (total 65 members).
3. **Step 2 (Report Verification):** Running `test/verify_parity_runner.py` proved that each of the 65 declarations is explicitly audited and discussed across Sections 3, 4, 5, and 6 of `BACKEND_API_AUDIT_REPORT.md` (0 omissions).
4. **Step 3 (Orphan Verification):** `discoverProjects` was claimed to be orphaned in Section 3.3 (line 941) and Section 6.2 (line 1703). Searching the repository confirmed zero usages outside `api_endpoints.dart:61`. `DiscoverRepositoryImpl` was proven to use `ApiEndpoints.projects` instead. Therefore, the claim that `discoverProjects` is orphaned is verified.
5. **Step 4 (Mock Fallback Verification):** Section 3, Issue 8 cataloged 12 specific repositories as containing silent mock fallbacks or stubs. Step-by-step source code inspection confirmed that all 12 repositories contain hardcoded mock data, silent catch blocks, simulated delays, or stubs.
6. **Conclusion:** All audited claims regarding inventory parity, orphaned routes, and mock fallback repositories in `BACKEND_API_AUDIT_REPORT.md` are empirically verified and accurate.

---

## 3. Caveats

- **Network Runtime Re-Probing:** This subagent did not issue fresh live HTTP requests against ngrok during this parity turn, relying on the live probe logs and response bodies documented in `BACKEND_API_AUDIT_REPORT.md`. Static code analysis and repository inspection were executed directly on local files.
- **Permission Check Note:** A secondary `flutter test` command invocation was stopped by a user permission prompt; however, the primary verification was completed and fully validated via the Python AST verification harness (`test/verify_parity_runner.py`), resulting in exit code 0 and full JSON verification output.

---

## 4. Conclusion

**Verdict: APPROVE**

- **Inventory Parity:** 65 of 65 `ApiEndpoints` members accounted for in `BACKEND_API_AUDIT_REPORT.md` (100% parity, 0 missing).
- **Orphan Status:** `discoverProjects` is confirmed 100% orphaned (0 callers in codebase).
- **Mock Fallback Accuracy:** All 12 reported client repositories genuinely contain mock data fallbacks, fake data models, or stubs.

---

## 5. Verification Method

To independently verify these findings:

1. **Run the Parity Runner:**
   ```powershell
   python test/verify_parity_runner.py
   ```
   *Expected result:* Exits with code 0, reporting `SUCCESS: 100% of ApiEndpoints constants & methods are accounted for!`.

2. **Inspect the JSON Parity Matrix:**
   Open `test/parity_verification_results.json` to inspect the 65 items with line references into `BACKEND_API_AUDIT_REPORT.md`.

3. **Verify Orphan Status:**
   ```powershell
   git grep 'discoverProjects'
   ```
   *Expected result:* Exactly 1 match in `lib/core/constants/api_endpoints.dart`.

4. **Verify Mock Fallbacks:**
   Inspect `lib/views/investor/investment_history/repositories/investment_history_repository.dart:76-144` and `lib/data/repositories/opportunity_repository.dart:13-77`.
