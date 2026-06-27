import os, re, json

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
LIB = os.path.join(ROOT, "lib")
TEST = os.path.join(ROOT, "test")

dart_files = []
for base in [LIB, TEST]:
    for r, d, files in os.walk(base):
        for f in files:
            if f.endswith(".dart"):
                dart_files.append(os.path.join(r, f))

import_re = re.compile(r"""^\s*import\s+['"]([^'"]+)['"](?:\s+as\s+(\w+))?(?:\s+show\s+[^;]+)?(?:\s+hide\s+[^;]+)?\s*;""", re.MULTILINE)
class_re = re.compile(r"""\bclass\s+(\w+)\b""")
enum_re = re.compile(r"""\benum\s+(\w+)\b""")
extension_re = re.compile(r"""\bextension\s+(?:on\s+)?(\w+)?\b""")
toplevel_fn_re = re.compile(r"""^(?:Future<[^>]*>|void|String|int|double|bool|[A-Z]\w*(?:<[^>]*>)?)\s+(\w+)\s*\(""", re.MULTILINE)
final_provider_re = re.compile(r"""^final\s+(\w+)\s*=""", re.MULTILINE)
typedef_re = re.compile(r"""\btypedef\s+(\w+)\b""")

records = {}
for path in dart_files:
    content = open(path, encoding="utf-8").read()
    rel = os.path.relpath(path, ROOT)
    imports = []
    for m in import_re.finditer(content):
        imports.append({"target": m.group(1), "alias": m.group(2)})
    classes = class_re.findall(content)
    enums = enum_re.findall(content)
    providers = final_provider_re.findall(content)
    typedefs = typedef_re.findall(content)
    records[rel] = {
        "path": path,
        "imports": imports,
        "classes": classes,
        "enums": enums,
        "providers": providers,
        "typedefs": typedefs,
    }

with open("/home/claude/audit/records.json", "w", encoding="utf-8") as f:
    json.dump(records, f, ensure_ascii=False, indent=2)

print(f"Parsed {len(dart_files)} dart files")
