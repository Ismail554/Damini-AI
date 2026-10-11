import os

base_dir = r"d:\Ismail_flutter\julkar_vai"

repo_files = []
for root, dirs, files in os.walk(os.path.join(base_dir, "lib")):
    for f in files:
        if "repo" in f.lower() and f.endswith(".dart"):
            repo_files.append(os.path.relpath(os.path.join(root, f), base_dir))

print(f"Total repo files: {len(repo_files)}")

for rf in sorted(repo_files):
    path = os.path.join(base_dir, rf)
    with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
        content = fp.read()
    has_api_endpoints = "ApiEndpoints" in content
    has_api_service = "ApiService" in content
    has_dio = "Dio" in content
    has_mock = "mock" in content.lower() or "Future.delayed" in content
    has_shared_prefs = "SharedPreferences" in content
    
    print(f"{rf}:")
    print(f"  ApiEndpoints: {has_api_endpoints}, ApiService: {has_api_service}, Dio: {has_dio}, Mock/Delay: {has_mock}, SharedPrefs: {has_shared_prefs}")
