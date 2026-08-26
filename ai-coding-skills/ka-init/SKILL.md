---
name: ka-init
description: Generate a lightweight project initialization doc for AI coding by scanning the repository, creating CLAUDE.md (or AGENTS.md) and docs/project-rule.md by default, with optional docs/project-info.md.
---

# ka-init

Use this skill when the user asks to initialize AI-coding project docs such as `CLAUDE.md`, `AGENTS.md`, or a lightweight project context file for a repo.

## Output Files

- Default: `CLAUDE.md`
- Optional: `AGENTS.md` (same structure, different filename for tool compatibility)
- Always: `docs/project-rule.md` (coding rules inferred from project code)
- Optional: `docs/project-info.md` (business/module details)

## Command Flags

- `/ka-init` → generate `CLAUDE.md`
- `/ka-init --agents` → generate `AGENTS.md`
- `/ka-init --both` → generate both
- `/ka-init --project-info` → also create `docs/project-info.md`
- `/ka-init --no-project-info` → skip `docs/project-info.md` without asking
- `/ka-init --force` → skip overwrite confirmation

Infer the same behavior from natural language when flags are not supported.

## Workflow

1. **Scan the repo** (see scan order below) before asking any questions.
2. **Infer** project name, purpose, stack, structure, key entries, build/test commands, coding rules, and behavioral boundaries (see Inference below).
3. **Decide target filename** from user intent, default to `CLAUDE.md`.
4. If target exists and `--force` not set, ask whether to overwrite or update in place.
5. Ask whether to create `docs/project-info.md` unless `--project-info` or `--no-project-info` was given.
6. Ask at most 1-3 follow-up questions only if key context is still missing.
7. Generate file(s) using templates in `assets/`. Always generate `docs/project-rule.md`.
8. Keep uncertain facts conservative. Do not invent modules, commands, or architecture.

## Scan Order

Scan in this order when present:

1. Root directory listing
2. `README.md`
3. Existing `CLAUDE.md` or `AGENTS.md`
4. Build/dependency files: `package.json`, `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `pom.xml`, `build.gradle`, `build.gradle.kts`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pubspec.yaml`, `composer.json`
5. Source directories: `src/`, `app/`, `pages/`, `api/`, `server/`, `backend/`, `frontend/`, `packages/`, `apps/`
6. Infra files: `Dockerfile`, `docker-compose.yml`, `Makefile`

## Inference

Infer from the repo without asking: project name, goal, tech stack, directory structure, key entries, build/test commands. Prefer heuristics for Java/Spring Boot, React, Vue, Node.js, Python.

**Coding rules** (for `docs/project-rule.md`) — infer from project code, NOT from external rules directories (`.claude/rules/`, `.cursor/rules/`, etc.):

- **代码风格** — naming conventions, indentation, import ordering, comment language, file naming patterns
- **架构约束** — layering conventions, module boundaries, API patterns, state management, error handling, testing patterns
- **行为边界** — 从 warning 注释、deprecated 标记、保护性文件、README 注意事项中推断禁止或敏感操作，不编造约束

Sources: entry files, core module code, existing tests, config files, README notes, warning/deprecated annotations, protected files. If no meaningful rules can be inferred, create a minimal file with a note. Do not invent constraints.

## Question Strategy

Ask only if missing info would materially reduce doc usefulness. Max 1-3 questions, prefer:
1. Main project goal or business scope
2. Highest-priority code directories
3. Special build/test/release rules not discoverable from repo

Do not ask the user to restate what is already clear from the repo.

## Writing Rules

- Keep output concise, structured, close to the AGENTS-style template shape.
- Prefer concrete paths and commands over vague descriptions.
- Omit or shorten sections that do not apply rather than padding.
- In main doc, keep `编码规则` lightweight → point to `@docs/project-rule.md`.
- In main doc, keep `核心功能` brief → point to `@docs/project-info.md` when available, otherwise list inline.
- Do not emit dead references to files that were not generated.
- When updating existing docs, preserve useful user-written constraints.
- Render project structure as a list with inline `— 用途` comments. Use indentation for sub-directories.

## Templates

- Main doc: [assets/main-doc.template.md](assets/main-doc.template.md)
- Project info: [assets/project-info.template.md](assets/project-info.template.md)
- Project rule: [assets/project-rule.template.md](assets/project-rule.template.md)

## Final Check

Before finishing:
1. Generated doc answers: what this project is, where the code is, where to start, how to build/validate.
2. Content stays close to the simple AGENTS-style template.
3. Main doc references `@docs/project-rule.md` (always) and `@docs/project-info.md` (only when generated).
