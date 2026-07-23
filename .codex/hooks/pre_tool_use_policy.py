#!/usr/bin/env python3
"""Block repository operations that violate the one-file deletion policy."""

from __future__ import annotations

import json
import re
import sys
from typing import Any


def _bulk_delete_command(command: str) -> str | None:
    segments = re.split(r"[\r\n;|&]+", command)
    for raw_segment in segments:
        segment = raw_segment.strip()
        if not segment:
            continue

        if re.match(r"^(?:sudo\s+)?rm\b", segment, re.IGNORECASE):
            flags = re.findall(r"(?<!\S)-([A-Za-z]+)", segment)
            combined = "".join(flags).lower()
            if "r" in combined and "f" in combined:
                return "Blocked bulk deletion command: rm with recursive and force flags."

        if re.search(r"(?:^|[{(]\s*)Remove-Item\b", segment, re.IGNORECASE) and re.search(
            r"(?<!\S)-Recurse\b", segment, re.IGNORECASE
        ):
            return "Blocked bulk deletion command: Remove-Item -Recurse."

        if re.match(r"^(?:cmd(?:\.exe)?\s+/c\s+)?(?:del|rd|rmdir)\b", segment, re.IGNORECASE) and re.search(
            r"(?<!\S)/s\b", segment, re.IGNORECASE
        ):
            return "Blocked bulk deletion command using /s."

    return None


def _blocked_reason(payload: dict[str, Any]) -> str | None:
    tool_name = str(payload.get("tool_name", ""))
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return None

    command = tool_input.get("command")
    if not isinstance(command, str):
        return None

    if tool_name == "apply_patch":
        delete_count = len(re.findall(r"^\*\*\* Delete File:", command, re.MULTILINE))
        if delete_count > 1:
            return "Blocked patch that deletes more than one file. Delete one confirmed file at a time."
        return None

    if tool_name == "Bash":
        return _bulk_delete_command(command)

    return None


def _deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            },
            ensure_ascii=False,
        )
    )


def _self_test() -> int:
    blocked = [
        "rm -rf build",
        "rm -r -f build",
        'Remove-Item "C:\\temp\\build" -Recurse',
        "cmd /c rmdir /s build",
    ]
    allowed = [
        'Remove-Item "C:\\temp\\one.txt"',
        "rm one.txt",
        "Select-String -Pattern 'Remove-Item -Recurse' AGENTS.md",
        "Write-Output 'rm -rf is forbidden'",
    ]

    failures: list[str] = []
    for command in blocked:
        if _bulk_delete_command(command) is None:
            failures.append(f"expected block: {command}")
    for command in allowed:
        if _bulk_delete_command(command) is not None:
            failures.append(f"expected allow: {command}")

    patch_payload = {
        "tool_name": "apply_patch",
        "tool_input": {
            "command": "*** Begin Patch\n*** Delete File: a.txt\n*** Delete File: b.txt\n*** End Patch"
        },
    }
    if _blocked_reason(patch_payload) is None:
        failures.append("expected block: multi-file delete patch")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("pre_tool_use_policy self-test passed")
    return 0


def main() -> int:
    if "--self-test" in sys.argv:
        return _self_test()

    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError) as exc:
        print(f"Invalid hook input: {exc}", file=sys.stderr)
        return 1

    reason = _blocked_reason(payload)
    if reason:
        _deny(reason)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
