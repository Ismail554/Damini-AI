import json

with open("probe_results_raw.json", "r", encoding="utf-8") as f:
    data = json.load(f)

print(f"Total probes: {len(data)}")
by_status = {}
for item in data:
    status = item["status_code"]
    by_status[status] = by_status.get(status, 0) + 1

print("Status distribution:", sorted(by_status.items()))

print("\n--- 500 INTERNAL SERVER ERRORS ---")
for item in data:
    if item["status_code"] == 500:
        print(f"{item['method']} {item['path']}")
        print(f"Body sent: {item['body']}")
        print(f"Response: {json.dumps(item['response_body'], indent=2)[:500]}")
        print("-" * 50)

print("\n--- 404 NOT FOUND (ROUTE MISMATCHES) ---")
for item in data:
    if item["status_code"] == 404:
        print(f"{item['method']} {item['path']} | Notes: {item['notes']}")
        print("-" * 50)

print("\n--- 415 UNSUPPORTED MEDIA TYPE (MULTIPART REQUIREMENT) ---")
for item in data:
    if item["status_code"] == 415:
        print(f"{item['method']} {item['path']} | Notes: {item['notes']}")
        print(f"Response: {item['response_body']}")
        print("-" * 50)
