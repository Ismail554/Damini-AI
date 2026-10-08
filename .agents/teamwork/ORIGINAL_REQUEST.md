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
