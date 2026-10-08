# Project: Braintech Flutter Application Comprehensive E2E Audit

## Architecture
- Client: Flutter Mobile/Desktop/Web App (Dart)
- State Management & DI: Provider / Riverpod / GetX / InheritedWidget (to be verified by Explorers)
- Routing: GoRouter / AutoRoute / Flutter Navigator 2.0 via `AppRouter` (`lib/core/routing/app_router.dart`)
- Network & API Layer: `ApiService` (`lib/core/services/api_service.dart`), repositories in `lib/data/` or feature folders
- Design System: `AppThemeColors`, `CustomSnackBar`, `flutter_screenutil`
- User Roles: Investor, Sponsor, and Shared/Auth flows

## Feature Inventory (Initial Audit Scope)
| # | Feature / Area | Description | Audit Focus | Source |
|---|----------------|-------------|-------------|--------|
| 1 | R1: Mock & Static Data Remnants | Hardcoded lists, constants, Future.delayed, stub repos in lib/views/ & lib/data/ | Catalog file paths, variables, missing endpoint specs | ORIGINAL_REQUEST §R1 |
| 2 | R2: User Flows & Navigation | AppRouter, role switching (Investor <-> Sponsor), auth, onboarding, deal flow | Dead-ends, broken back buttons, route param validation | ORIGINAL_REQUEST §R2 |
| 3 | R3: Backend Integration & API Robustness | ApiService, ApiException/AppException, token refresh, offline resilience | Schema mismatch, unhandled HTTP status, interceptors | ORIGINAL_REQUEST §R3 |
| 4 | R4: UX/UI Consistency & Edge Cases | Shimmers, empty states, snackbars, theme mode, ScreenUtil, keyboard overflows | Visual glitches, unhandled loading/error states | ORIGINAL_REQUEST §R4 |
| 5 | R5: Production Readiness & Code Health | dart analyze, automated tests, .env security, secure storage | Static analysis output, test execution, secrets exposure | ORIGINAL_REQUEST §R5 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|--------------|--------|
| M0 | Survey & Multi-Track Exploration | 3 parallel Explorers across R1-R5 | None | IN_PROGRESS |
| M1 | Deep Static Data & Endpoint Contract Catalog | Full catalog of unintegrated endpoints with HTTP method, URL, payloads | M0 | PLANNED |
| M2 | Flow & Navigation Matrix Verification | Complete route tree vs screen invocation mapping & role transitions | M0 | PLANNED |
| M3 | Quality Assurance & Static Analysis Audit | dart analyze execution, test suite run, security audit | M0 | PLANNED |
| M4 | Forensic Audit & Integrity Verification | Forensic integrity checks on findings and recommendations | M1, M2, M3 | PLANNED |
| M5 | Final Executive Audit Report & Prioritized Remediation Plan | Unified executive report synthesized for stakeholders | M4 | PLANNED |

## Interface Contracts & Guidelines
- Output format for missing endpoints: Exact HTTP Method, URL path, Request Body JSON schema, Response Body JSON schema.
- Output format for mock data: Absolute/relative file path, Line numbers, Variable/method name, Classification (Pure Mock / Fallback Mock / Placeholder Constant / Future.delayed stub).
- Output format for navigation routes: Route path, Screen widget, Role constraint, Parameters required, Back button behavior.
