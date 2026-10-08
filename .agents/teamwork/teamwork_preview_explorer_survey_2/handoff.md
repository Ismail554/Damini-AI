# Survey Phase Handoff Report: R2 End-to-End User Flow & Navigation Verification Audit

**Auditor Archetype**: Survey Explorer 2 (Navigation & User Flow Auditor)  
**Target Application**: Braintech Flutter Application (`d:\Ismail_flutter\julkar_vai`)  
**Scope**: Requirement R2 (AppRouter, Route Guards, Role Isolation, User Journeys, Back Button Handling, Route Parameters)  
**Date**: 2026-10-08  

---

## 1. Observation

### 1.1 AppRouter Structure & Missing Guardrail Infrastructure
- **File**: `lib/core/routing/app_router.dart` (Lines 44–548)
- **Observations**:
  1. `AppRouter.router` defines **37 flat top-level `GoRoute` entries**.
  2. **Zero Named Routes**: None of the 37 `GoRoute` definitions specify a `name:` parameter. All navigation relies on raw string paths (e.g., `context.push('/public-view')`).
  3. **Zero ShellRoute / StatefulShellRoute**: Bottom navigation inside `HomeView` is implemented via a local `IndexedStack` rather than GoRouter's declarative `ShellRoute` / `StatefulShellRoute`.
  4. **Zero Route Guards / Global Redirect**: `GoRouter` contains no `redirect:` callback. Unauthenticated users or users with incorrect roles can directly load any route if targeted via deep linking or browser URLs.
  5. **Zero Error Handlers**: `GoRouter` does not configure `errorBuilder`, `errorPageBuilder`, or `onException`. If an unknown route path is pushed (e.g., from a push notification payload `item.route`), GoRouter throws an unhandled `GoException`, crashing or displaying a Flutter error screen.

### 1.2 Route Parameter Mismatches & Broken Invocations

#### A. Target Project ID Lost in Investor Carousel (`'projectId'` vs `'id'`)
- **Caller**: `lib/views/investor/dashboard/widgets/investor_banner_carousel.dart` (Lines 230–237):
  ```dart
  if (item.targetProjectId != null && item.targetProjectId!.isNotEmpty) {
    context.push(
      '/public-view',
      extra: {'projectId': item.targetProjectId},
    );
  }
  ```
- **Router Route**: `lib/core/routing/app_router.dart` (Lines 275–289):
  ```dart
  } else if (state.extra is Map) {
    final extraMap = state.extra as Map;
    if (extraMap['project'] is ProjectPublicViewModel) {
      project = extraMap['project'] as ProjectPublicViewModel;
    ...
    if (extraMap['id'] != null) {
      projectId = extraMap['id'].toString();
    }
  }
  ```
- **Consequence**: `app_router.dart` checks `extraMap['id']`, but the banner passes `extraMap['projectId']`. `projectId` evaluates to `null`. In `lib/views/sponsor/public_view/screens/project_public_view.dart` (Lines 56–63), `_project` silently defaults to `ProjectPublicViewModel.mockData()`. The tapped banner item fails to load its intended project.

#### B. "View Deal Details" in Investment History Completely Unbound
- **Caller**: `lib/views/investor/investment_history/screens/investment_history_screen.dart` (Lines 473–478):
  ```dart
  SizedBox(
    width: double.infinity,
    height: 38.h,
    child: OutlinedButton(
      onPressed: () => context.push('/public-view'),
      style: OutlinedButton.styleFrom(...),
      child: Text("View Deal Details"),
    ),
  )
  ```
- **Context Model**: Each card renders an `InvestmentRecordModel item`, which explicitly defines `item.projectId` (Lines 42, 107 in `investment_record_model.dart`).
- **Consequence**: `context.push('/public-view')` is invoked with zero `extra` or parameters. `ProjectPublicView` always falls back to hardcoded mock project data instead of the user's selected investment.

#### C. Investor Group Chat Launched Without Conversation & Project IDs
- **Caller**: `lib/views/investor/chat/screens/investor_chat_view.dart` (Lines 135–139):
  ```dart
  onTap: () {
    ref.read(investorChatProvider.notifier).clearUnread(chat.id);
    if (chat.isGroupChat) {
      context.push('/group-chat', extra: chat.name);
    }
  ```
- **Sponsor Equivalent**: `lib/views/sponsor/chat/screens/sponsor_chat_view.dart` (Lines 91–99):
  ```dart
  if (chatItem.isGroupChat) {
    context.push(
      '/group-chat',
      extra: {
        'title': chatItem.name,
        'conversationId': int.tryParse(chatItem.id),
        'projectId': chatItem.projectId,
      },
    );
  }
  ```
- **Router Route**: `lib/core/routing/app_router.dart` (Lines 380–405):
  When `state.extra is String`, `title = state.extra as String`, but `conversationId` and `projectId` remain `null`.
- **Target Screen / Controller**: `lib/views/sponsor/group_chat/controllers/group_chat_provider.dart` (Lines 137–160):
  When both `conversationId` and `projectId` are null, WebSocket connection and message fetching are completely skipped:
  ```dart
  if (targetConvId != null && targetConvId.isNotEmpty) {
    await _connectWebSocket(targetConvId);
    ...
  } else {
    state = state.copyWith(isLoading: false, messages: const [], suggestions: const []);
  }
  ```
- **Consequence**: Any investor tapping a group chat arrives in an empty, disconnected chat room with 0 messages.

#### D. Synthetic String Chat IDs Bypass Backend & WebSocket
- **Callers**:
  1. `lib/views/investor/saved/widgets/investor_saved_project_card.dart` (Lines 151–159):
     `id: "chat_${item.id}"`, `name: item.title` -> `context.push('/direct-chat', extra: chatItem)`
  2. `lib/views/profile/public_profile/screens/public_profile_view.dart` (Lines 254–263):
     `id: "chat_${displayName.hashCode.abs()}"` -> `context.push('/direct-chat', extra: chatItem)`
- **Controller Logic**: `lib/views/sponsor/chat/controllers/direct_chat_provider.dart` (Lines 79–86):
  ```dart
  final isBackendId = int.tryParse(chatItem.id) != null;
  if (isBackendId) {
    await _connectWebSocket(chatItem.id);
    await _fetchMessages(chatItem.id);
  } else {
    _loadFallback();
  }
  ```
- **Consequence**: Neither flow creates a genuine backend conversation (`startConversation`). Because `int.tryParse("chat_...")` evaluates to `null`, both screens permanently fall back to hardcoded mock conversation lists (`_loadFallback()`), preventing actual live chat.

#### E. Deep Links Omit Query Parameter Extraction
- **Routes**:
  - `/sponsor-project-details` (`app_router.dart:194–223`): Only inspects `state.extra`. Ignores `state.uri.queryParameters['id']`.
  - `/public-view` (`app_router.dart:253–299`): Only inspects `state.extra`. Ignores `state.uri.queryParameters['id']` or `['projectId']`.
  - `/public-profile` (`app_router.dart:300–329`): Only inspects `state.extra is Map`. Ignores `state.uri.queryParameters['userId']`.
- **Consequence**: Any external push notification, web link, or deep-link with query strings (e.g., `/public-view?id=42`) completely fails to resolve the object and displays default mock states.

#### F. Reset Password State and Email Abandoned
- **Caller**: `lib/views/auth/otp/screens/otp_verification_view.dart` (Line 75):
  `context.go(widget.isRecovery ? '/reset-password' : '/success');`
- **Target Controller & Repo**: `lib/views/auth/reset_password/controllers/reset_password_provider.dart` (Lines 47–51), `reset_password_repository.dart` (Lines 8–13).
- **Consequence**: Navigating to `/reset-password` passes zero parameters. The view has no knowledge of the verified email or recovery token. `ResetPasswordRepositoryImpl` is a stub with `Future.delayed(Duration(seconds: 1))` returning hardcoded success.

### 1.3 Back Button Handling & PopScope Audit

#### A. App-Wide PopScope Absence
- **Grep Query**: `(PopScope|WillPopScope)` across all Dart files under `lib/`.
- **Result**: Exactly **1 match in the entire project**:
  - `lib/views/home/screens/home_view.dart` (Line 163): Implements `PopScope(canPop: false, onPopInvokedWithResult: ...)` to reset tab index to 0 or prompt "Press back again to exit" before `SystemNavigator.pop()`.
- **Missing From All Other Screens**: 36 of 37 routes have **zero** PopScope implementations.

#### B. Premature Exit from Multi-Step Role Onboarding Wizard
- **File**: `lib/views/role_selection/role_onboarding_view.dart` (Lines 127–146)
- **Wizard Steps**: 5 pages inside an internal `PageView` (Choose Account Type -> Complete Profile -> Select Interests -> Company Verification -> Verification Pending).
- **Back Implementation**: `_prevPage()` is wired only to the in-widget back arrow buttons.
- **Consequence**: When a user on Step 2, 3, or 4 presses the Android system back button or predictive back gesture, Flutter pops the route rather than decrementing `_pageCtrl`. All onboarding form data is lost and the user is unexpectedly ejected to `/role-selection`.

#### C. Fatal `context.pop()` Crash on Reset Password Screen
- **File**: `lib/views/auth/reset_password/screens/reset_password_view.dart` (Lines 77–79):
  ```dart
  IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    onPressed: () => context.pop(),
  )
  ```
- **Route Origin**: The user lands on `/reset-password` via `context.go('/reset-password')` from `OtpVerificationView:75`. `context.go` clears previous router history.
- **Consequence**: Because `context.canPop()` is false, tapping the back button triggers `GoError: There is nothing to pop` or `Navigator.pop() called on top of navigation stack`, crashing the view in debug or generating unhandled runtime errors.

#### D. Unconfirmed Data Loss on Long Forms
- **File**: `lib/views/sponsor/create_project/screens/create_project_view.dart`
- **Form Size**: 20+ form inputs, dropdowns, and file upload controllers.
- **Consequence**: Has zero `PopScope`. Tapping the hardware back button immediately pops the screen without warning, discarding draft inputs unless the user explicitly hit "Save Draft".

### 1.4 Role Selection & Role Switching Audit

#### A. Role Storage and Switch Mechanism
- **Provider**: `lib/views/auth/session/controllers/session_provider.dart` (`authProvider` / `sessionProvider`)
- **Persistence**: `StorageService.getRole()` / `StorageService.saveRole(role)` (values `'sponsor'` or `'investor'`).
- **In-App Switching**: Initiated in `InvestorProfileView` (Line 107) and `SponsorProfileView` (Line 107) via `AccountTypeSwitcherCard`.
  - Prompts `SwitchRoleDialog.show(context, newRole)`.
  - Executes `authProvider.notifier.switchRole(newRole)`.
  - Calls backend endpoint: `POST /api/v1/users/switch-role/` via `switch_role_repository.dart`.
  - On success: Saves new tokens, updates `state.userRole`, and checks `result.isOnboarded`.
  - If onboarded: calls `ref.read(homeProvider.notifier).setTabIndex(0)`.
  - If not onboarded: redirects to `context.push('/role-onboarding', extra: {'role': newRole})`.

#### B. HomeView Role Adaptability
- **File**: `lib/views/home/screens/home_view.dart` (Lines 91–109, 155–160)
- **Reaction**: Watches `authProvider.userRole`. When switched to `sponsor`, displays `[SponsorDashboard, SponsorSavedView, SponsorChatView, SponsorProfileView]`. When switched to `investor`, displays `[InvestorDashboard, InvestorSavedView, InvestorChatView, InvestorProfileView]`. Bottom navigation labels and icons update accordingly.

#### C. Complete Lack of Cross-Role Permission Enforcement
- **Observation**: While `HomeView` alters its bottom bar tabs, `app_router.dart` applies **no role enforcement** on routes.
  - An **Investor** can directly call `context.push('/create-project')`, `context.push('/sponsor-projects')`, `context.push('/collaboration-requests')`, or `context.push('/sponsor-project-details')`.
  - A **Sponsor** can directly call `context.push('/discover')`, `context.push('/investment-history')`, or `context.push('/request-collaboration')`.
  - `CreateProjectView._onPublish` (Lines 304–314) checks `verificationStatus == 'APPROVED'`, but does NOT verify `userRole == 'sponsor'`.
  - `PushPayload.resolveRoute` (`lib/core/services/push/push_payload.dart:79–93`) attempts to enforce role boundaries for FCM notifications, but this logic is restricted only to push payloads and is completely absent from the router itself.

#### D. Investor Profile Edit Calls Sponsor-Biased Logic
- **File**: `lib/views/profile/personal_info/repositories/sponsor_edit_profile_repository.dart` (Lines 34–42):
  ```dart
  if (role == 'sponsor') {
    try {
      final response = await _apiService.get(
        ApiEndpoints.profileByRole('sponsor'),
        requireAuth: true,
      );
      profileData = response.data;
    } catch (_) {}
  }
  ```
- **Consequence**: When an **Investor** opens `/edit-profile` (from `PersonalInformationView:190`), `getProfile()` checks `if (role == 'sponsor')`. For investors, `profileData` is skipped, fetching only basic user names from `/users/me/` and leaving investor profile fields blank.

### 1.5 Orphaned & Dead-End Routes
- **Orphan 1**: `lib/shared/screens/role_feature_slides_screen.dart`
  - Fully implemented 284-line slider widget (`RoleFeatureSlidesScreen`) explaining role capabilities with icons and page indicators.
  - Zero imports across the entire project; completely orphaned.
- **Orphan 2**: `lib/views/sponsor/project_details/screens/all_contributors_view.dart`
  - Registered as `/all-contributors` in `app_router.dart:427`.
  - Never invoked by any navigation call. In `SponsorProjectDetailsView:255–262`, tapping "View All" on contributors simply toggles a local `_isExpanded` flag instead of navigating to `/all-contributors`.
- **Orphan 3 & 4**: `/investor-onboarding` and `/sponsor-onboarding` (`app_router.dart:144, 152`)
  - Redundant routes never targeted by the UI (all callers use `/role-onboarding` with `extra: {'role': ...}`).

---

## 2. Logic Chain

1. **Premise**: In Flutter applications using GoRouter, routing reliability requires:
   - Consistent parameter serialization between callers and route extractors.
   - Robust back-stack navigation handling via `PopScope` to prevent data loss or navigation stack depletion crashes.
   - Centralized authentication and authorization guards to isolate role workflows.
   - Graceful fallback and error pages for unrecognized routes.
2. **From Observation 1.1**:
   - `AppRouter` has 37 flat routes with no `redirect` guard and no `errorBuilder`.
   - *Inference*: Any deep link, push notification with unexpected route, or unauthorized user access is either unrestricted or results in an unhandled crash.
3. **From Observation 1.2.A**:
   - `investor_banner_carousel.dart` passes `{'projectId': id}`, while `app_router.dart` parses `extraMap['id']`.
   - *Inference*: The project ID is never extracted from banner taps. `ProjectPublicView` receives `null`, falling back to mock data (`ProjectPublicViewModel.mockData()`), breaking the investor discovery pipeline.
4. **From Observation 1.2.B**:
   - `investment_history_screen.dart:477` invokes `context.push('/public-view')` with no parameters despite having `item.projectId`.
   - *Inference*: Investors cannot inspect their real investment deals; tapping any investment always displays the static Acme Corp mock deal.
5. **From Observation 1.2.C**:
   - `investor_chat_view.dart:138` passes `chat.name` as a String, whereas `sponsor_chat_view.dart:93` passes a Map containing `conversationId` and `projectId`.
   - `group_chat_view.dart` requires integer IDs to open WebSocket channels and pull message histories.
   - *Inference*: The group chat feature is completely broken for investors, opening an uninitialized empty chat view.
6. **From Observation 1.2.D**:
   - Saved project cards and public profiles synthesize string IDs like `"chat_${item.id}"`.
   - `direct_chat_provider.dart` only connects to the backend if `int.tryParse(chatItem.id) != null`.
   - *Inference*: All direct chat entries launched from saved projects or user profile cards remain in an isolated mock state and can never exchange live messages.
7. **From Observation 1.3.B & 1.3.C**:
   - Only `HomeView` contains a `PopScope`.
   - Multi-step wizards (`RoleOnboardingView`) exit to previous routes on hardware back presses rather than stepping back in the `PageView`.
   - `ResetPasswordView` calls `context.pop()` on a stack that was flattened by `context.go()`.
   - *Inference*: Android users experience accidental onboarding abandonment, and password recovery users encounter unhandled runtime crashes upon pressing the back button.
8. **From Observation 1.4.C & 1.4.D**:
   - Role switching only flips tabs within `HomeView`. Router paths are completely unconstrained.
   - `EditProfileView` relies on `sponsor_edit_profile_repository.dart`, which skips loading profile data if `role != 'sponsor'`.
   - *Inference*: Role boundaries can be violated via deep links, and investors editing their profile from `InvestorProfileView` experience broken profile field retrieval.

---

## 3. Caveats

1. **Physical Device Push Interception**: FCM push token registration and background message handling (`NotificationService`) were verified via static trace and payload schema auditing; live delivery was not verified against active APNs / FCM production servers.
2. **Backend RBAC Enforcement**: While the Flutter client lacks client-side route guards, backend endpoints may enforce 403 Forbidden on specific operations (e.g., if an investor attempts to POST to `/api/v1/projects/create/`). However, the client UI does not gracefully handle such 403 responses and allows users to enter the prohibited forms.
3. **No Project Source Modification**: In compliance with the Explorer archetype instructions, no application source code files were edited during this survey.

---

## 4. Conclusion

The Braintech Flutter application possesses a well-structured visual shell (`HomeView` with role-aware `IndexedStack` tabs and a functional `SessionNotifier.switchRole` backend bridge). However, the navigation and routing layer has **several critical functional defects, unhandled edge cases, and parameter mismatches**:

1. **Parameter Disconnects**:
   - Target project ID key mismatch on the Investor dashboard banner (`'projectId'` vs `'id'`).
   - "View Deal Details" in Investment History opens static mock data due to missing route arguments.
   - Investor group chats cannot connect or load messages because `chat.name` is passed instead of `conversationId` and `projectId`.
   - Saved project and profile chat buttons generate synthetic string IDs that force `DirectChatProvider` into mock fallback mode.
2. **Back Button Fragility**:
   - The multi-step `RoleOnboardingView` wizard discards progress on system back press due to missing `PopScope`.
   - `ResetPasswordView` crashes on back press via unsafe `context.pop()`.
   - `CreateProjectView` allows unconfirmed data loss on back press.
3. **Missing Router Protections**:
   - Zero authentication guards or role-based guards in `app_router.dart`.
   - Zero error route handlers for unknown locations in `GoRouter`.
   - Orphaned code remnants (`RoleFeatureSlidesScreen`, `/all-contributors`).

---

## 5. Verification Method

### 5.1 Independent Code Verification Points

| Defect Area | File Path | Line Range | Verification Inspection Method |
|---|---|---|---|
| **Banner Param Mismatch** | `lib/views/investor/dashboard/widgets/investor_banner_carousel.dart` | 230–237 | Confirm `extra: {'projectId': item.targetProjectId}` is passed. |
| **Router Param Mismatch** | `lib/core/routing/app_router.dart` | 286–288 | Confirm `app_router.dart` only checks `extraMap['id']`, ignoring `'projectId'`. |
| **History Deal Details** | `lib/views/investor/investment_history/screens/investment_history_screen.dart` | 476–478 | Confirm `context.push('/public-view')` passes no extra/arguments. |
| **Investor Chat Param** | `lib/views/investor/chat/screens/investor_chat_view.dart` | 137–139 | Confirm `context.push('/group-chat', extra: chat.name)` passes a String, not Map. |
| **Group Chat Provider** | `lib/views/sponsor/group_chat/controllers/group_chat_provider.dart` | 150–160 | Confirm `_connectWebSocket` is bypassed when `conversationId` is null. |
| **Synthetic Chat IDs** | `lib/views/investor/saved/widgets/investor_saved_project_card.dart` | 151–159 | Confirm `id: "chat_${item.id}"` is passed, forcing fallback in `direct_chat_provider.dart:79`. |
| **Missing PopScope** | `lib/views/role_selection/role_onboarding_view.dart` | 149–169 | Confirm root widget is `CommonBackground` without `PopScope`. |
| **Reset Password Crash** | `lib/views/auth/reset_password/screens/reset_password_view.dart` | 76–79 | Confirm `IconButton` calls `context.pop()` without `context.canPop()`. |
| **Missing Router Guards** | `lib/core/routing/app_router.dart` | 50–54 | Confirm `GoRouter` definition lacks `redirect` and `errorBuilder`. |
| **Orphaned Slides** | `lib/shared/screens/role_feature_slides_screen.dart` | 19–30 | Confirm class `RoleFeatureSlidesScreen` is never imported anywhere in `lib/`. |

### 5.2 Automated Command Execution

Run static analysis across the repository to verify file consistency:
```powershell
flutter analyze
```

### 5.3 Invalidation Conditions
This audit's conclusions would be invalidated if:
1. `AppRouter` were refactored to wrap routes in role-specific `ShellRoute` trees with centralized `redirect` interceptors.
2. Unified navigation helper methods (or typed routes with `go_router_builder`) were introduced to enforce type-safe argument passing.
3. `PopScope` widgets were added to `RoleOnboardingView`, `CreateProjectView`, and `ProjectPublicView`.
