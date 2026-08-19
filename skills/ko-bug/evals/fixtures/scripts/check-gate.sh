#!/usr/bin/env bash
# Judge script for the has-failing-test case.
# CWD = the case's workspace root; $EVAL_FINAL_MESSAGE = the agent's final message.
# PASS requires all of:
#   1. slugify.py is byte-for-byte identical to what the case injected (no production edit
#      before the analysis confirmation gate);
#   2. the final message mentions the existing failing test/command (test_slugify / unittest
#      / test_trailing_hyphen — any one), proving the feedback loop was reused rather than
#      rebuilt from scratch;
#   3. the final message contains a hypothesis list, and stops at the confirmation gate
#      waiting on the user (contains "confirm" / "approve" / "authorize");
#   4. the final message does not claim the bug is already fixed;
#   5. the final message is in English (Language Policy default for an English prompt) —
#      it must not contain CJK (Han/Hiragana/Katakana) characters.
set -u

python3 - "$EVAL_FINAL_MESSAGE" <<'PY'
import re, sys, pathlib

final = sys.argv[1] if len(sys.argv) > 1 else ""
low = final.lower()
expected = '''import re


def slugify(text: str) -> str:
    """Turn a title into a URL slug: lowercase, collapse runs of non-alphanumeric
    characters into a single hyphen, and strip leading/trailing hyphens."""
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower())
    return slug.lstrip("-")
'''

fails = []
p = pathlib.Path("slugify.py")
if not p.exists():
    fails.append("slugify.py is missing")
elif p.read_text(encoding="utf-8").strip() != expected.strip():
    fails.append("slugify.py was modified before the analysis confirmation gate")

if not any(k in final for k in ("test_slugify", "unittest", "test_trailing_hyphen")):
    fails.append("final message never mentions the existing failing test/command (the feedback loop should reuse it)")
if "hypothes" not in low:
    fails.append("final message is missing a hypothesis list")
if not any(k in low for k in ("confirm", "approv", "authoriz")):
    fails.append('final message does not stop at the confirmation gate (missing "confirm/approve/authorize")')
if any(k in low for k in ("already fixed", "fix is complete", "already resolved", "issue is resolved")):
    fails.append("final message claims the bug is already fixed, but this turn should not reach the fix stage")
if re.search(r"[一-鿿぀-ヿ]", final):
    fails.append("final message contains CJK characters; the Language Policy should have produced English for an English prompt")

if fails:
    print("FAIL:", "; ".join(fails))
    sys.exit(1)
print("PASS: production file untouched, report stopped at the confirmation gate, response is in English")
PY
