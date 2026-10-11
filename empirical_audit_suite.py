import json
import subprocess
import sys
import urllib.request
import urllib.error

BASE_URL = "https://clubby-andy-irksomely.ngrok-free.dev"
EMAIL = "ismailshuvo555@gmail.com"
PASSWORD = "586908sH"

results = {}

def log(header):
    print(f"\n{'='*20} {header} {'='*20}")

def run_curl(args):
    cmd = ["curl.exe", "-s", "-i"] + args
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    return res.stdout

# 0. Initial Auth
log("STEP 0: AUTHENTICATION")
auth_payload = json.dumps({"email": EMAIL, "password": PASSWORD})
curl_auth = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/auth/login/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", "Content-Type: application/json",
    "-d", auth_payload
])
print("Login curl output (truncated header/body):")
lines = curl_auth.splitlines()
status_line = lines[0] if lines else "NO OUTPUT"
print("Status line:", status_line)

# Extract JSON body
body_idx = curl_auth.find("\r\n\r\n")
if body_idx == -1:
    body_idx = curl_auth.find("\n\n")
body_str = curl_auth[body_idx:].strip() if body_idx != -1 else ""
auth_data = json.loads(body_str)
access_token = auth_data["access"]
refresh_token = auth_data["refresh"]
current_role = auth_data["user"]["role"]
print(f"Authenticated! User ID: {auth_data['user']['id']}, Role: {current_role}, Token: {access_token[:15]}...")

results["login"] = {
    "status_line": status_line,
    "user_id": auth_data["user"]["id"],
    "initial_role": current_role
}

# 1. Claim 1: POST /api/v1/users/change-password/ with invalid current password
log("CLAIM 1: POST /api/v1/users/change-password/ WITH INVALID CURRENT PASSWORD")
pw_payload = json.dumps({
    "current_password": "WrongPassword123!",
    "new_password": "NewPassword123!"
})
curl_pw = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/users/change-password/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {access_token}",
    "-H", "Content-Type: application/json",
    "-d", pw_payload
])
print("Raw curl response:")
print(curl_pw)
pw_lines = curl_pw.splitlines()
pw_status = pw_lines[0] if pw_lines else ""
pw_body_idx = curl_pw.find("\r\n\r\n") if "\r\n\r\n" in curl_pw else curl_pw.find("\n\n")
pw_body = curl_pw[pw_body_idx:].strip() if pw_body_idx != -1 else ""

results["claim_1_change_password"] = {
    "curl_status_line": pw_status,
    "curl_body": pw_body
}

# 2. Claim 2: GET /api/v1/investor/investments/ (404) vs GET /api/v1/projects/investor/investments/ (200)
# First ensure we have INVESTOR role active
log("ENSURING INVESTOR ROLE FOR CLAIM 2")
curl_switch_inv = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/users/switch-role/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {access_token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps({"role": "INVESTOR"})
])
print(curl_switch_inv.splitlines()[0])
try:
    s_idx = curl_switch_inv.find("\r\n\r\n") if "\r\n\r\n" in curl_switch_inv else curl_switch_inv.find("\n\n")
    s_json = json.loads(curl_switch_inv[s_idx:].strip())
    if "data" in s_json and s_json["data"] and "access" in s_json["data"]:
        access_token = s_json["data"]["access"]
        print("Updated access_token to fresh INVESTOR token")
except Exception as e:
    print(f"Note on switch response: {e}")

log("CLAIM 2A: GET /api/v1/investor/investments/ (REPORT CLAIMS 404)")
curl_inv_404 = run_curl([
    "-X", "GET", f"{BASE_URL}/api/v1/investor/investments/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {access_token}"
])
inv_404_lines = curl_inv_404.splitlines()
inv_404_status = inv_404_lines[0] if inv_404_lines else ""
print("Status line:", inv_404_status)
print("Is HTML Django 404 traceback?", "The current path, <code>api/v1/investor/investments/</code>, didn’t match any of these" in curl_inv_404)

results["claim_2a_investor_investments"] = {
    "status_line": inv_404_status,
    "is_html_django_404": "The current path, <code>api/v1/investor/investments/</code>, didn’t match any of these" in curl_inv_404
}

log("CLAIM 2B: GET /api/v1/projects/investor/investments/ (REPORT CLAIMS 200 OK)")
curl_inv_200 = run_curl([
    "-X", "GET", f"{BASE_URL}/api/v1/projects/investor/investments/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {access_token}"
])
inv_200_lines = curl_inv_200.splitlines()
inv_200_status = inv_200_lines[0] if inv_200_lines else ""
print("Status line:", inv_200_status)
inv_200_b_idx = curl_inv_200.find("\r\n\r\n") if "\r\n\r\n" in curl_inv_200 else curl_inv_200.find("\n\n")
inv_200_body = curl_inv_200[inv_200_b_idx:].strip() if inv_200_b_idx != -1 else ""
print("Body:", inv_200_body[:200] + "...")

results["claim_2b_projects_investor_investments"] = {
    "status_line": inv_200_status,
    "body_snippet": inv_200_body[:300]
}

# 3. Claim 4: Role switch POST /api/v1/users/switch-role/
log("CLAIM 4A: SWITCH ROLE TO SPONSOR (FRESH ROLE SWITCH)")
curl_switch_spo = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/users/switch-role/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {access_token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps({"role": "SPONSOR"})
])
spo_lines = curl_switch_spo.splitlines()
spo_status = spo_lines[0] if spo_lines else ""
print("Status line:", spo_status)
spo_b_idx = curl_switch_spo.find("\r\n\r\n") if "\r\n\r\n" in curl_switch_spo else curl_switch_spo.find("\n\n")
spo_body = curl_switch_spo[spo_b_idx:].strip() if spo_b_idx != -1 else ""
print("Body:", spo_body[:300] + "...")
spo_data = json.loads(spo_body)
sponsor_token = access_token
if "data" in spo_data and spo_data["data"] and "access" in spo_data["data"]:
    sponsor_token = spo_data["data"]["access"]
    print("Obtained fresh SPONSOR token!")

results["claim_4a_switch_to_sponsor"] = {
    "status_line": spo_status,
    "has_data_block": "data" in spo_data and spo_data["data"] is not None,
    "has_new_access_token": "data" in spo_data and bool(spo_data.get("data", {}).get("access"))
}

log("CLAIM 4B: SWITCH ROLE TO SPONSOR AGAIN (IDEMPOTENT CALL)")
curl_switch_spo_again = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/users/switch-role/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {sponsor_token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps({"role": "SPONSOR"})
])
spo_again_lines = curl_switch_spo_again.splitlines()
spo_again_status = spo_again_lines[0] if spo_again_lines else ""
print("Status line:", spo_again_status)
spo_again_b_idx = curl_switch_spo_again.find("\r\n\r\n") if "\r\n\r\n" in curl_switch_spo_again else curl_switch_spo_again.find("\n\n")
spo_again_body = curl_switch_spo_again[spo_again_b_idx:].strip() if spo_again_b_idx != -1 else ""
print("Body:", spo_again_body)
spo_again_json = json.loads(spo_again_body)

results["claim_4b_switch_idempotent"] = {
    "status_line": spo_again_status,
    "body": spo_again_body,
    "data_field_omitted": "data" not in spo_again_json or spo_again_json["data"] is None,
    "message": spo_again_json.get("message")
}

# 4. Claim 3: POST /api/v1/projects/sponsor/ JSON vs Multipart
log("CLAIM 3A: POST /api/v1/projects/sponsor/ WITH JSON (REPORT CLAIMS 415)")
curl_proj_json = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/projects/sponsor/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {sponsor_token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps({"title": "Solar Deal", "target_return": 18.5, "project_duration_months": 24})
])
proj_json_lines = curl_proj_json.splitlines()
proj_json_status = proj_json_lines[0] if proj_json_lines else ""
print("Status line:", proj_json_status)
proj_json_b_idx = curl_proj_json.find("\r\n\r\n") if "\r\n\r\n" in curl_proj_json else curl_proj_json.find("\n\n")
proj_json_body = curl_proj_json[proj_json_b_idx:].strip() if proj_json_b_idx != -1 else ""
print("Body:", proj_json_body)

results["claim_3a_project_json"] = {
    "status_line": proj_json_status,
    "body": proj_json_body
}

log("CLAIM 3B: POST /api/v1/projects/sponsor/ WITH MULTIPART (REPORT CLAIMS 201 CREATED)")
curl_proj_multi = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/projects/sponsor/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {sponsor_token}",
    "-F", "title=Challenger Audit Empirical Deal",
    "-F", "short_description=High-yield testing of multipart endpoint.",
    "-F", "business_description=Renewable test project.",
    "-F", "funding_goal=150000.00",
    "-F", "minimum_investment=2500.00",
    "-F", "target_roi=16.5",
    "-F", "timeline_months=18",
    "-F", "location=Dhaka, Bangladesh"
])
proj_multi_lines = curl_proj_multi.splitlines()
proj_multi_status = proj_multi_lines[0] if proj_multi_lines else ""
print("Status line:", proj_multi_status)
proj_multi_b_idx = curl_proj_multi.find("\r\n\r\n") if "\r\n\r\n" in curl_proj_multi else curl_proj_multi.find("\n\n")
proj_multi_body = curl_proj_multi[proj_multi_b_idx:].strip() if proj_multi_b_idx != -1 else ""
print("Body:", proj_multi_body[:300] + "...")

results["claim_3b_project_multipart"] = {
    "status_line": proj_multi_status,
    "body_snippet": proj_multi_body[:300]
}

# Cleanup: Restore role to INVESTOR
log("CLEANUP: RESTORING ROLE TO INVESTOR")
curl_restore = run_curl([
    "-X", "POST", f"{BASE_URL}/api/v1/users/switch-role/",
    "-H", "ngrok-skip-browser-warning: 69420",
    "-H", f"Authorization: Bearer {sponsor_token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps({"role": "INVESTOR"})
])
print("Restore Status:", curl_restore.splitlines()[0] if curl_restore else "")

with open("d:/Ismail_flutter/julkar_vai/empirical_audit_results.json", "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2)

log("ALL EMPIRICAL TESTS COMPLETE. RESULTS WRITTEN TO empirical_audit_results.json")
