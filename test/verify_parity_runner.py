import re
import os
import sys
import json

# Ensure UTF-8 output on Windows
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

def main():
    endpoints_file = r"d:\Ismail_flutter\julkar_vai\lib\core\constants\api_endpoints.dart"
    report_file = r"d:\Ismail_flutter\julkar_vai\BACKEND_API_AUDIT_REPORT.md"
    
    with open(endpoints_file, "r", encoding="utf-8") as f:
        endpoints_code = f.read()
        
    with open(report_file, "r", encoding="utf-8") as f:
        report_content = f.read()

    declarations = []
    
    # 1. baseUrl
    declarations.append({
        "type": "getter",
        "name": "baseUrl",
        "raw": "static String get baseUrl",
        "url_pattern": "https://clubby-andy-irksomely.ngrok-free.dev"
    })
    
    # 2. constants
    const_pattern = re.compile(r'static\s+const\s+String\s+(\w+)\s*=\s*"([^"]+)";')
    for m in const_pattern.finditer(endpoints_code):
        declarations.append({
            "type": "const",
            "name": m.group(1),
            "raw": m.group(0),
            "url_pattern": m.group(2)
        })
        
    # 3. methods
    method_pattern = re.compile(r'static\s+String\s+(\w+)\s*\(([^)]*)\)\s*(?:=>\s*"([^"]+)"|\{([\s\S]*?)\})')
    for m in method_pattern.finditer(endpoints_code):
        name = m.group(1)
        params = m.group(2)
        expr = m.group(3)
        body = m.group(4)
        declarations.append({
            "type": "method",
            "name": name,
            "params": params,
            "expr": expr if expr else "block",
            "body": body.strip() if body else "",
            "url_pattern": expr if expr else "dynamic"
        })

    print(f"Total ApiEndpoints members extracted: {len(declarations)}")
    
    results = []
    missing = []
    
    for item in declarations:
        name = item["name"]
        item_type = item["type"]
        
        search_tokens = []
        if item_type == "const":
            url = item["url_pattern"]
            search_tokens.append(url)
            search_tokens.append(url.rstrip("/"))
            search_tokens.append(name)
        elif item_type == "getter":
            search_tokens.append("baseUrl")
            search_tokens.append(item["url_pattern"])
        elif item_type == "method":
            search_tokens.append(name)
            expr = item.get("expr", "")
            if expr and expr != "block":
                # Convert interpolation like "/api/v1/profiles/${role.toLowerCase()}/onboarding/"
                # into clean search fragments
                clean_expr = re.sub(r'(\$\{[^}]+\}|\$[a-zA-Z0-9_]+)', '{id}', expr)
                search_tokens.append(clean_expr)
                parts = re.split(r'\{id\}', clean_expr)
                for p in parts:
                    if len(p) >= 4:
                        search_tokens.append(p)
            elif name == "chatWebSocket":
                search_tokens.append("/ws/chat/")
                search_tokens.append("chatWebSocket")

        matched_tokens = []
        matched_lines = []
        for line_num, line in enumerate(report_content.splitlines(), 1):
            line_matched = False
            for token in search_tokens:
                if token.lower() in line.lower():
                    if token not in matched_tokens:
                        matched_tokens.append(token)
                    line_matched = True
            if line_matched:
                # Remove emojis for safe formatting
                clean_line = re.sub(r'[^\x00-\x7F]+', ' ', line.strip())
                matched_lines.append((line_num, clean_line))
                    
        is_audited = len(matched_tokens) > 0
        res_record = {
            "name": name,
            "type": item_type,
            "url_pattern": item.get("url_pattern", ""),
            "search_tokens": search_tokens,
            "is_audited": is_audited,
            "matched_tokens": matched_tokens,
            "match_count": len(matched_lines),
            "sample_match": matched_lines[0] if matched_lines else None
        }
        results.append(res_record)
        if not is_audited:
            missing.append(res_record)

    print("\n=======================================================")
    print("      API ENDPOINTS PARITY VERIFICATION REPORT         ")
    print("=======================================================")
    print(f"Total declarations in ApiEndpoints: {len(results)}")
    print(f"Total successfully verified in report: {len(results) - len(missing)}")
    print(f"Missing from audit report: {len(missing)}")
    print("-------------------------------------------------------")
    
    if missing:
        print("FAIL: The following endpoints are missing from BACKEND_API_AUDIT_REPORT.md:")
        for m in missing:
            print(f"  - {m['name']} ({m['type']})")
        sys.exit(1)
    else:
        print("SUCCESS: 100% of ApiEndpoints constants & methods are accounted for!")

    print("\nDetailed breakdown of all 65 members:")
    print(f"{'No':<3} | {'Member Name':<32} | {'Type':<7} | {'Audited?':<8} | {'Matches':<7} | First Report Reference")
    print("-" * 110)
    for idx, r in enumerate(results, 1):
        status_str = "VERIFIED" if r["is_audited"] else "MISSING"
        sample = f"L{r['sample_match'][0]}: {r['sample_match'][1][:55]}" if r['sample_match'] else "None"
        print(f"{idx:<3} | {r['name']:<32} | {r['type']:<7} | {status_str:<8} | {r['match_count']:<7} | {sample}")

    # Also output json summary
    output_summary = {
        "total_declared": len(results),
        "total_verified": len(results) - len(missing),
        "total_missing": len(missing),
        "verdict": "APPROVE" if len(missing) == 0 else "CHALLENGE_FAILED",
        "items": [
            {
                "index": idx,
                "name": r["name"],
                "type": r["type"],
                "url_pattern": r["url_pattern"],
                "verified": r["is_audited"],
                "matches_in_report": r["match_count"],
                "first_ref_line": r["sample_match"][0] if r["sample_match"] else None
            }
            for idx, r in enumerate(results, 1)
        ]
    }
    
    with open(r"d:\Ismail_flutter\julkar_vai\test\parity_verification_results.json", "w", encoding="utf-8") as f:
        json.dump(output_summary, f, indent=2)

if __name__ == "__main__":
    main()
