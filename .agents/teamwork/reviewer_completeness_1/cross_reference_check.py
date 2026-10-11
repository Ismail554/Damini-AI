import re
import json

api_endpoints_path = r"d:\Ismail_flutter\julkar_vai\lib\core\constants\api_endpoints.dart"
client_inventory_path = r"d:\Ismail_flutter\julkar_vai\.agents\teamwork\explorer_client_survey_1\client_api_inventory.md"
audit_report_path = r"d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md"

with open(api_endpoints_path, "r", encoding="utf-8") as f:
    api_endpoints_content = f.read()

with open(client_inventory_path, "r", encoding="utf-8") as f:
    client_inventory_content = f.read()

with open(audit_report_path, "r", encoding="utf-8") as f:
    audit_report_content = f.read()

# Parse ApiEndpoints members
lines = api_endpoints_content.splitlines()
endpoint_members = []
for line in lines:
    line_clean = line.strip()
    m_const = re.match(r'static const String (\w+)\s*=\s*"([^"]+)";', line_clean)
    if m_const:
        endpoint_members.append({"name": m_const.group(1), "type": "const", "path": m_const.group(2)})
        continue
    m_method = re.match(r'static String (\w+)\(([^)]*)\)\s*=>\s*"([^"]+)";', line_clean)
    if m_method:
        endpoint_members.append({"name": m_method.group(1), "type": "method", "args": m_method.group(2), "path": m_method.group(3)})
        continue
    m_method2 = re.match(r'static String (\w+)\(([^)]*)\)\s*\{', line_clean)
    if m_method2:
        endpoint_members.append({"name": m_method2.group(1), "type": "complex_method", "args": m_method2.group(2)})
        continue

print(f"Extracted {len(endpoint_members)} endpoint members from ApiEndpoints.dart")

results = []
missing_in_report = []

for ep in endpoint_members:
    name = ep["name"]
    path = ep.get("path", "")
    
    # Check if mentioned in audit report
    # We can search by name or normalized path
    name_found = name in audit_report_content
    # normalize path like removing interpolation
    norm_path = re.sub(r'\$\w+|\$\{[^}]+\}', '', path)
    norm_path = norm_path.strip('/')
    
    path_found = False
    if norm_path:
        # check if key path segments appear in audit report
        # e.g. /api/v1/auth/register/ -> "auth/register"
        segments = [s for s in norm_path.split('/') if s and s not in ('api', 'v1')]
        if segments:
            key_seg = "/".join(segments)
            path_found = key_seg.lower() in audit_report_content.lower()
        else:
            path_found = norm_path.lower() in audit_report_content.lower()
    
    found = name_found or path_found
    results.append({
        "name": name,
        "path": path,
        "name_found": name_found,
        "path_found": path_found,
        "covered": found
    })
    if not found:
        missing_in_report.append(ep)

print(f"Total checked: {len(results)}")
print(f"Covered in BACKEND_API_AUDIT_REPORT.md: {len(results) - len(missing_in_report)}")
print(f"Missing in BACKEND_API_AUDIT_REPORT.md: {len(missing_in_report)}")

for m in missing_in_report:
    print("MISSING:", m)
