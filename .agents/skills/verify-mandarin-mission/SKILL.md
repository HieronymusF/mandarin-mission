---
name: verify-mandarin-mission
description: Select and run risk-matched verification for Mandarin Mission changes. Use after editing Flutter mobile code, pure Dart learning rules, course content or assets, the Go API, repository automation, or project documentation; also use before committing, pushing, opening a PR, or claiming a task is complete.
---

# Verify Mandarin Mission

Verify the user-visible result and the closest technical risks without automatically running every expensive check.

## Select the scope

Inspect `git status -sb` and the task diff before running commands.

| Changed area | Minimum scope |
| --- | --- |
| `apps/mobile/` | `mobile` |
| `packages/learning_core/` | `core` |
| `content/` | `content`; add `mobile` when packaged assets or App behavior changes |
| `services/api/` | `api` |
| `.codex/`, `.agents/`, `tools/`, root instructions | targeted script/skill validation plus `docs` when documentation routes changed |
| Cross-cutting release or PR | `all`, plus requested build switches |

Run the shared script from the repository root:

```powershell
.\tools\scripts\verify.ps1 -Scope <mobile|core|content|api|docs|all>
```

Use `-BuildApk` only when Android packaging matters. Use `-BuildContainer` only when the API image matters.

## Add risk-specific evidence

- UI changes: capture the same page, state, viewport, and text scale before and after. Automated tests alone do not prove a visual fix.
- Permissions, audio, recording, lifecycle, and device integration: run the closest automated tests, then state whether evidence came from a simulator or a real device.
- Drift schema changes: regenerate database files and migrations, then verify no unexpected generated diff remains.
- Course assets: verify file existence, SHA-256, source, license, credit, content status, and human pronunciation review state.
- Review algorithm changes: add a failing test first and document data migration impact.
- Docs-only changes: validate links/structure and run the repo-docs validator when `repo-docs/` changed.

## Report accurately

List commands and results. Distinguish passed, failed, skipped, unavailable, simulator-only, and real-device evidence. Never infer remote CI, packaging, device behavior, commit, push, or deployment status from local checks.
