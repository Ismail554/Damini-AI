# Backend Connectivity, Environment & Probing Mechanics Survey

**Date:** 2026-10-11  
**Investigating Agent:** `explorer_backend_survey_1`  
**Working Directory:** `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\`  
**Target Backend:** `https://clubby-andy-irksomely.ngrok-free.dev`  

---

## 1. Executive Summary & Verification Matrix

The backend server is online, operational, and responsive via the ngrok tunnel. It runs **Django REST Framework** served via **Daphne (ASGI)** with `DEBUG = True` enabled. Live probing successfully validated public endpoints, schema endpoints, authentication, token refresh, and role-switching mechanics.

| Probe / Survey Item | Status | Verified Result | Details |
| :--- | :---: | :--- | :--- |
| **Backend Base URL** | ✅ Verified | `https://clubby-andy-irksomely.ngrok-free.dev` | Declared in `.env` and fallback in `api_endpoints.dart` |
| **ngrok Interception Header** | ⚠️ Required | `ngrok-skip-browser-warning: 69420` (or `true`) | **Strictly required** for mobile/browser User-Agents; otherwise ngrok serves `ERR_NGROK_6024` HTML |
| **OpenAPI / Swagger Spec** | ✅ Verified | `/api/schema/`, `/docs/`, `/swagger/`, `/redoc/` | Complete 85 KB OpenAPI 3.0 schema extracted and saved |
| **Public Endpoints** | ✅ Verified | `GET /api/v1/banners/` (200), `GET /api/v1/projects/` (200) | Returns valid JSON; 5 active projects live in DB |
| **Protected Endpoints Guard** | ✅ Verified | `GET /api/v1/profiles/industries/` (401), `GET /discover/` (401) | Returns structured 401 with `Authentication credentials were not provided.` |
| **Pre-existing Test Account** | ✅ Verified | `ismailshuvo555@gmail.com` / `586908sH` | User ID 28. Fully configured for **BOTH** Investor & Sponsor roles |
| **Token Refresh Lifecycle** | ✅ Verified | `POST /api/v1/auth/token/refresh/` (200) | Successfully refreshes JWT access/refresh token pair |
| **Role Switching Mechanics** | ✅ Verified | `POST /api/v1/users/switch-role/` (200) | Instantly switches between `INVESTOR` and `SPONSOR`, issuing fresh tokens |

---

## 2. Environment Configuration Analysis

### 2.1 File Location & Variables
Configuration file is located at `d:\Ismail_flutter\julkar_vai\.env`:

```env
BASE_URL=https://clubby-andy-irksomely.ngrok-free.dev
GOOGLE_SERVER_CLIENT_ID=1003008036989-vtiu7c5gn3936pj7jn5mg3nn5ao2k9bd.apps.googleusercontent.com
FIREBASE_PROJECT_ID=damini-ai
FIREBASE_MESSAGING_SENDER_ID=1003008036989
FIREBASE_ANDROID_API_KEY=AIzaSyDN6umw3hTVL4arpnIpKD2L-UzJ3Fvp0uE
FIREBASE_ANDROID_APP_ID=1:1003008036989:android:5ddc00f78c3c5d2022a114
FIREBASE_STORAGE_BUCKET=damini-ai.firebasestorage.app
FIREBASE_IOS_API_KEY=AIzaSyDus-Kwpx5cHGcdfKOVUU7jD2TlX8EZp90
FIREBASE_IOS_APP_ID=1:1003008036989:ios:fb0b806b699cd83222a114
FIREBASE_IOS_BUNDLE_ID=com.braintekh.diafi
```

### 2.2 Client URL Resolution Logic
In `lib/core/constants/api_endpoints.dart`:
```dart
static String get baseUrl {
  if (dotenv.isInitialized) {
    try {
      final url = dotenv.env['BASE_URL'];
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
  }
  return "https://clubby-andy-irksomely.ngrok-free.dev";
}
```
Both the `.env` value and hardcoded fallback match `https://clubby-andy-irksomely.ngrok-free.dev`.

---

## 3. HTTP Client Setup, Interceptors & Default Headers

Inspected files:
- `lib/core/services/dio_service.dart`
- `lib/core/services/api_service.dart`
- `lib/core/services/auth_interceptor.dart`
- `lib/core/services/storage_service.dart`

### 3.1 Dio Client Dual-Instance Architecture
`DioService` instantiates two dedicated static clients:
1. `DioService.client`: Uses `AuthInterceptor` for protected APIs (Profile, Projects, Dashboard, Chat, etc.).
2. `DioService.noAuthClient`: Bypasses `AuthInterceptor` for unauthenticated APIs (Login, Signup, OTP, Token Refresh).

### 3.2 Default Headers
Configured on `BaseOptions`:
```dart
headers: const {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'ngrok-skip-browser-warning': '69420',
  'User-Agent': 'Braintech-Mobile-App/1.0',
}
```
In addition, `DioService` attaches a dedicated `_ngrokInterceptor`:
```dart
static final InterceptorsWrapper _ngrokInterceptor = InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['ngrok-skip-browser-warning'] = '69420';
    handler.next(options);
  },
);
```
And `AuthInterceptor.onRequest` also explicitly reinforces:
```dart
options.headers['ngrok-skip-browser-warning'] = '69420';
```

### 3.3 Authorization & Concurrency Token Refresh
`AuthInterceptor`:
1. Reads access token from secure storage: `StorageService.getToken()`.
2. Attaches `Authorization: Bearer <token>`.
3. Catches HTTP `401 Unauthorized`:
   - Uses a `Completer<bool>? _refreshCompleter` mutex lock to prevent stampedes when multiple simultaneous requests receive 401.
   - Issues a single refresh call to `POST /api/v1/auth/token/refresh/` using a clean, dedicated `_refreshDio` instance with `{'refresh': refreshToken}`.
   - On success: updates tokens in `StorageService`, tags the failed request with `isRetry: true`, and replays it with the new token.
   - On failure: clears credentials via `StorageService.clearAll()` and redirects to `/login`.

### 3.4 SSL Certificate Handling
In `lib/core/services/dio_service.dart`:
```dart
if (kDebugMode) {
  client.badCertificateCallback = (cert, host, port) => true;
}
```
This bypasses self-signed or invalid cert warnings in debug environments, preventing local/staging handshake drops.

---

## 4. Live Probing Mechanics & ngrok Behavior

### 4.1 Server State & Routing
Probing root `/` returned Django's debug URLconf error page confirming Daphne server:
```
Server: daphne
Ngrok-Agent-Ips: 123.0.23.1
DEBUG = True (config.urls)
```
Top-level namespaces identified:
- `admin/`
- `api/schema/`
- `docs/`
- `swagger/`
- `redoc/`
- `api/v1/auth/`
- `api/v1/users/`
- `api/v1/profiles/`
- `api/v1/projects/`
- `api/v1/notifications/`
- `api/v1/ai/`
- `api/v1/`
- `^media/`
- `^static/`

### 4.2 Is `ngrok-skip-browser-warning` Strictly Required?
**YES.**
- When requests are made with a standard browser User-Agent (`Mozilla/5.0...`) or a mobile webview User-Agent without `ngrok-skip-browser-warning`, ngrok intercepts the request and responds with **HTTP 200 OK** containing an HTML interstitial page (`ERR_NGROK_6024`).
- When `ngrok-skip-browser-warning: 69420` (or `true`) is passed, ngrok immediately forwards the request to the upstream Daphne backend.
- Command-line `curl` with its native user agent (`curl/8.x`) is whitelisted by ngrok, but any realistic client simulator, automated browser, or mobile request MUST pass this header.

### 4.3 Live Endpoint Verification Results

#### Probe 1: OpenAPI Schema (`GET /api/schema/`)
- **Status:** `HTTP/1.1 200 OK`
- **Output:** Extracted and saved to `openapi_schema.yaml` (85,356 bytes).
- Contains 73 total REST operations covering Auth, Profiles, Projects, Notifications, Chat, and AI Copilot.

#### Probe 2: Public Banners (`GET /api/v1/banners/`)
- **Headers:** `ngrok-skip-browser-warning: true`, `Accept: application/json`
- **Status:** `HTTP/1.1 200 OK`
- **Response Body:**
  ```json
  {"status":"success","data":[]}
  ```

#### Probe 3: Public Projects List (`GET /api/v1/projects/`)
- **Status:** `HTTP/1.1 200 OK`
- **Response Body:** Returns 5 active projects with full schemas:
  - Project ID 5: "abdullah al fahad" (Sponsor: "Global Ventures LLC", status: "ACTIVE")
  - Project ID 4: "test the new project" (Sponsor: "Global Ventures LLC", status: "ACTIVE")
  - Project ID 3: "Dummy Project 3 by ismail" (Sponsor: "Global Ventures LLC", status: "ACTIVE")
  - Project ID 2: "Dummy Project 2 by ismail" (Sponsor: "Global Ventures LLC", status: "ACTIVE")
  - Project ID 1: "Dummy Project 1 by ismail" (Sponsor: "Global Ventures LLC", status: "ACTIVE")

#### Probe 4: Protected Industries (`GET /api/v1/profiles/industries/` without token)
- **Status:** `HTTP/1.1 401 Unauthorized`
- **Response Body:**
  ```json
  {"status":"error","message":"Authentication credentials were not provided."}
  ```

#### Probe 5: Protected Discover (`GET /api/v1/projects/discover/` without token)
- **Status:** `HTTP/1.1 401 Unauthorized`
- **Response Body:**
  ```json
  {"status":"error","message":"Authentication credentials were not provided."}
  ```

---

## 5. Test Credentials & Authentication Mechanics

### 5.1 Primary Test User (Dual-Role Enabled)
We confirmed and verified the primary developer test account:
- **Email:** `ismailshuvo555@gmail.com`
- **Password:** `586908sH`
- **User ID:** `28`

#### Verification via `POST /api/v1/auth/login/`:
```bash
curl.exe -i -s \
  -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/login/" \
  -d '{"email":"ismailshuvo555@gmail.com","password":"586908sH"}'
```
**Response:** `HTTP/1.1 200 OK`
```json
{
  "access": "eyJhbGciOiJIUzI1Ni...",
  "refresh": "eyJhbGciOiJIUzI1Ni...",
  "user": {
    "id": 28,
    "first_name": "ismail",
    "last_name": "hosen",
    "full_name": "ismail hosen",
    "email": "ismailshuvo555@gmail.com",
    "role": "SPONSOR",
    "is_email_verified": true,
    "push_notifications_enabled": true,
    "subscription_tier": "FREE"
  }
}
```

### 5.2 Live Profile Details (`GET /api/v1/users/me/`)
Authenticated probe returned:
```json
{
  "status": "success",
  "data": {
    "id": 28,
    "first_name": "ismail",
    "last_name": "hosen",
    "email": "ismailshuvo555@gmail.com",
    "role": "SPONSOR",
    "is_email_verified": true,
    "push_notifications_enabled": true,
    "subscription_tier": "FREE",
    "profile": {
      "id": 6,
      "sponsor_type": "COMPANY",
      "first_name": "ismail",
      "last_name": "hosen",
      "email": "ismailshuvo555@gmail.com",
      "legal_company_name": "Global Ventures LLC",
      "registration_number": "",
      "business_address": "",
      "company_website": "",
      "phone": "01619524736",
      "country": "Bangladesh",
      "location": "feni",
      "position_title": "executive",
      "bio": "",
      "profile_photo": "/media/profile_photos/sponsors/cropped_profile_1791178537405.png",
      "verification_status": "APPROVED",
      "documents": [],
      "created_at": "2026-09-24T03:40:10.451320Z",
      "updated_at": "2026-10-05T10:15:25.343831Z"
    },
    "stats": {
      "projects": 5,
      "requests": 3,
      "funded": 0
    }
  }
}
```

### 5.3 Dynamic Role Switching (`POST /api/v1/users/switch-role/`)
The test user is configured with **BOTH** profiles on the database, allowing seamless switching:

#### Switching to INVESTOR:
```bash
curl.exe -i -s \
  -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/users/switch-role/" \
  -d '{"role":"INVESTOR"}'
```
**Response:** `HTTP/1.1 200 OK`
```json
{
  "status": "success",
  "message": "Switched to INVESTOR mode successfully.",
  "data": {
    "active_role": "INVESTOR",
    "is_onboarded": true,
    "verification_status": "PENDING",
    "account_type": "INDIVIDUAL",
    "access": "<NEW_INVESTOR_JWT_ACCESS>",
    "refresh": "<NEW_INVESTOR_JWT_REFRESH>",
    "user": {
      "id": 28,
      "first_name": "ismail",
      "last_name": "hosen",
      "email": "ismailshuvo555@gmail.com",
      "role": "INVESTOR",
      "is_email_verified": true,
      "profile": {
        "investor_type": "INDIVIDUAL",
        "company_name": "Global Ventures LLC",
        "phone": "01619524736",
        "country": "Bangladesh",
        "location": "feni",
        "verification_status": "PENDING"
      },
      "stats": {
        "saved_projects": 1,
        "total_committed": 0,
        "active_projects": 0,
        "pending_ndas": 0
      }
    }
  }
}
```

#### Switching to SPONSOR:
```bash
curl.exe -i -s \
  -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/users/switch-role/" \
  -d '{"role":"SPONSOR"}'
```
**Response:** `HTTP/1.1 200 OK`
- Active Role: `SPONSOR`
- Verification Status: `APPROVED`
- Account Type: `COMPANY` (`Global Ventures LLC`)
- Stats: 5 projects, 3 requests

### 5.4 Token Refresh Verification (`POST /api/v1/auth/token/refresh/`)
```bash
curl.exe -i -s \
  -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/token/refresh/" \
  -d '{"refresh":"<VALID_REFRESH_TOKEN>"}'
```
**Response:** `HTTP/1.1 200 OK`
```json
{
  "access": "<NEW_ACCESS_TOKEN>",
  "refresh": "<NEW_REFRESH_TOKEN>"
}
```

### 5.5 Fresh Registration & OTP Verification Mechanics
Creating fresh accounts was probed against `POST /api/v1/auth/register/`:
```bash
curl.exe -i -s \
  -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/register/" \
  -d '{
    "first_name": "Test",
    "last_name": "User",
    "email": "fresh_user@example.com",
    "password": "Password123!"
  }'
```
**Behavior:**
1. Registration returns `201 Created` with message: `"Account created. Please check your email for the verification code."`
2. Backend generates a 6-digit verification code and triggers email dispatch.
3. Probing `POST /api/v1/auth/verify-otp/` with `"123456"` returned `400 Bad Request` (`"Invalid or expired verification code."`), confirming OTP is dynamically validated on the backend.
4. **Recommendation for live probing workers:** Do NOT attempt registration-loop probes that rely on dynamic email OTP retrieval. Instead, utilize the verified `ismailshuvo555@gmail.com` account and use `POST /api/v1/users/switch-role/` to test both Investor and Sponsor protected endpoints.

---

## 6. Full Django URLconf Route Map

Extracted from live server trace and verified against `openapi_schema.yaml`:

```
/admin/                                                                   [admin]
/api/schema/                                                              [OpenAPI 3.0 YAML spec]
/docs/                                                                    [Swagger UI]
/swagger/                                                                 [Swagger UI]
/redoc/                                                                   [ReDoc UI]
/api/v1/auth/register/                                                    [POST] Register user
/api/v1/auth/verify-otp/                                                  [POST] Verify OTP
/api/v1/auth/resend-otp/                                                  [POST] Resend OTP
/api/v1/auth/login/                                                       [POST] Login with email/pass
/api/v1/auth/logout/                                                      [POST] Logout
/api/v1/auth/google/                                                      [POST] Google Social Login
/api/v1/auth/apple/                                                       [POST] Apple Social Login
/api/v1/auth/token/refresh/                                               [POST] JWT Refresh
/api/v1/auth/forgot-password/                                             [POST] Forgot password request
/api/v1/auth/reset-password/                                              [POST] Reset password
/api/v1/users/me/                                                         [GET, PATCH] Current user
/api/v1/users/switch-role/                                                [POST] Switch role (SPONSOR <-> INVESTOR)
/api/v1/users/change-password/                                            [POST] Change password
/api/v1/users/delete-account/                                             [POST] Soft-delete account
/api/v1/profiles/set-role/                                                [POST] Initial role lock
/api/v1/profiles/industries/                                              [GET] Available industries (auth required)
/api/v1/profiles/verification-status/                                     [GET] Check profile verification
/api/v1/profiles/verification-documents/                                  [POST] Upload docs (multipart)
/api/v1/profiles/investor/onboarding/                                     [PATCH] Complete investor onboarding
/api/v1/profiles/sponsor/                                                 [GET, PATCH] Sponsor profile
/api/v1/profiles/sponsor/status/                                          [GET] Sponsor verification status
/api/v1/profiles/sponsor/nda/                                             [GET, POST] Sponsor NDA terms & deck
/api/v1/profiles/saved/                                                   [GET] Saved profiles
/api/v1/profiles/{user_id}/                                               [GET] User public profile
/api/v1/profiles/{user_id}/save/                                          [POST] Bookmark profile
/api/v1/banners/                                                          [GET] Dashboard banners (public)
/api/v1/projects/                                                         [GET] Public projects list (public)
/api/v1/projects/{id}/                                                    [GET] Project public/detail view
/api/v1/projects/{id}/save/                                               [POST] Bookmark project
/api/v1/projects/{project_id}/sign-nda/                                   [POST] Sign project NDA
/api/v1/projects/{project_id}/requests/                                   [POST] Submit collaboration request
/api/v1/projects/discover/                                                [GET] Filtered discover projects (auth required)
/api/v1/projects/saved/                                                   [GET] Saved projects list
/api/v1/projects/investor/dashboard/                                      [GET] Investor dashboard summary
/api/v1/projects/investor/investments/                                    [GET] Investor investments list
/api/v1/projects/investor/my-requests/                                    [GET] Investor collaboration requests
/api/v1/projects/investor/portfolio-summary/                              [GET] Investor portfolio summary
/api/v1/projects/sponsor/                                                 [GET, POST] Sponsor project list & creation
/api/v1/projects/sponsor/{id}/                                            [GET, PATCH] Sponsor project detail & update
/api/v1/projects/sponsor/requests/                                        [GET] Sponsor incoming collaboration requests
/api/v1/projects/sponsor/requests/{id}/approve/                           [POST] Approve collaboration request
/api/v1/projects/sponsor/requests/{id}/reject/                            [POST] Reject collaboration request
/api/v1/projects/sponsor/requests/{id}/fund-received/                     [POST] Record wired funds
/api/v1/projects/{id}/confirm-investors/                                  [POST] Confirm investors
/api/v1/projects/{id}/terminate/                                          [POST] Terminate project
/api/v1/ai/projects/conversations/                                        [GET, POST] Damini Advisor conversations
/api/v1/ai/projects/conversations/{id}/                                   [GET] Damini Advisor conversation detail
/api/v1/ai/projects/conversations/{id}/messages/                          [GET, POST] Damini Advisor messages
/api/v1/ai/chat/initial/                                                  [GET] AI Copilot initial conversation
/api/v1/ai/chat/conversations/{conversation_id}/messages/                 [GET, POST] AI Copilot messages
/api/v1/ai/chat/conversations/{conversation_id}/clear/                    [POST] AI Copilot clear history
/api/v1/notifications/                                                    [GET] Notifications list
/api/v1/notifications/{id}/read/                                          [PATCH] Mark notification read
/api/v1/notifications/mark-all-read/                                      [POST] Mark all notifications read
/api/v1/notifications/clear-all/                                          [DELETE] Clear all notifications
/api/v1/notifications/device-token/                                       [POST] Register FCM device token
/api/v1/notifications/chat/conversations/                                 [GET] Chat conversations list
/api/v1/notifications/chat/conversations/start/                           [POST] Start direct chat
/api/v1/notifications/chat/conversations/{id}/header/                     [GET] Chat header info
/api/v1/notifications/chat/conversations/{id}/messages/                   [GET] Chat messages history
/api/v1/notifications/chat/conversations/{id}/messages/send/              [POST] Send chat message (HTTP fallback)
/api/v1/notifications/chat/conversations/{id}/read/                       [POST] Mark chat read
/api/v1/notifications/chat/upload/                                        [POST] Upload chat audio/media
/api/v1/notifications/chat/conversations/{id}/leave/                      [POST] Leave group chat
/api/v1/notifications/chat/conversations/{id}/report/                     [POST] Report chat
/api/v1/notifications/chat/conversations/{id}/confirm-investors/          [POST] Confirm investors via chat
/api/v1/notifications/chat/conversations/{id}/participants/{user_id}/     [DELETE] Remove participant
```

---

## 7. Direct Instructions & Golden cURLs for Probing Workers

### 7.1 Golden cURL: Sponsor Authentication
```bash
curl.exe -s -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/login/" \
  -H "ngrok-skip-browser-warning: 69420" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"ismailshuvo555@gmail.com","password":"586908sH"}'
```

### 7.2 Golden cURL: Switch to Investor Role
```bash
curl.exe -s -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/users/switch-role/" \
  -H "ngrok-skip-browser-warning: 69420" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"role":"INVESTOR"}'
```

### 7.3 Golden cURL: Switch to Sponsor Role
```bash
curl.exe -s -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/users/switch-role/" \
  -H "ngrok-skip-browser-warning: 69420" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"role":"SPONSOR"}'
```

### 7.4 Golden cURL: Refresh JWT Token
```bash
curl.exe -s -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/token/refresh/" \
  -H "ngrok-skip-browser-warning: 69420" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"refresh":"<REFRESH_TOKEN>"}'
```
