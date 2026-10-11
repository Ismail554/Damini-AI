import re
import os
import json

base_dir = r"d:\Ismail_flutter\julkar_vai"
api_file = os.path.join(base_dir, "lib", "core", "constants", "api_endpoints.dart")

with open(api_file, 'r', encoding='utf-8') as f:
    api_content = f.read()

# Let's tokenize or extract comments, declarations, etc.
# We can normalize newlines within static declarations.

# Remove multi-line comments or parse line-by-line while tracking comments
lines = api_content.splitlines()

# Let's also capture comments above or beside each endpoint
entries = []
current_comment = []

# First let's extract all static members
# Join lines that belong to the same statement
statements = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    
    if stripped.startswith('//'):
        current_comment.append(stripped)
        i += 1
        continue
    
    if not stripped or stripped.startswith('import ') or stripped.startswith('class ') or stripped == '}':
        if not stripped:
            current_comment = []
        i += 1
        continue
        
    # Accumulate statement until ';' or '{ ... }'
    stmt = stripped
    comment_for_stmt = "\n".join(current_comment) if current_comment else ""
    current_comment = []
    
    if '{' in stmt and 'get baseUrl' in stmt:
        # baseUrl block
        depth = stmt.count('{') - stmt.count('}')
        while depth > 0 and i + 1 < len(lines):
            i += 1
            stmt += " " + lines[i].strip()
            depth += lines[i].count('{') - lines[i].count('}')
        statements.append((stmt, comment_for_stmt, i + 1))
        i += 1
        continue

    if '{' in stmt and 'chatWebSocket' in stmt:
        depth = stmt.count('{') - stmt.count('}')
        while depth > 0 and i + 1 < len(lines):
            i += 1
            stmt += " " + lines[i].strip()
            depth += lines[i].count('{') - lines[i].count('}')
        statements.append((stmt, comment_for_stmt, i + 1))
        i += 1
        continue

    while not stmt.endswith(';') and i + 1 < len(lines):
        i += 1
        stmt += " " + lines[i].strip()
    
    statements.append((stmt, comment_for_stmt, i + 1))
    i += 1

print(f"Total extracted statements: {len(statements)}")

parsed_entries = []
for stmt, comment, lno in statements:
    # static const String name = "...";
    m1 = re.match(r'static\s+const\s+String\s+([a-zA-Z0-9_]+)\s*=\s*["\']([^"\']+)["\'];', stmt)
    if m1:
        parsed_entries.append({
            'kind': 'const',
            'name': m1.group(1),
            'value': m1.group(2),
            'signature': f'static const String {m1.group(1)} = "{m1.group(2)}"',
            'comment': comment,
            'stmt': stmt
        })
        continue

    # static String name(...) => "...";
    m2 = re.match(r'static\s+String\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*=>\s*["\']?([^;]+)["\']?;', stmt)
    if m2:
        val = m2.group(3).strip('"\'; ')
        parsed_entries.append({
            'kind': 'method',
            'name': m2.group(1),
            'params': m2.group(2).strip(),
            'value': val,
            'signature': f'static String {m2.group(1)}({m2.group(2)}) => {val}',
            'comment': comment,
            'stmt': stmt
        })
        continue

    # static String get baseUrl { ... }
    m3 = re.match(r'static\s+String\s+get\s+([a-zA-Z0-9_]+)', stmt)
    if m3:
        parsed_entries.append({
            'kind': 'getter',
            'name': m3.group(1),
            'value': 'https://clubby-andy-irksomely.ngrok-free.dev (or dotenv)',
            'signature': f'static String get {m3.group(1)}',
            'comment': comment,
            'stmt': stmt
        })
        continue

    # static String chatWebSocket(...) { ... }
    m4 = re.match(r'static\s+String\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*\{', stmt)
    if m4:
        parsed_entries.append({
            'kind': 'block_method',
            'name': m4.group(1),
            'params': m4.group(2).strip(),
            'value': '$wsBase/ws/chat/$conversationId/?token=$token',
            'signature': f'static String {m4.group(1)}({m4.group(2)})',
            'comment': comment,
            'stmt': stmt
        })
        continue

    print(f"FAILED TO PARSE: {stmt}")

print(f"Total parsed entries: {len(parsed_entries)}")

# Now search dart files for usages
dart_files = []
for root, dirs, files in os.walk(os.path.join(base_dir, "lib")):
    for f in files:
        if f.endswith('.dart') and f != 'api_endpoints.dart':
            dart_files.append(os.path.join(root, f))

results = []
for entry in parsed_entries:
    name = entry['name']
    pattern = re.compile(r'\bApiEndpoints\.' + name + r'\b')
    usages = []
    for df in dart_files:
        rel_path = os.path.relpath(df, base_dir)
        with open(df, 'r', encoding='utf-8', errors='ignore') as fp:
            for lno, line in enumerate(fp, 1):
                if pattern.search(line):
                    usages.append({
                        'file': rel_path,
                        'line': lno,
                        'code': line.strip()
                    })
    
    repo_usages = [u for u in usages if 'repository' in u['file'].lower()]
    entry['total_usages'] = len(usages)
    entry['repo_usages_count'] = len(repo_usages)
    entry['usages'] = usages
    entry['repo_usages'] = repo_usages
    results.append(entry)

out_path = os.path.join(base_dir, ".agents", "teamwork", "explorer_client_survey_1", "endpoint_usage.json")
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2)

print(f"Saved {len(results)} items to {out_path}")

print("\n=== SUMMARY OF ALL APIENDPOINTS ===")
for r in results:
    stat = f"{r['repo_usages_count']} repo refs, {r['total_usages']} total refs"
    print(f"[{r['kind']:<12}] {r['name']:<32} = {r['value']:<50} ({stat})")
