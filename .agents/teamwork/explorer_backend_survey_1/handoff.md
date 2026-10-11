# Handoff Report: Environment, Backend Connectivity & Probing Mechanics Survey

**Agent:** `explorer_backend_survey_1`  
**Working Directory:** `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\`  
**Milestone:** `backend_survey`  
**Handoff Type:** Hard  

---

## 1. Observation

1. **Environment Configuration:**
   - `.env` line 1: `BASE_URL=https://clubby-andy-irksomely.ngrok-free.dev`.
   - `lib/core/constants/api_endpoints.dart` line 11: fallback `return "https://clubby-andy-irksomely.ngrok-free.dev";`.
   - `.env` lines 2-10 contains active Firebase Project ID `damini-ai`, Google Client ID, Android/iOS Firebase API keys and App IDs.

2. **HTTP Client & Default Headers:**
   - `lib/core/services/dio_service.dart` lines 22-27:
     ```dart
     headers: const {
       'Content-Type': 'application/json',
       'Accept': 'application/json',
       'ngrok-skip-browser-warning': '69420',
       'User-Agent': 'Braintech-Mobile-App/1.0',
     }
     ```
   - `lib/core/services/dio_service.dart` lines 47-52 injects `_ngrokInterceptor` setting `options.headers['ngrok-skip-browser-warning'] = '69420'`.
   - `lib/core/services/dio_service.dart` line 39 enables `client.badCertificateCallback = (cert, host, port) => true;` in debug mode.
   - `lib/core/services/auth_interceptor.dart` lines 36-38, 59-63, 89-98 implements token attachment via `StorageService.getToken()` and a concurrency lock `_refreshCompleter` routing 401s to `POST /api/v1/auth/token/refresh/` with `refresh` token.

3. **Backend Live State & ngrok Behavior:**
   - Probing root without `ngrok-skip-browser-warning` with a browser User-Agent returned HTTP 200 with ngrok HTML interstitial: `ERR_NGROK_6024`.
   - Probing with `-H "ngrok-skip-browser-warning: true"` returned HTTP 404 from Daphne server displaying Django URLconf (`config.urls`) with `DEBUG = True`.
   - Probing `GET /api/schema/` returned HTTP 200 with the full OpenAPI 3.0 YAML spec (saved to `openapi_schema.yaml`, 85,356 bytes, 73 endpoints).
   - Probing `GET /api/v1/banners/` returned `HTTP/1.1 200 OK` with body `{"status":"success","data":[]}`.
   - Probing `GET /api/v1/projects/` returned `HTTP/1.1 200 OK` with body `{"success":true,"count":5,...}` containing 5 live active projects.
   - Probing `GET /api/v1/profiles/industries/` without token returned `HTTP/1.1 401 Unauthorized` with body `{"status":"error","message":"Authentication credentials were not provided."}`.

4. **Authentication, Credentials & Role Switching:**
   - Verified account provided and validated:
     - Email: `ismailshuvo555@gmail.com`
     - Password: `586908sH`
   - Probing `POST /api/v1/auth/login/` with these credentials returned `HTTP/1.1 200 OK`, returning user id 28 with role `SPONSOR`, JWT access and refresh tokens.
   - Probing `GET /api/v1/users/me/` with the access token returned HTTP 200 with user profile `Global Ventures LLC`, `verification_status: APPROVED`, and stats `projects: 5, requests: 3`.
   - Probing `POST /api/v1/users/switch-role/` with `{"role": "INVESTOR"}` returned `HTTP/1.1 200 OK`, `active_role: INVESTOR`, `is_onboarded: true`, issuing fresh access and refresh tokens.
   - Probing `POST /api/v1/users/switch-role/` with `{"role": "SPONSOR"}` returned `HTTP/1.1 200 OK`, switching back to `SPONSOR` and issuing fresh tokens.
   - Probing `POST /api/v1/auth/token/refresh/` with the refresh token returned `HTTP/1.1 200 OK` and a new access/refresh pair.
   - Probing `POST /api/v1/auth/register/` with fresh user data returned `HTTP/1.1 201 Created` with message `"Account created. Please check your email for the verification code."`.
   - Probing `POST /api/v1/auth/verify-otp/` with `"123456"` returned `HTTP/1.1 400 Bad Request` (`"Invalid or expired verification code."`).

---

## 2. Logic Chain

1. From Observation 1, both the runtime environment (`.env`) and default fallback in client code (`api_endpoints.dart`) target `https://clubby-andy-irksomely.ngrok-free.dev`.
2. From Observation 2, `DioService` and `AuthInterceptor` inject `ngrok-skip-browser-warning: 69420`, use `application/json`, and handle token refreshes via mutex locking.
3. From Observation 3, ngrok strictly intercepts non-curl User-Agents with an HTML warning page (`ERR_NGROK_6024`) unless `ngrok-skip-browser-warning` is included. With the header present, requests hit the live Daphne ASGI server.
4. From Observation 3 and 4, public endpoints (`/banners/`, `/projects/`) are accessible without authentication, whereas data/profile endpoints (`/industries/`, `/projects/discover/`) enforce JWT authentication (returning 401).
5. From Observation 4, the verified user `ismailshuvo555@gmail.com` (password `586908sH`) possesses pre-existing, fully initialized profiles for both `SPONSOR` (Approved company) and `INVESTOR` (Individual). Calling `POST /api/v1/users/switch-role/` allows instant switching between roles without registering new accounts or handling email OTP verification.
6. From Observation 4, fresh user registration triggers dynamic email-bound OTP verification, making dynamic registration unsuitable for automated blackbox probe scripts when an existing dual-role account is already available.

---

## 3. Caveats

1. The backend database has `ismailshuvo555@gmail.com` investor profile in `verification_status: PENDING` whereas the sponsor profile is `APPROVED`. Endpoints requiring an approved investor may behave differently from approved sponsors.
2. The ngrok tunnel hostname (`clubby-andy-irksomely.ngrok-free.dev`) is a free ngrok domain. If the ngrok agent restarts on the host machine, the URL may change or disconnect.
3. No automated backend email capture service (e.g. Mailhog, Mailcatcher) is publicly exposed to intercept OTP codes for arbitrary new emails.

---

## 4. Conclusion

1. The backend environment is completely functional and accessible at `https://clubby-andy-irksomely.ngrok-free.dev`.
2. All probing tools and cURL scripts MUST include the header:
   `ngrok-skip-browser-warning: 69420` (or `true`).
3. For live probing of protected Investor and Sponsor endpoints, workers must authenticate using:
   - Email: `ismailshuvo555@gmail.com`
   - Password: `586908sH`
   and toggle between roles via `POST /api/v1/users/switch-role/` with `{"role": "INVESTOR"}` or `{"role": "SPONSOR"}`.
4. The complete OpenAPI specification was captured in `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\openapi_schema.yaml`.
5. Full detailed findings are published in `d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_backend_survey_1\backend_survey.md`.

---

## 5. Verification Method

To independently verify these findings, run the following commands:

1. **Verify Backend Reachability & ngrok Bypass:**
   ```powershell
   curl.exe -i -s -H "ngrok-skip-browser-warning: true" "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/banners/"
   ```
   *Expected:* HTTP 200 OK with `{"status":"success","data":[]}`.

2. **Verify Dual-Role Test Login:**
   ```powershell
   curl.exe -i -s -H "ngrok-skip-browser-warning: true" -H "Content-Type: application/json" -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/auth/login/" -d '{\"email\":\"ismailshuvo555@gmail.com\",\"password\":\"586908sH\"}'
   ```
   *Expected:* HTTP 200 OK returning `access`, `refresh`, and `user.id: 28`.

3. **Verify Role Switch to INVESTOR:**
   ```powershell
   curl.exe -i -s -H "ngrok-skip-browser-warning: true" -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" -X POST "https://clubby-andy-irksomely.ngrok-free.dev/api/v1/users/switch-role/" -d '{\"role\":\"INVESTOR\"}'
   ```
   *Expected:* HTTP 200 OK with `data.active_role: "INVESTOR"` and fresh JWT tokens.
