import os
import sys
import json
import time
import requests

BASE_URL = "https://clubby-andy-irksomely.ngrok-free.dev"

DEFAULT_HEADERS = {
    "ngrok-skip-browser-warning": "69420",
    "Content-Type": "application/json",
    "Accept": "application/json"
}

EMAIL = "ismailshuvo555@gmail.com"
PASSWORD = "586908sH"

results = []
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
JSON_PATH = os.path.join(OUT_DIR, "probe_results_raw.json")

def safe_extract_first_id(resp_body, default="1"):
    try:
        if isinstance(resp_body, list) and len(resp_body) > 0:
            item = resp_body[0]
            if isinstance(item, dict):
                return str(item.get("id", default))
        elif isinstance(resp_body, dict):
            if "id" in resp_body:
                return str(resp_body["id"])
            if "conversation_id" in resp_body:
                return str(resp_body["conversation_id"])
            for key in ["results", "data", "conversations", "projects", "requests", "notifications"]:
                val = resp_body.get(key)
                if isinstance(val, list) and len(val) > 0:
                    item = val[0]
                    if isinstance(item, dict):
                        return str(item.get("id", default))
                elif isinstance(val, dict):
                    if "id" in val:
                        return str(val["id"])
                    if "conversation_id" in val:
                        return str(val["conversation_id"])
    except Exception:
        pass
    return default

def make_curl(method, url, headers=None, body=None):
    parts = ["curl.exe -s -i"]
    parts.append(f'-X {method.upper()}')
    parts.append(f'"{url}"')
    
    h = headers or DEFAULT_HEADERS
    for k, v in h.items():
        parts.append(f'-H "{k}: {v}"')
        
    if body is not None:
        if isinstance(body, (dict, list)):
            body_str = json.dumps(body)
            escaped_body = body_str.replace('"', '\\"')
            parts.append(f'-d "{escaped_body}"')
        else:
            parts.append(f'-d "{body}"')
            
    return " \\\n  ".join(parts)

def probe(name, method, path, headers=None, body=None, expected_status=None, notes="", category="General"):
    url = f"{BASE_URL}{path}"
    req_headers = dict(DEFAULT_HEADERS)
    if headers:
        req_headers.update(headers)
        
    curl_cmd = make_curl(method, url, req_headers, body)
    
    start_time = time.time()
    status_code = None
    response_body = None
    latency_ms = 0
    error_msg = None
    
    try:
        if method.upper() == "GET":
            resp = requests.get(url, headers=req_headers, timeout=20)
        elif method.upper() == "POST":
            if isinstance(body, (dict, list)):
                resp = requests.post(url, headers=req_headers, json=body, timeout=20)
            else:
                resp = requests.post(url, headers=req_headers, data=body, timeout=20)
        elif method.upper() == "PATCH":
            if isinstance(body, (dict, list)):
                resp = requests.patch(url, headers=req_headers, json=body, timeout=20)
            else:
                resp = requests.patch(url, headers=req_headers, data=body, timeout=20)
        elif method.upper() == "DELETE":
            resp = requests.delete(url, headers=req_headers, json=body if isinstance(body, (dict, list)) else None, timeout=20)
        else:
            resp = requests.request(method, url, headers=req_headers, timeout=20)
            
        latency_ms = int((time.time() - start_time) * 1000)
        status_code = resp.status_code
        try:
            response_body = resp.json()
        except Exception:
            response_body = resp.text[:1000]
    except Exception as e:
        latency_ms = int((time.time() - start_time) * 1000)
        error_msg = str(e)
        response_body = {"error": error_msg}
        status_code = 0

    verdict = "Working"
    if status_code >= 500 or status_code == 0:
        verdict = "Broken"
    elif status_code == 404:
        if "test if 404" in notes.lower() or "not found" in notes.lower() or "client declared path" in notes.lower() or "legacy" in notes.lower() or "dispatch path" in notes.lower():
            verdict = "Broken (404 Route Not Found)"
        else:
            verdict = "Broken (404 Not Found)"
    elif expected_status and status_code != expected_status:
        if status_code in (400, 401, 403, 404, 429):
            verdict = f"Status Divergence (Got {status_code}, Expected {expected_status})"
            
    record = {
        "name": name,
        "category": category,
        "method": method.upper(),
        "path": path,
        "url": url,
        "headers": req_headers,
        "body": body,
        "status_code": status_code,
        "latency_ms": latency_ms,
        "response_body": response_body,
        "curl_command": curl_cmd,
        "verdict": verdict,
        "notes": notes
    }
    results.append(record)
    
    # Save after each probe to prevent data loss
    try:
        with open(JSON_PATH, "w", encoding="utf-8") as f:
            json.dump(results, f, indent=2)
    except Exception as ex:
        print(f"Warning saving JSON: {ex}", flush=True)

    print(f"[{category}] {method.upper()} {path} -> {status_code} ({latency_ms}ms) [{verdict}]", flush=True)
    return record, response_body

def main():
    print("=== STARTING LIVE API PROBING SUITE ===", flush=True)
    
    # -------------------------------------------------------------
    # 1. PUBLIC & UNAUTHENTICATED ENDPOINTS
    # -------------------------------------------------------------
    probe(
        name="Public Banners List",
        method="GET",
        path="/api/v1/banners/",
        expected_status=200,
        notes="Dashboard carousel promotional banners. Publicly readable.",
        category="Public Endpoints"
    )
    
    probe(
        name="Public Projects List",
        method="GET",
        path="/api/v1/projects/",
        expected_status=200,
        notes="General projects discovery feed. Publicly readable without auth.",
        category="Public Endpoints"
    )

    probe(
        name="Unauthenticated Industries Taxonomy",
        method="GET",
        path="/api/v1/profiles/industries/",
        expected_status=401,
        notes="Rejects unauthenticated calls with 401 Unauthorized.",
        category="Public Endpoints"
    )
    
    probe(
        name="Unauthenticated Current User Me",
        method="GET",
        path="/api/v1/users/me/",
        expected_status=401,
        notes="Rejects unauthenticated calls with 401 Unauthorized.",
        category="Public Endpoints"
    )
    
    probe(
        name="Unauthenticated Discover Projects",
        method="GET",
        path="/api/v1/projects/discover/",
        expected_status=401,
        notes="Rejects unauthenticated calls with 401 Unauthorized.",
        category="Public Endpoints"
    )

    # -------------------------------------------------------------
    # 2. AUTHENTICATION & SESSION ENDPOINTS
    # -------------------------------------------------------------
    login_rec, login_body = probe(
        name="Standard Login - Valid Credentials",
        method="POST",
        path="/api/v1/auth/login/",
        body={"email": EMAIL, "password": PASSWORD},
        expected_status=200,
        notes="Dual-role test credentials. Expect 200 with JWT access, refresh, and user dictionary.",
        category="Auth Endpoints"
    )
    
    base_access_token = None
    base_refresh_token = None
    if isinstance(login_body, dict):
        base_access_token = login_body.get("access")
        base_refresh_token = login_body.get("refresh")
        
    probe(
        name="Standard Login - Invalid Password",
        method="POST",
        path="/api/v1/auth/login/",
        body={"email": EMAIL, "password": "WrongPassword123!"},
        expected_status=400,
        notes="Backend returns 400 Bad Request with {'status': 'error', 'message': 'Invalid email or password'}.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Token Refresh - Valid Refresh Token",
        method="POST",
        path="/api/v1/auth/token/refresh/",
        body={"refresh": base_refresh_token or "dummy"},
        expected_status=200,
        notes="Refreshes access and refresh tokens. Essential for AuthInterceptor.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Token Refresh - Invalid Refresh Token",
        method="POST",
        path="/api/v1/auth/token/refresh/",
        body={"refresh": "invalid_jwt_refresh_token_xyz"},
        expected_status=401,
        notes="Returns 401 with token invalid/expired error.",
        category="Auth Endpoints"
    )
    
    probe(
        name="User Registration - Valid New Payload",
        method="POST",
        path="/api/v1/auth/register/",
        body={
            "first_name": "Audit",
            "last_name": "Tester",
            "email": f"audit_probe_{int(time.time())}@braintech.test",
            "password": "Password99@Pass"
        },
        expected_status=201,
        notes="Registers new user and dispatches email OTP verification code.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Verify OTP - Invalid Code",
        method="POST",
        path="/api/v1/auth/verify-otp/",
        body={"email": EMAIL, "code": "000000"},
        expected_status=400,
        notes="Verifies 400 Bad Request error behavior on invalid/expired OTP.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Resend OTP",
        method="POST",
        path="/api/v1/auth/resend-otp/",
        body={"email": EMAIL},
        notes="Triggers OTP resend for email. Note: rate-limited or requires unverified status.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Forgot Password - Existing Email",
        method="POST",
        path="/api/v1/auth/forgot-password/",
        body={"email": EMAIL},
        notes="Requests password reset OTP to user email.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Reset Password - Invalid OTP Code",
        method="POST",
        path="/api/v1/auth/reset-password/",
        body={
            "email": EMAIL,
            "otp": "999999",
            "new_password": "NewSecretPass123!",
            "confirm_password": "NewSecretPass123!"
        },
        expected_status=400,
        notes="Attempts password reset with invalid OTP code. Verifies validation error.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Social Auth - Google Sign-In (Dummy Token)",
        method="POST",
        path="/api/v1/auth/google/",
        body={"id_token": "dummy_google_id_token_for_audit"},
        notes="Verifies endpoint exists and handles invalid Google OAuth tokens.",
        category="Auth Endpoints"
    )
    
    probe(
        name="Social Auth - Apple Sign-In (Dummy Token)",
        method="POST",
        path="/api/v1/auth/apple/",
        body={"id_token": "dummy_apple_identity_token_for_audit"},
        notes="Verifies endpoint exists and handles invalid Apple tokens.",
        category="Auth Endpoints"
    )
    
    # -------------------------------------------------------------
    # 3. INVESTOR ROLE FLOW & ENDPOINTS
    # -------------------------------------------------------------
    switch_inv_rec, switch_inv_body = probe(
        name="Switch Role to INVESTOR",
        method="POST",
        path="/api/v1/users/switch-role/",
        headers={"Authorization": f"Bearer {base_access_token}"},
        body={"role": "INVESTOR"},
        expected_status=200,
        notes="Switches active user session to INVESTOR mode and returns new JWT tokens.",
        category="Investor Endpoints"
    )
    
    inv_token = base_access_token
    if isinstance(switch_inv_body, dict) and "data" in switch_inv_body:
        inv_token = switch_inv_body["data"].get("access") or base_access_token
    inv_auth_header = {"Authorization": f"Bearer {inv_token}"}
    
    probe(
        name="Investor Current User Me",
        method="GET",
        path="/api/v1/users/me/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Fetches current user profile under INVESTOR context with investor stats.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Investor Current User (PATCH)",
        method="PATCH",
        path="/api/v1/users/me/",
        headers=inv_auth_header,
        body={"push_notifications_enabled": True},
        expected_status=200,
        notes="Updates top-level user settings like push notifications.",
        category="Investor Endpoints"
    )

    probe(
        name="Investor Industries List",
        method="GET",
        path="/api/v1/profiles/industries/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Taxonomy of industries used in onboarding and filters.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Investor Onboarding Profile (GET)",
        method="GET",
        path="/api/v1/profiles/investor/onboarding/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Retrieves investor onboarding status and preferences.",
        category="Investor Endpoints"
    )

    probe(
        name="Investor Onboarding Profile (PATCH)",
        method="PATCH",
        path="/api/v1/profiles/investor/onboarding/",
        headers=inv_auth_header,
        body={
            "investor_type": "INDIVIDUAL",
            "bio": "Accredited angel investor active in Tech & Real Estate.",
            "location": "Dhaka",
            "country": "Bangladesh"
        },
        expected_status=200,
        notes="Updates investor preferences and onboarding profile.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Projects Feed with Query Parameters",
        method="GET",
        path="/api/v1/projects/?category=&is_featured=true&is_trending=true",
        headers=inv_auth_header,
        expected_status=200,
        notes="Feed with featured and trending filters as called by Investor dashboard.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Discover Projects Route (/api/v1/projects/discover/)",
        method="GET",
        path="/api/v1/projects/discover/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Declared in ApiEndpoints.discoverProjects. Filtered project search.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Project Details (/api/v1/projects/1/)",
        method="GET",
        path="/api/v1/projects/1/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Detailed deal room view for project ID 1.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Toggle Save Project (/api/v1/projects/1/save/)",
        method="POST",
        path="/api/v1/projects/1/save/",
        headers=inv_auth_header,
        notes="Bookmarks or unbookmarks project ID 1.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Saved Projects List (/api/v1/projects/saved/)",
        method="GET",
        path="/api/v1/projects/saved/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Retrieves list of projects bookmarked by investor.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Sign NDA (/api/v1/projects/1/sign-nda/)",
        method="POST",
        path="/api/v1/projects/1/sign-nda/",
        headers=inv_auth_header,
        body={
            "full_name": "Ismail Hosen",
            "signature_date": "2026-10-11",
            "accepted_terms": True
        },
        notes="Signs non-disclosure agreement to unlock deal documents.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Create Collaboration Request (/api/v1/projects/1/requests/)",
        method="POST",
        path="/api/v1/projects/1/requests/",
        headers=inv_auth_header,
        body={
            "proposed_budget": 50000,
            "message": "Interested in participating in seed syndicate round."
        },
        notes="Submits collaboration / investment proposal to project sponsor.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Investor Investments - Client Declared Path (/api/v1/investor/investments/)",
        method="GET",
        path="/api/v1/investor/investments/",
        headers=inv_auth_header,
        notes="Declared in ApiEndpoints.investorInvestments. Testing whether this route exists or 404s.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Investor Investments - Backend OpenAPI Route (/api/v1/projects/investor/investments/)",
        method="GET",
        path="/api/v1/projects/investor/investments/",
        headers=inv_auth_header,
        notes="Actual backend route declared in OpenAPI for investor investment history.",
        category="Investor Endpoints"
    )

    probe(
        name="Investor Dashboard Summary (/api/v1/projects/investor/dashboard/)",
        method="GET",
        path="/api/v1/projects/investor/dashboard/",
        headers=inv_auth_header,
        notes="Investor dashboard summary metrics and status cards.",
        category="Investor Endpoints"
    )

    probe(
        name="Investor Portfolio Summary (/api/v1/projects/investor/portfolio-summary/)",
        method="GET",
        path="/api/v1/projects/investor/portfolio-summary/",
        headers=inv_auth_header,
        notes="Investor portfolio metrics.",
        category="Investor Endpoints"
    )

    probe(
        name="Investor My Requests (/api/v1/projects/investor/my-requests/)",
        method="GET",
        path="/api/v1/projects/investor/my-requests/",
        headers=inv_auth_header,
        notes="Investor outgoing collaboration requests list.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Public Member Profile (/api/v1/profiles/28/)",
        method="GET",
        path="/api/v1/profiles/28/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Fetches public profile view of user ID 28.",
        category="Investor Endpoints"
    )
    
    probe(
        name="Save Member Profile Self-Save Edge Case (/api/v1/profiles/28/save/)",
        method="POST",
        path="/api/v1/profiles/28/save/",
        headers=inv_auth_header,
        expected_status=400,
        notes="Attempting to bookmark own profile. Edge case spec mandates 400 Bad Request.",
        category="Investor Endpoints"
    )
    
    probe(
        name="List Saved Profiles (/api/v1/profiles/saved/)",
        method="GET",
        path="/api/v1/profiles/saved/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Fetches list of profiles bookmarked by user.",
        category="Investor Endpoints"
    )
    
    # AI Copilot Initial
    ai_init_rec, ai_init_body = probe(
        name="AI Copilot Initial Session (/api/v1/ai/chat/initial/)",
        method="GET",
        path="/api/v1/ai/chat/initial/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Retrieves initial AI welcome message, conversation ID, and suggested prompt chips.",
        category="AI Copilot Endpoints"
    )
    
    ai_conv_id = safe_extract_first_id(ai_init_body, "eac39a79-564d-4005-af66-4221899c52cb")
        
    probe(
        name=f"AI Copilot Send Message (/api/v1/ai/chat/conversations/{ai_conv_id}/messages/)",
        method="POST",
        path=f"/api/v1/ai/chat/conversations/{ai_conv_id}/messages/",
        headers=inv_auth_header,
        body={"content": "What are the most promising technology deals available?"},
        notes="Sends prompt to AI investment copilot and awaits response.",
        category="AI Copilot Endpoints"
    )
    
    probe(
        name=f"AI Copilot Message History (/api/v1/ai/chat/conversations/{ai_conv_id}/messages/)",
        method="GET",
        path=f"/api/v1/ai/chat/conversations/{ai_conv_id}/messages/",
        headers=inv_auth_header,
        notes="Retrieves conversation thread message history.",
        category="AI Copilot Endpoints"
    )

    probe(
        name=f"AI Copilot Clear Session (DELETE /api/v1/ai/chat/conversations/{ai_conv_id}/clear/)",
        method="DELETE",
        path=f"/api/v1/ai/chat/conversations/{ai_conv_id}/clear/",
        headers=inv_auth_header,
        notes="Clears conversation thread using DELETE method.",
        category="AI Copilot Endpoints"
    )

    probe(
        name=f"AI Copilot Clear Session (POST /api/v1/ai/chat/conversations/{ai_conv_id}/clear/)",
        method="POST",
        path=f"/api/v1/ai/chat/conversations/{ai_conv_id}/clear/",
        headers=inv_auth_header,
        notes="Clears conversation thread using POST method.",
        category="AI Copilot Endpoints"
    )

    # Chat Conversations List (Client path vs Backend path)
    probe(
        name="Chat Conversations - Client/Dispatch Path (/api/v1/chat/conversations/)",
        method="GET",
        path="/api/v1/chat/conversations/",
        headers=inv_auth_header,
        notes="Testing path without 'notifications' prefix.",
        category="Chat Endpoints"
    )
    
    chat_list_rec, chat_list_body = probe(
        name="Chat Conversations - Actual Backend Path (/api/v1/notifications/chat/conversations/)",
        method="GET",
        path="/api/v1/notifications/chat/conversations/",
        headers=inv_auth_header,
        notes="Full backend route for listing chat conversations.",
        category="Chat Endpoints"
    )
    
    first_chat_id = safe_extract_first_id(chat_list_body, "1")

    probe(
        name="Start Conversation - Client/Dispatch Path (/api/v1/chat/conversations/start/)",
        method="POST",
        path="/api/v1/chat/conversations/start/",
        headers=inv_auth_header,
        body={"target_user_id": 28},
        notes="Testing direct chat creation without 'notifications' prefix.",
        category="Chat Endpoints"
    )
    
    probe(
        name="Start Conversation - Actual Backend Path (/api/v1/notifications/chat/conversations/start/)",
        method="POST",
        path="/api/v1/notifications/chat/conversations/start/",
        headers=inv_auth_header,
        body={"target_user_id": 28},
        notes="Testing direct chat creation with notifications/chat/conversations/start/.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Chat Messages History (/api/v1/notifications/chat/conversations/{first_chat_id}/messages/)",
        method="GET",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/messages/",
        headers=inv_auth_header,
        notes="Fetches chronological chat messages for conversation.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Chat Send Message (/api/v1/notifications/chat/conversations/{first_chat_id}/messages/send/)",
        method="POST",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/messages/send/",
        headers=inv_auth_header,
        body={"message": "Hello from automated audit probe suite!"},
        notes="HTTP fallback message posting endpoint.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Mark Chat Conversation Read (/api/v1/notifications/chat/conversations/{first_chat_id}/read/)",
        method="POST",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/read/",
        headers=inv_auth_header,
        notes="Resets unread message counter for conversation.",
        category="Chat Endpoints"
    )

    # Notifications List
    notif_rec, notif_body = probe(
        name="Notifications List (/api/v1/notifications/)",
        method="GET",
        path="/api/v1/notifications/",
        headers=inv_auth_header,
        expected_status=200,
        notes="Retrieves user notifications list.",
        category="Notification Endpoints"
    )
    
    first_notif_id = safe_extract_first_id(notif_body, "1")

    probe(
        name="Mark Notification Read - Dispatch Path (/api/v1/notifications/read/)",
        method="POST",
        path="/api/v1/notifications/read/",
        headers=inv_auth_header,
        body={"id": first_notif_id},
        notes="Testing dispatch route /api/v1/notifications/read/.",
        category="Notification Endpoints"
    )

    probe(
        name=f"Mark Notification Read - Actual Path (/api/v1/notifications/{first_notif_id}/read/)",
        method="POST",
        path=f"/api/v1/notifications/{first_notif_id}/read/",
        headers=inv_auth_header,
        notes="Backend OpenAPI route with ID in path.",
        category="Notification Endpoints"
    )

    probe(
        name="Mark All Notifications Read (/api/v1/notifications/mark-all-read/)",
        method="POST",
        path="/api/v1/notifications/mark-all-read/",
        headers=inv_auth_header,
        notes="Marks all user notifications as read.",
        category="Notification Endpoints"
    )

    probe(
        name="Register FCM Device Token (/api/v1/notifications/device-token/)",
        method="POST",
        path="/api/v1/notifications/device-token/",
        headers=inv_auth_header,
        body={"token": "test_fcm_token_dummy_998877", "platform": "android"},
        notes="Registers FCM push notification token.",
        category="Notification Endpoints"
    )

    probe(
        name="Clear All Notifications (DELETE /api/v1/notifications/clear-all/)",
        method="DELETE",
        path="/api/v1/notifications/clear-all/",
        headers=inv_auth_header,
        notes="Flushes all notifications for user.",
        category="Notification Endpoints"
    )

    # -------------------------------------------------------------
    # 4. SPONSOR ROLE FLOW & ENDPOINTS
    # -------------------------------------------------------------
    switch_sp_rec, switch_sp_body = probe(
        name="Switch Role to SPONSOR",
        method="POST",
        path="/api/v1/users/switch-role/",
        headers=inv_auth_header,
        body={"role": "SPONSOR"},
        expected_status=200,
        notes="Switches active user session to SPONSOR mode and returns new JWT tokens.",
        category="Sponsor Endpoints"
    )
    
    sp_token = inv_token
    if isinstance(switch_sp_body, dict) and "data" in switch_sp_body:
        sp_token = switch_sp_body["data"].get("access") or inv_token
    sp_auth_header = {"Authorization": f"Bearer {sp_token}"}
    
    probe(
        name="Sponsor Current User Me",
        method="GET",
        path="/api/v1/users/me/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Fetches current user profile under SPONSOR context with sponsor stats.",
        category="Sponsor Endpoints"
    )
    
    probe(
        name="Sponsor Profile (GET /api/v1/profiles/sponsor/)",
        method="GET",
        path="/api/v1/profiles/sponsor/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Retrieves active sponsor profile.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor Profile (PATCH /api/v1/profiles/sponsor/)",
        method="PATCH",
        path="/api/v1/profiles/sponsor/",
        headers=sp_auth_header,
        body={
            "legal_company_name": "Global Ventures LLC",
            "position_title": "Executive Director",
            "location": "Dhaka",
            "country": "Bangladesh"
        },
        expected_status=200,
        notes="Updates active sponsor profile fields.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor Onboarding Client Declared Path (/api/v1/profiles/sponsor/onboarding/)",
        method="PATCH",
        path="/api/v1/profiles/sponsor/onboarding/",
        headers=sp_auth_header,
        body={
            "legal_company_name": "Global Ventures LLC",
            "location": "Dhaka"
        },
        notes="Declared by Flutter client ApiEndpoints.onboarding('sponsor'). Testing if route exists or 404s.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor NDA Configuration (GET /api/v1/profiles/sponsor/nda/)",
        method="GET",
        path="/api/v1/profiles/sponsor/nda/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Retrieves sponsor's active NDA terms and documents.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor NDA Configuration (POST /api/v1/profiles/sponsor/nda/)",
        method="POST",
        path="/api/v1/profiles/sponsor/nda/",
        headers=sp_auth_header,
        body={
            "title": "Standard Mutual Non-Disclosure Agreement",
            "confidentiality_terms": "All project data and financial disclosures remain strictly confidential.",
            "custom_clauses": "Governing jurisdiction: Delaware."
        },
        notes="Updates sponsor NDA terms.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor Verification Status (/api/v1/profiles/verification-status/)",
        method="GET",
        path="/api/v1/profiles/verification-status/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Checks KYC/KYB business verification status.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor Verification Status Alternate Route (/api/v1/profiles/sponsor/status/)",
        method="GET",
        path="/api/v1/profiles/sponsor/status/",
        headers=sp_auth_header,
        notes="Backend route declared in OpenAPI for sponsor status.",
        category="Sponsor Endpoints"
    )

    probe(
        name="Sponsor Projects List (/api/v1/projects/sponsor/)",
        method="GET",
        path="/api/v1/projects/sponsor/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Retrieves projects owned by authenticated sponsor.",
        category="Sponsor Endpoints"
    )

    draft_title = f"Audit Deal Room {int(time.time())}"
    create_proj_rec, create_proj_body = probe(
        name="Create Sponsor Project (/api/v1/projects/sponsor/)",
        method="POST",
        path="/api/v1/projects/sponsor/",
        headers=sp_auth_header,
        body={
            "title": draft_title,
            "business_description": "Comprehensive renewable clean energy venture expanding across South Asia.",
            "funding_goal": 250000.0,
            "minimum_investment": 5000.0,
            "target_return": 18.5,
            "project_duration_months": 24,
            "location": "Dhaka, Bangladesh",
            "category": "Clean Energy"
        },
        notes="Creates a new project draft for sponsor.",
        category="Sponsor Endpoints"
    )
    
    created_proj_id = safe_extract_first_id(create_proj_body, "5")
        
    probe(
        name=f"Update Sponsor Project (/api/v1/projects/sponsor/{created_proj_id}/)",
        method="PATCH",
        path=f"/api/v1/projects/sponsor/{created_proj_id}/",
        headers=sp_auth_header,
        body={
            "tagline": "Innovative solar-hybrid microgrid solutions."
        },
        notes="Updates details of sponsor project.",
        category="Sponsor Endpoints"
    )

    sp_req_rec, sp_req_body = probe(
        name="Sponsor Collaboration Requests List (/api/v1/projects/sponsor/requests/)",
        method="GET",
        path="/api/v1/projects/sponsor/requests/",
        headers=sp_auth_header,
        expected_status=200,
        notes="Retrieves all incoming collaboration proposals across sponsor's projects.",
        category="Sponsor Endpoints"
    )
    
    first_req_id = safe_extract_first_id(sp_req_body, "1")

    probe(
        name=f"Sponsor Project-Specific Requests (/api/v1/projects/sponsor/{created_proj_id}/requests/)",
        method="GET",
        path=f"/api/v1/projects/sponsor/{created_proj_id}/requests/",
        headers=sp_auth_header,
        notes="Retrieves collaboration proposals for a specific project.",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Approve Collaboration Request (/api/v1/projects/sponsor/requests/{first_req_id}/approve/)",
        method="POST",
        path=f"/api/v1/projects/sponsor/requests/{first_req_id}/approve/",
        headers=sp_auth_header,
        notes="Sponsor approves collaboration proposal.",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Reject Collaboration Request (/api/v1/projects/sponsor/requests/{first_req_id}/reject/)",
        method="POST",
        path=f"/api/v1/projects/sponsor/requests/{first_req_id}/reject/",
        headers=sp_auth_header,
        body={"reason": "Syndicate allocation is currently oversubscribed."},
        notes="Sponsor declines collaboration proposal.",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Record Fund Received (/api/v1/projects/sponsor/requests/{first_req_id}/fund-received/)",
        method="POST",
        path=f"/api/v1/projects/sponsor/requests/{first_req_id}/fund-received/",
        headers=sp_auth_header,
        body={
            "received_amount": 25000.0,
            "payment_reference": "WIRE-REF-99281923",
            "received_at": "2026-10-11T10:00:00Z"
        },
        notes="Sponsor acknowledges capital deployment / wire transfer receipt.",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Confirm Investors (/api/v1/projects/{created_proj_id}/confirm-investors/)",
        method="POST",
        path=f"/api/v1/projects/{created_proj_id}/confirm-investors/",
        headers=sp_auth_header,
        body={
            "confirmed_investor_ids": [28],
            "closing_date": "2026-10-31"
        },
        notes="Batch locks confirmed investors into deal syndicate.",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Terminate Project (/api/v1/projects/{created_proj_id}/terminate/)",
        method="POST",
        path=f"/api/v1/projects/{created_proj_id}/terminate/",
        headers=sp_auth_header,
        body={
            "reason": "Test project termination audit probe for verification."
        },
        notes="Terminates deal room with reason (minimum 10 characters).",
        category="Sponsor Endpoints"
    )

    probe(
        name=f"Chat Header - Dispatch Path (/api/v1/chat/conversations/{first_chat_id}/header/)",
        method="GET",
        path=f"/api/v1/chat/conversations/{first_chat_id}/header/",
        headers=sp_auth_header,
        notes="Testing dispatch route without 'notifications' prefix.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Chat Header - Actual Backend Path (/api/v1/notifications/chat/conversations/{first_chat_id}/header/)",
        method="GET",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/header/",
        headers=sp_auth_header,
        notes="Retrieves group chat metadata and avatar participant stack.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Leave Conversation - Dispatch Path (/api/v1/chat/conversations/{first_chat_id}/leave/)",
        method="POST",
        path=f"/api/v1/chat/conversations/{first_chat_id}/leave/",
        headers=sp_auth_header,
        notes="Testing dispatch route /api/v1/chat/conversations/{id}/leave/.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Leave Conversation - Actual Backend Path (/api/v1/notifications/chat/conversations/{first_chat_id}/leave/)",
        method="POST",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/leave/",
        headers=sp_auth_header,
        notes="Testing actual backend route. Note: creator leaving triggers 400 OWNER_CANNOT_LEAVE.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Report Conversation - Dispatch Path (/api/v1/chat/conversations/{first_chat_id}/report/)",
        method="POST",
        path=f"/api/v1/chat/conversations/{first_chat_id}/report/",
        headers=sp_auth_header,
        body={"reason": "Spam / unsolicited advertising", "description": "Suspicious promotion in syndicate room."},
        notes="Testing dispatch route /api/v1/chat/conversations/{id}/report/.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Report Conversation - Actual Backend Path (/api/v1/notifications/chat/conversations/{first_chat_id}/report/)",
        method="POST",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/report/",
        headers=sp_auth_header,
        body={"reason": "Spam / unsolicited advertising", "description": "Suspicious promotion in syndicate room."},
        notes="Testing actual backend route /api/v1/notifications/chat/conversations/{id}/report/.",
        category="Chat Endpoints"
    )

    probe(
        name=f"Chat Confirm Investors (/api/v1/notifications/chat/conversations/{first_chat_id}/confirm-investors/)",
        method="POST",
        path=f"/api/v1/notifications/chat/conversations/{first_chat_id}/confirm-investors/",
        headers=sp_auth_header,
        body={"investors": [28]},
        notes="Confirm investors from group chat app bar.",
        category="Chat Endpoints"
    )

    # Damini AI Project Wizard Endpoints
    ai_proj_rec, ai_proj_body = probe(
        name="AI Project Creation Wizard Start (/api/v1/ai/projects/conversations/)",
        method="POST",
        path="/api/v1/ai/projects/conversations/",
        headers=sp_auth_header,
        body={"initial_context": "Creating an agritech supply chain venture."},
        notes="Initializes Damini Advisor interactive project creation wizard.",
        category="AI Advisor Endpoints"
    )
    
    ai_proj_conv_id = safe_extract_first_id(ai_proj_body, "1")

    probe(
        name=f"AI Project Wizard Conversation State (/api/v1/ai/projects/conversations/{ai_proj_conv_id}/)",
        method="GET",
        path=f"/api/v1/ai/projects/conversations/{ai_proj_conv_id}/",
        headers=sp_auth_header,
        notes="Retrieves step state and wizard metadata.",
        category="AI Advisor Endpoints"
    )

    probe(
        name=f"AI Project Wizard Send Message (/api/v1/ai/projects/conversations/{ai_proj_conv_id}/messages/)",
        method="POST",
        path=f"/api/v1/ai/projects/conversations/{ai_proj_conv_id}/messages/",
        headers=sp_auth_header,
        body={"content": "The project will connect rural organic farmers with urban supermarket chains."},
        notes="Advances AI project wizard step.",
        category="AI Advisor Endpoints"
    )

    probe(
        name="Change Password - Validation Error Probe (/api/v1/users/change-password/)",
        method="POST",
        path="/api/v1/users/change-password/",
        headers=sp_auth_header,
        body={
            "current_password": "WrongCurrentPassword123!",
            "new_password": "NewSecretPassword9988!"
        },
        expected_status=400,
        notes="Probes change password endpoint with incorrect current password to verify routing and error handling without mutating active credentials.",
        category="Account Security Endpoints"
    )

    probe(
        name="Delete Account - Validation Error Probe (/api/v1/users/delete-account/)",
        method="POST",
        path="/api/v1/users/delete-account/",
        headers=sp_auth_header,
        body={
            "password": "WrongPasswordProbe123!",
            "confirmation": "DELETE"
        },
        expected_status=400,
        notes="Probes account deletion endpoint with wrong password to verify route existence and 400 Bad Request error handling without destroying user account.",
        category="Account Security Endpoints"
    )

    probe(
        name="Set Initial Role (/api/v1/profiles/set-role/)",
        method="POST",
        path="/api/v1/profiles/set-role/",
        headers=sp_auth_header,
        body={"role": "SPONSOR"},
        notes="Sets user persona role.",
        category="Account Security Endpoints"
    )

    # Final logout probe
    probe(
        name="User Logout (/api/v1/auth/logout/)",
        method="POST",
        path="/api/v1/auth/logout/",
        headers=sp_auth_header,
        body={"refresh": base_refresh_token or "dummy_token"},
        notes="Blacklists refresh token and closes session.",
        category="Auth Endpoints"
    )

    print(f"\n[COMPLETE] Successfully executed and recorded {len(results)} live endpoint probes!", flush=True)

if __name__ == "__main__":
    main()
