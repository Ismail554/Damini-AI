# Dispatch Instructions

## 2026-10-08T05:27:42Z
You are the Project Orchestrator for the Braintech Flutter application end-to-end audit.

Your working directory is: d:\Ismail_flutter\julkar_vai\.agents\teamwork\orchestrator\
Project root: d:\Ismail_flutter\julkar_vai
User request authoritative record: d:\Ismail_flutter\julkar_vai\.agents\teamwork\ORIGINAL_REQUEST.md

Please review the full requirements in ORIGINAL_REQUEST.md:
- R1. Comprehensive Static & Mock Data Audit (lib/views/ and lib/data/ for mock lists, placeholder constants, Future.delayed, stub repos, and missing endpoints)
- R2. End-to-End User Flow & Navigation Verification (AppRouter, role selection, auth, onboarding, home tabs, AI chat, sponsor project creation, deal flow lifecycle, back buttons, route params)
- R3. Backend Integration & API Robustness Audit (ApiService usage, ApiException/AppException handling, token expiration/refresh, offline resilience, schema compliance)
- R4. UX / UI Consistency & Edge Case Audit (shimmers, empty states, error snackbars, AppThemeColors dark/light, ScreenUtil, keyboard overflow)
- R5. Production Readiness & Quality Assurance Report (remediation checklist, dart analyze, test suite execution & coverage, .env security, secure storage)

Acceptance Criteria:
1. Every repository across lib/views/ (Investor, Sponsor, Auth, Profile, Notifications, Chat, AI Chat) audited for real API integration vs fallback mocks.
2. Any remaining unintegrated endpoints documented with exact HTTP methods, URLs, request/response JSON contracts.
3. All route paths in AppRouter verified against screen invocations and bottom navigation bar tabs. Investor -> Sponsor role switching flow and permissions verified.
4. dart analyze executed and audited.
5. Automated test suite executed and audited for coverage gaps.
6. Final executive audit report provided with prioritized remediation steps.

Maintain your BRIEFING.md and progress.md regularly in your working directory.
Dispatch specialists as appropriate, synthesize findings, verify everything thoroughly, and report back when the audit is complete.
