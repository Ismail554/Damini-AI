# Technical Review Report: Contract Diffs, Reproduction cURLs & Backend Fixes
**Target Document:** `d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md`  
**Reviewer:** `reviewer_contract_1` (Subagent Teamwork Fleet — Reviewer & Adversarial Critic)  
**Date:** October 11, 2026  
**Verdict:** **REQUEST_CHANGES**

---

## 1. Observation

### 1.1 Live Probing & Reproduction cURLs
Direct inspection of all 64 reproduction cURL commands in `BACKEND_API_AUDIT_REPORT.md` revealed:
- **Header Compliance:** Every single cURL command (100%) includes the required header `-H "ngrok-skip-browser-warning: 69420"`.
- **Authorization Compliance:** Every protected endpoint correctly specifies `-H "Authorization: Bearer <TOKEN>"` (or `<INVESTOR_TOKEN>` / `<SPONSOR_TOKEN>` / `<VALID_USER_TOKEN>`).
- **Media Type & Multipart:** JSON-bearing endpoints specify `-H "Content-Type: application/json"`. Multipart endpoints (verification documents, NDA attachments, chat voice notes) use `-F` flags without conflicting `Content-Type` headers, enabling curl to generate correct multipart boundaries.
- **Windows Shell Execution Incompatibility:** The commands use `curl.exe` with POSIX/bash line continuations (`\`) and single-quoted JSON bodies (`-d '{"key":"value"}'`). On Windows PowerShell, the backslash `\` is not a continuation character (PowerShell uses backtick `` ` ``), and in Windows `cmd.exe`, single quotes are treated as literal characters, causing syntax errors if pasted directly into native Windows shells.

### 1.2 Inspection of Payload & Schema Diff Table (Section 5, Table 5) vs. Actual Flutter Codebase
Direct inspection of Flutter models in `lib/` revealed discrepancies between what `BACKEND_API_AUDIT_REPORT.md` claims the Flutter client sends vs. what the Flutter codebase actually implements:

1. **`target_return` vs `target_roi` & `project_duration_months` vs `timeline_months`:**
   - *Report Claim (Table 5, lines 1659-1661; Section 6.2, line 1698):*
     Claims Flutter client sends `target_return: 18.5` and `project_duration_months: 24`, causing 400 Bad Request, and instructs developers:
     `"Send target_roi instead of target_return, timeline_months instead of project_duration_months, require short_description, and serialize via dio.FormData"`.
   - *Actual Codebase Observation:*
     In `lib/views/sponsor/create_project/models/create_project_models.dart:54-76`:
     ```dart
     final Map<String, dynamic> map = {
       'title': title.trim(),
       'short_description': shortDescription.trim(),
       'business_description': businessDescription.trim(),
       'funding_goal': fundingGoal.toStringAsFixed(2),
       'minimum_investment': minimumInvestment.toStringAsFixed(2),
       'target_roi': targetRoi.toStringAsFixed(2),
       'country': country.trim(),
       'location': location.trim(),
       'funding_stage': fundingStage.trim(),
       'timeline_months': timelineMonths.toString(),
       ...
     };
     return FormData.fromMap(map);
     ```
     In `lib/views/sponsor/create_project/repositories/create_project_repository.dart:22-25`:
     ```dart
     final formData = await request.toFormData();
     final response = await _apiService.post(
       ApiEndpoints.sponsorProjects,
       data: formData,
       requireAuth: true,
     );
     ```
     **Direct Fact:** The Flutter client ALREADY sends `target_roi`, `timeline_months`, and `short_description`, and ALREADY serializes them using `FormData`. The keys `target_return` and `project_duration_months` do not exist anywhere in `lib/`. They were introduced by the synthetic probe runner in `worker_live_probe_1/probe_runner.py:864`.

2. **`otp` vs `code` in Password Reset:**
   - *Report Claim (Table 5, line 1662; Section 6.2, line 1699):*
     Claims Flutter client sends `otp: "123456"`, causing 400 Bad Request, and instructs:
     `"Update request JSON map to send code: otpValue"`.
   - *Actual Codebase Observation:*
     In `lib/views/auth/reset_password/models/reset_password_model.dart:14-19`:
     ```dart
     Map<String, dynamic> toJson() => {
       'email': email,
       'code': code,
       'new_password': newPassword,
       'confirm_password': confirmPassword,
     };
     ```
     In `lib/views/auth/otp/models/otp_model.dart:12-17`:
     ```dart
     Map<String, dynamic> toJson() {
       return {
         'email': email.trim(),
         'code': code.trim(),
       };
     }
     ```
     **Direct Fact:** The Flutter client ALREADY sends `code`. It never sends `otp`.

3. **Sponsor NDA `custom_clauses` & Multipart:**
   - *Report Claim (Table 5, lines 1663-1664):*
     Claims Flutter client sends `application/json` and plain string `"Delaware law"`.
   - *Actual Codebase Observation:*
     In `lib/views/sponsor/nda/repositories/nda_repository.dart:65-77`:
     ```dart
     if (customClauses != null && customClauses.isNotEmpty) {
       map['custom_clauses'] = jsonEncode(customClauses);
     }
     ...
     final formData = FormData.fromMap(map);
     final response = await _apiService.post(
       ApiEndpoints.sponsorNda,
       data: formData,
       requireAuth: true,
     );
     ```
     **Direct Fact:** `NdaRepository` ALREADY uses `jsonEncode(customClauses)` and ALREADY sends `FormData`.

4. **Genuine Flutter Contract Discrepancies Confirmed:**
   - `lib/core/constants/api_endpoints.dart:62`:
     `static const String investorInvestments = "/api/v1/investor/investments/";`
     Causes live HTTP 404. Backend route is `/api/v1/projects/investor/investments/` (200 OK). Verified.
   - `lib/core/constants/api_endpoints.dart:28`:
     `static String onboarding(String role) => "/api/v1/profiles/${role.toLowerCase()}/onboarding/";`
     Produces `/api/v1/profiles/sponsor/onboarding/`, returning 404. Backend route is `PATCH /api/v1/profiles/sponsor/`. Verified.
   - `lib/views/sponsor/nda/repositories/sign_nda_repository.dart:44-51`:
     When `signatureImagePath == null`, sends plain JSON map `payload = {'digital_signature': digitalSignature};`, which triggers backend `415 Unsupported Media Type` because view requires multipart parser. Verified.

### 1.3 Recommended Backend Fixes for Django REST Framework (DRF)
- **Change Password Unhandled 500 (Issue 1 & Table 6.1):** Recommends validating `user.check_password(current_password)` in the serializer and raising `serializers.ValidationError({"current_password": ["Current password is incorrect."]})`.
- **Damini AI Wizard Crash (Issue 2 & Table 6.1):** Recommends decoupling conversation session allocation from immediate external LLM completion, wrapping LLM initialization in try/except.
- **Group Chat Confirm Investors 500 Crash (Issue 3 & Table 6.1):** Recommends serializer list validation for `investors` and wrapping Django Channels group broadcast in try/except.
- **Multipart 415 Rejections (Issue 7 & Table 6.1):** Recommends adding `rest_framework.parsers.JSONParser` to `parser_classes = [MultiPartParser, FormParser, JSONParser]`.
- **Password Reset Code Alias (Table 6.1):** Recommends accepting both `code` and `otp` in serializer `to_internal_value()`.
- **Role Switching Idempotency (Table 6.1):** Recommends returning current `data: {access: ..., refresh: ...}` even when the user is already in the requested role.
- **Synchronous SMTP Latency (Section 1.3 & Table 6.1):** Recommends moving `send_mail` calls to Celery tasks.

---

## 2. Logic Chain

1. **Reproduction cURLs Evaluation:**
   - Observed that all cURLs contain necessary authentication tokens and ngrok bypass headers.
   - Observed that Windows bash line continuations (`\`) fail when pasted into Windows PowerShell.
   - *Inference:* The cURLs are syntactically valid in bash/sh environments, but require a documented execution note for Windows PowerShell / cmd developers.

2. **Schema Diff Accuracy Evaluation:**
   - Observed that `probe_runner.py` sent synthetic test probes with `target_return`, `project_duration_months`, and `otp`.
   - Observed that the probe runner's notes recorded: *"Flutter client sends target_return..."*.
   - Observed that `BACKEND_API_AUDIT_REPORT.md` transferred this statement directly into Table 5 and Table 6.2 as client defects requiring P0/P1 fixes.
   - Observed by direct inspection of `create_project_models.dart`, `create_project_repository.dart`, and `reset_password_model.dart` that the client ALREADY sends `target_roi`, `timeline_months`, `short_description`, `FormData`, and `code`.
   - *Inference:* The report misattributes the probing script's own probe payloads as client codebase errors. If delivered as-is, Flutter developers will attempt to remediate code that is already correct, causing confusion and regression risks.

3. **DRF Soundness Evaluation:**
   - DRF serializers map `serializers.ValidationError` directly to standard HTTP 400 Bad Request responses.
   - Adding `JSONParser` to `parser_classes` alongside `MultiPartParser` and `FormParser` is the standard DRF pattern for dual-mode endpoints.
   - Moving blocking I/O (SMTP) to background task queues (Celery) is standard Django best practice.
   - *Inference:* All recommended backend fixes are technically sound, idiomatic, and directly remediate the server defects.

---

## 3. Caveats

1. Direct live probing commands via terminal tool were denied by environment security policy; live response verification was conducted through direct review of raw live probe logs (`worker_live_probe_1/probe_results_raw.json`), which recorded full HTTP status codes, latency, and verbatim JSON responses.
2. The staging server environment has `DEBUG = True` active. While this allows traceback visibility, it also means some 500 errors may manifest differently in production if custom exception handlers are not configured.

---

## 4. Conclusion & Gate Verdict

**Gate Verdict:** **REQUEST_CHANGES**

### Findings Summary:

- **Finding 1 [Major — Fact Discrepancy]:** Table 5 and Table 6.2 incorrectly assert that `CreateProjectRequestModel` sends `target_return` and `project_duration_months`. The client already sends `target_roi`, `timeline_months`, and `short_description` as `FormData`. Update Table 5 and Table 6.2 to reflect that this is a **Backend Schema Requirement verified via probe**, while the Flutter client model is already compliant.
- **Finding 2 [Major — Fact Discrepancy]:** Table 5 and Table 6.2 assert that `ResetPasswordRequestModel` sends `otp` instead of `code`. The client already sends `code`. Update Table 5 and Table 6.2 accordingly.
- **Finding 3 [Minor — Fact Discrepancy]:** Table 5 asserts that `NdaRepository` sends JSON and unencoded string `custom_clauses`. In reality, `NdaRepository` already sends `FormData` and `jsonEncode(customClauses)`.
- **Finding 4 [Minor — Formatting/Tooling]:** Reproduction cURLs use bash `\` continuations with `curl.exe`. Add a brief note advising Windows developers to execute via Git Bash / WSL, or provide PowerShell backtick (`` ` ``) equivalents.
- **Finding 5 [Approved — DRF Fixes]:** All recommended backend fixes for Django REST Framework (password validation, AI wizard decoupling, JSONParser addition, Celery email dispatch) are **100% technically sound and approved**.
- **Finding 6 [Approved — Headers & Parity]:** Reproduction cURLs possess complete, correct headers (`ngrok-skip-browser-warning: 69420`, `Authorization`, `Content-Type`). Real client route bugs (`investorInvestments` 404, `onboarding('sponsor')` 404, and `sign-nda` JSON 415) are accurately diagnosed and approved.

---

## 5. Verification Method

To independently verify these findings:

1. **Verify `CreateProjectRequestModel` Compliance:**
   - Inspect `d:\Ismail_flutter\julkar_vai\lib\views\sponsor\create_project\models\create_project_models.dart`: lines 56-76 (`short_description`, `target_roi`, `timeline_months`, `toFormData()`).
2. **Verify `ResetPasswordRequestModel` Compliance:**
   - Inspect `d:\Ismail_flutter\julkar_vai\lib\views\auth\reset_password\models\reset_password_model.dart`: lines 14-19 (`'code': code`).
3. **Verify `NdaRepository` Compliance:**
   - Inspect `d:\Ismail_flutter\julkar_vai\lib\views\sponsor\nda\repositories\nda_repository.dart`: lines 65-77 (`jsonEncode(customClauses)`, `FormData.fromMap(map)`).
4. **Verify Route 404 Bugs in Client:**
   - Inspect `d:\Ismail_flutter\julkar_vai\lib\core\constants\api_endpoints.dart`: line 62 (`investorInvestments`) and line 28 (`onboarding`).
