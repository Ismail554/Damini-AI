import json
import urllib.request
import urllib.error
import ssl
import sys

BASE_URL = "https://clubby-andy-irksomely.ngrok-free.dev"
EMAIL = "ismailshuvo555@gmail.com"
PASSWORD = "586908sH"

ctx = ssl.create_default_context()

def send_request(method, path, headers=None, body=None):
    url = f"{BASE_URL}{path}"
    req_headers = {
        "ngrok-skip-browser-warning": "69420",
        "User-Agent": "VictoryAuditor/1.0",
    }
    if headers:
        req_headers.update(headers)
    
    data = None
    if body is not None:
        if isinstance(body, (dict, list)):
            data = json.dumps(body).encode("utf-8")
            if "Content-Type" not in req_headers:
                req_headers["Content-Type"] = "application/json"
        elif isinstance(body, str):
            data = body.encode("utf-8")
        elif isinstance(body, bytes):
            data = body
            
    req = urllib.request.Request(url, data=data, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
            resp_body = resp.read().decode("utf-8", errors="replace")
            return {
                "status_code": resp.status,
                "headers": dict(resp.headers),
                "body": resp_body
            }
    except urllib.error.HTTPError as e:
        resp_body = e.read().decode("utf-8", errors="replace")
        return {
            "status_code": e.code,
            "headers": dict(e.headers),
            "body": resp_body
        }
    except Exception as e:
        return {
            "status_code": 0,
            "error": str(e),
            "body": ""
        }

def run_audit():
    print(f"[*] Starting Independent Victory Probes against {BASE_URL}...")
    report = {}

    # Probe 1: Public Banners
    p_banners = send_request("GET", "/api/v1/banners/")
    print(f"[1] GET /api/v1/banners/ -> {p_banners['status_code']}")
    report["banners"] = p_banners

    # Probe 2: Public Projects
    p_proj = send_request("GET", "/api/v1/projects/")
    print(f"[2] GET /api/v1/projects/ -> {p_proj['status_code']}")
    report["public_projects"] = p_proj

    # Probe 3: Authentication
    p_login = send_request("POST", "/api/v1/auth/login/", body={"email": EMAIL, "password": PASSWORD})
    print(f"[3] POST /api/v1/auth/login/ -> {p_login['status_code']}")
    report["login"] = p_login

    if p_login["status_code"] != 200:
        print("[!] Login failed! Cannot proceed with protected probes.")
        return report

    login_json = json.loads(p_login["body"])
    access_token = login_json["access"]
    auth_header = {"Authorization": f"Bearer {access_token}"}
    print(f"[*] Acquired token for User {login_json['user']['id']} (Current role: {login_json['user']['role']})")

    # Probe 4: Issue 1 — Change password crash with invalid current password
    p_pw = send_request(
        "POST",
        "/api/v1/users/change-password/",
        headers=auth_header,
        body={"current_password": "WrongPassword123!", "new_password": "NewPassword123!"}
    )
    print(f"[4] Issue 1: POST /api/v1/users/change-password/ (Invalid Password) -> {p_pw['status_code']} (Expected: 500)")
    report["issue_1_change_password_500"] = p_pw

    # Probe 5: Issue 2 — AI Wizard Start Crash
    p_ai = send_request(
        "POST",
        "/api/v1/ai/projects/conversations/",
        headers=auth_header,
        body={"initial_context": "Creating tech startup"}
    )
    print(f"[5] Issue 2: POST /api/v1/ai/projects/conversations/ -> {p_ai['status_code']} (Expected: 500)")
    report["issue_2_ai_wizard_500"] = p_ai

    # Probe 6: Issue 4 — Client declared investor investments route
    p_inv_declared = send_request(
        "GET",
        "/api/v1/investor/investments/",
        headers=auth_header
    )
    print(f"[6] Issue 4: GET /api/v1/investor/investments/ -> {p_inv_declared['status_code']} (Expected: 404)")
    report["issue_4_investor_investments_declared"] = p_inv_declared

    # Probe 7: Issue 4 — Working backend route for investor investments
    p_inv_actual = send_request(
        "GET",
        "/api/v1/projects/investor/investments/",
        headers=auth_header
    )
    print(f"[7] Issue 4 (Fix): GET /api/v1/projects/investor/investments/ -> {p_inv_actual['status_code']} (Expected: 200)")
    report["issue_4_investor_investments_actual"] = p_inv_actual

    # Probe 8: Issue 6 — Client declared sponsor onboarding route
    p_spo_onb = send_request(
        "GET",
        "/api/v1/profiles/sponsor/onboarding/",
        headers=auth_header
    )
    print(f"[8] Issue 6: GET /api/v1/profiles/sponsor/onboarding/ -> {p_spo_onb['status_code']} (Expected: 404)")
    report["issue_6_sponsor_onboarding_declared"] = p_spo_onb

    # Probe 9: Issue 6 — Working backend route for sponsor onboarding profile
    p_spo_prof = send_request(
        "GET",
        "/api/v1/profiles/sponsor/",
        headers=auth_header
    )
    print(f"[9] Issue 6 (Fix): GET /api/v1/profiles/sponsor/ -> {p_spo_prof['status_code']} (Expected: 200)")
    report["issue_6_sponsor_profile_actual"] = p_spo_prof

    # Probe 10: Switch Role to SPONSOR
    p_switch_spo = send_request(
        "POST",
        "/api/v1/users/switch-role/",
        headers=auth_header,
        body={"role": "SPONSOR"}
    )
    print(f"[10] POST /api/v1/users/switch-role/ (to SPONSOR) -> {p_switch_spo['status_code']}")
    report["switch_role_to_sponsor"] = p_switch_spo

    spo_token = access_token
    try:
        sw_json = json.loads(p_switch_spo["body"])
        if "data" in sw_json and sw_json["data"] and "access" in sw_json["data"]:
            spo_token = sw_json["data"]["access"]
    except Exception:
        pass

    spo_auth = {"Authorization": f"Bearer {spo_token}"}

    # Probe 11: Idempotent switch-role call (missing data block)
    p_switch_idem = send_request(
        "POST",
        "/api/v1/users/switch-role/",
        headers=spo_auth,
        body={"role": "SPONSOR"}
    )
    print(f"[11] POST /api/v1/users/switch-role/ (Idempotent SPONSOR) -> {p_switch_idem['status_code']} (Body: {p_switch_idem['body']})")
    report["switch_role_idempotent"] = p_switch_idem

    # Probe 12: Issue 7 — Project creation with JSON (415 Media Type Rejection)
    p_proj_json = send_request(
        "POST",
        "/api/v1/projects/sponsor/",
        headers=spo_auth,
        body={"title": "Audit Deal", "target_roi": 15.0, "timeline_months": 12}
    )
    print(f"[12] Issue 7: POST /api/v1/projects/sponsor/ (with JSON) -> {p_proj_json['status_code']} (Expected: 415)")
    report["issue_7_project_json_415"] = p_proj_json

    # Probe 13: Sign NDA with JSON (415 Media Type Rejection)
    p_nda_json = send_request(
        "POST",
        "/api/v1/projects/4/sign-nda/",
        headers=spo_auth,
        body={"digital_signature": "Ismail Hosen"}
    )
    print(f"[13] POST /api/v1/projects/4/sign-nda/ (with JSON) -> {p_nda_json['status_code']} (Expected: 415)")
    report["sign_nda_json_415"] = p_nda_json

    # Restore role back to INVESTOR
    p_restore = send_request(
        "POST",
        "/api/v1/users/switch-role/",
        headers=spo_auth,
        body={"role": "INVESTOR"}
    )
    print(f"[14] Cleanup: Switch role back to INVESTOR -> {p_restore['status_code']}")

    with open(r"d:\Ismail_flutter\julkar_vai\.agents\teamwork\victory_auditor_1\independent_victory_probe_results.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print("[*] Successfully recorded all independent probe results to independent_victory_probe_results.json!")

if __name__ == "__main__":
    run_audit()
