import os
import re
import json

base_dir = r"d:\Ismail_flutter\julkar_vai"
api_file = os.path.join(base_dir, "lib", "core", "constants", "api_endpoints.dart")

with open(os.path.join(base_dir, ".agents", "teamwork", "explorer_client_survey_1", "endpoint_usage.json"), 'r', encoding='utf-8') as f:
    endpoints = json.load(f)

# For each endpoint, let's find the files where it's used.
# Let's inspect the context around the line in each file.

detailed_results = []

for ep in endpoints:
    name = ep['name']
    kind = ep['kind']
    val = ep['value']
    usages = ep['usages']
    repo_usages = ep['repo_usages']

    call_details = []
    for u in usages:
        fpath = os.path.join(base_dir, u['file'])
        with open(fpath, 'r', encoding='utf-8', errors='ignore') as fp:
            flines = fp.readlines()
        
        lidx = u['line'] - 1
        # Grab surrounding lines (e.g. -20 to +40)
        start_l = max(0, lidx - 25)
        end_l = min(len(flines), lidx + 45)
        context_block = "".join(flines[start_l:end_l])
        
        # Check HTTP method
        http_method = "UNKNOWN"
        for m in ['post', 'get', 'put', 'patch', 'delete']:
            if re.search(r'\b_?apiService\.' + m + r'\b', context_block, re.I) or \
               re.search(r'\b_?dio\.' + m + r'\b', context_block, re.I):
                http_method = m.upper()
                break

        # Check for mock fallback in this block
        has_mock_fallback = "mock" in context_block.lower() or "Future.delayed" in context_block

        call_details.append({
            'file': u['file'],
            'line': u['line'],
            'http_method': http_method,
            'has_mock_fallback': has_mock_fallback,
            'code_snippet': flines[lidx].strip(),
            'context': context_block
        })
    
    detailed_results.append({
        'name': name,
        'kind': kind,
        'value': val,
        'total_usages': len(usages),
        'repo_usages_count': len(repo_usages),
        'calls': call_details
    })

out_path = os.path.join(base_dir, ".agents", "teamwork", "explorer_client_survey_1", "detailed_calls.json")
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(detailed_results, f, indent=2)

print(f"Generated detailed_calls.json for {len(detailed_results)} endpoints.")
