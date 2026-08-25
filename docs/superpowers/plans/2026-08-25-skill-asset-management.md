# APAC Skills 资产库搭建 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从零搭建 apac-skills monorepo，包含目录结构、模板、文档、CI 和搜索工具

**Architecture:** Monorepo，按类别（ai-agent-skills / ai-coding-skills / ai-tools / ai-wiki）分区，每个 skill 一个子目录，包含 skill.json 元数据和 README.md

**Tech Stack:** 纯文件 + Shell 脚本 + GitHub Actions CI，无外部依赖

---

## 文件结构

```
apac-skills/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .github/workflows/check.yml
├── templates/
│   ├── skill-template/
│   │   ├── skill.json
│   │   └── README.md
│   ├── wiki-template/
│   │   ├── wiki.json
│   │   └── README.md
│   └── tool-template/
│       ├── tool.json
│       └── README.md
├── ai-agent-skills/.gitkeep
├── ai-coding-skills/.gitkeep
├── ai-tools/.gitkeep
├── ai-wiki/.gitkeep
└── scripts/
    └── search-skills.sh
```

---

### Task 1: 创建目录结构

**Files:**
- Create: `ai-agent-skills/.gitkeep`
- Create: `ai-coding-skills/.gitkeep`
- Create: `ai-tools/.gitkeep`
- Create: `ai-wiki/.gitkeep`
- Create: `templates/skill-template/` (directory)
- Create: `templates/wiki-template/` (directory)
- Create: `templates/tool-template/` (directory)
- Create: `scripts/` (directory)
- Create: `.github/workflows/` (directory)

- [ ] **Step 1: 创建所有目录和占位文件**

```bash
mkdir -p ai-agent-skills ai-coding-skills ai-tools ai-wiki \
  templates/skill-template templates/wiki-template templates/tool-template \
  scripts .github/workflows

touch ai-agent-skills/.gitkeep ai-coding-skills/.gitkeep \
  ai-tools/.gitkeep ai-wiki/.gitkeep
```

- [ ] **Step 2: 验证目录结构**

```bash
find . -type d | sort
```

Expected: 应包含 `ai-agent-skills`, `ai-coding-skills`, `ai-tools`, `ai-wiki`, `templates/skill-template`, `templates/wiki-template`, `templates/tool-template`, `scripts`, `.github/workflows`

- [ ] **Step 3: Commit**

```bash
git add ai-agent-skills/ ai-coding-skills/ ai-tools/ ai-wiki/ templates/ scripts/ .github/
git commit -m "feat: create directory structure for skill categories and templates"
```

---

### Task 2: 编写项目 README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 用项目内容替换模板 README**

```markdown
# APAC Skills

APAC 团队 AI 技能资产库。统一管理 AI Agent Skills、AI Coding 实践、AI 工具指南和 AI 业务 Wiki，支持团队内部知识共享和跨团队复用。

## 目录结构

```
apac-skills/
├── ai-agent-skills/    # AI Agent 相关技能（如 brainstorming、debugging）
├── ai-coding-skills/   # AI 编码最佳实践和规范
├── ai-tools/           # AI 工具使用指南
├── ai-wiki/            # AI 业务知识库
├── templates/          # Skill 模板
└── scripts/            # 工具脚本
```

## 快速开始

### 浏览 Skill

按类别浏览对应目录，每个 skill 子目录包含：
- `skill.json` — 元数据（名称、版本、标签、作者等）
- `README.md` — 使用说明和示例

### 搜索 Skill

```bash
./scripts/search-skills.sh --category ai-agent-skills
./scripts/search-skills.sh --tag "debugging"
./scripts/search-skills.sh --keyword "code review"
```

### 创建新 Skill

```bash
cp -r templates/skill-template/ ai-agent-skills/my-new-skill/
# 编辑 ai-agent-skills/my-new-skill/skill.json 和 README.md
```

## 贡献

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 分类

| 类别 | 用途 | 示例 |
|------|------|------|
| `ai-agent-skills` | AI Agent 交互技能 | brainstorming, debugging, code-review |
| `ai-coding-skills` | AI 编码规范与实践 | test-driven-development, code-style |
| `ai-tools` | AI 工具使用指南 | cursor-setup, copilot-tips |
| `ai-wiki` | AI 业务知识 | domain-glossary, architecture-decisions |
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: write project README with overview and quick start"
```

---

### Task 3: 编写 CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: 创建贡献指南**

```markdown
# 贡献指南

## Skill 添加流程

1. 选择正确的类别目录（`ai-agent-skills` / `ai-coding-skills` / `ai-tools` / `ai-wiki`）
2. 从 `templates/` 复制对应模板
3. 填写 `skill.json` 元数据
4. 编写 `README.md`（至少包含：说明、用法、示例）
5. 提交 PR

## Skill 元数据规范

每个 skill 必须包含 `skill.json`：

```json
{
  "name": "skill-name",
  "version": "1.0",
  "description": "简短描述",
  "category": "ai-agent-skills|ai-coding-skills|ai-tools|ai-wiki",
  "tags": ["tag1", "tag2"],
  "author": "your-name",
  "team": "your-team",
  "dependencies": [],
  "platform": ["opencode", "claude-code"],
  "lastUpdated": "2026-08-25",
  "rating": 0,
  "usageCount": 0
}
```

## 版本管理

- 简单递增版本号：`1.0` → `1.1` → `2.0`
- 小改动（修复、文档更新）：次版本号 +1
- 大改动（不兼容变更）：主版本号 +1
- 小改动直接提交 main 分支，大改动创建分支 → PR → 审查

## 文档要求

- 每个 skill 必须有 `README.md`
- 必须包含：功能说明、使用方式、代码示例
- 可选：`WIKI.md` 存放详细文档

## 代码审查

- 至少一位团队成员 approve 后合并
- 检查项：元数据完整性、文档质量、分类正确性
```

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add contribution guide with metadata spec and workflow"
```

---

### Task 4: 创建 Skill 模板

**Files:**
- Create: `templates/skill-template/skill.json`
- Create: `templates/skill-template/README.md`

- [ ] **Step 1: 创建 skill.json 模板**

```json
{
  "name": "skill-name",
  "version": "1.0",
  "description": "",
  "category": "ai-agent-skills",
  "tags": [],
  "author": "",
  "team": "",
  "dependencies": [],
  "platform": [],
  "lastUpdated": "",
  "rating": 0,
  "usageCount": 0
}
```

- [ ] **Step 2: 创建 README.md 模板**

```markdown
# [Skill Name]

## 简介

[一句话描述这个 skill 做什么]

## 使用方式

[如何使用这个 skill]

## 示例

[代码或配置示例]

## 依赖

[依赖的其他 skill 或工具]

## 平台支持

[支持的 AI 平台，如 opencode、claude-code]
```

- [ ] **Step 3: Commit**

```bash
git add templates/skill-template/
git commit -m "feat: add skill template with metadata and README"
```

---

### Task 5: 创建 Wiki 模板

**Files:**
- Create: `templates/wiki-template/wiki.json`
- Create: `templates/wiki-template/README.md`

- [ ] **Step 1: 创建 wiki.json 模板**

```json
{
  "name": "wiki-name",
  "version": "1.0",
  "description": "",
  "category": "ai-wiki",
  "tags": [],
  "author": "",
  "team": "",
  "dependencies": [],
  "platform": [],
  "lastUpdated": "",
  "rating": 0,
  "usageCount": 0
}
```

- [ ] **Step 2: 创建 README.md 模板**

```markdown
# [Wiki Name]

## 概述

[知识领域概述]

## 核心概念

[关键概念和术语]

## 最佳实践

[推荐做法和注意事项]

## 参考

[相关链接和资料]
```

- [ ] **Step 3: Commit**

```bash
git add templates/wiki-template/
git commit -m "feat: add wiki template with metadata and README"
```

---

### Task 6: 创建 Tool 模板

**Files:**
- Create: `templates/tool-template/tool.json`
- Create: `templates/tool-template/README.md`

- [ ] **Step 1: 创建 tool.json 模板**

```json
{
  "name": "tool-name",
  "version": "1.0",
  "description": "",
  "category": "ai-tools",
  "tags": [],
  "author": "",
  "team": "",
  "dependencies": [],
  "platform": [],
  "lastUpdated": "",
  "rating": 0,
  "usageCount": 0
}
```

- [ ] **Step 2: 创建 README.md 模板**

```markdown
# [Tool Name]

## 简介

[工具简介]

## 安装

[安装步骤]

## 配置

[配置说明]

## 使用示例

[使用示例和截图]

## 常见问题

[FAQ]
```

- [ ] **Step 3: Commit**

```bash
git add templates/tool-template/
git commit -m "feat: add tool template with metadata and README"
```

---

### Task 7: 设置 CI

**Files:**
- Create: `.github/workflows/check.yml`

- [ ] **Step 1: 创建 CI workflow，检查 JSON 有效性和目录规范**

```yaml
name: Check

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate JSON files
        run: |
          find . -name "*.json" -not -path "./.git/*" | while read f; do
            echo "Checking $f"
            python3 -m json.tool "$f" > /dev/null || exit 1
          done

      - name: Check skill directories have required files
        run: |
          for dir in ai-agent-skills ai-coding-skills ai-tools ai-wiki; do
            for skill in "$dir"/*/; do
              if [ -d "$skill" ]; then
                echo "Checking $skill"
                [ -f "$skill/skill.json" ] || [ -f "$skill/wiki.json" ] || [ -f "$skill/tool.json" ] || { echo "Missing metadata in $skill"; exit 1; }
                [ -f "$skill/README.md" ] || { echo "Missing README.md in $skill"; exit 1; }
              fi
            done
          done
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/check.yml
git commit -m "ci: add GitHub Actions workflow for JSON and structure validation"
```

---

### Task 8: 创建搜索脚本

**Files:**
- Create: `scripts/search-skills.sh`

- [ ] **Step 1: 创建搜索脚本**

```bash
#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--category <cat>] [--tag <tag>] [--keyword <kw>]"
  echo ""
  echo "Options:"
  echo "  --category   Filter by category (ai-agent-skills|ai-coding-skills|ai-tools|ai-wiki)"
  echo "  --tag        Filter by tag"
  echo "  --keyword    Search in name and description"
  echo ""
  echo "Examples:"
  echo "  $0 --category ai-agent-skills"
  echo "  $0 --tag debugging"
  echo "  $0 --keyword brainstorm"
  exit 0
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CATEGORY=""
TAG=""
KEYWORD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --keyword) KEYWORD="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

SEARCH_DIRS=("ai-agent-skills" "ai-coding-skills" "ai-tools" "ai-wiki")

if [ -n "$CATEGORY" ]; then
  SEARCH_DIRS=("$CATEGORY")
fi

FOUND=0
for dir in "${SEARCH_DIRS[@]}"; do
  if [ ! -d "$PROJECT_DIR/$dir" ]; then
    continue
  fi
  for skill_dir in "$PROJECT_DIR/$dir"/*/; do
    [ -d "$skill_dir" ] || continue
    META=""
    for f in "$skill_dir/skill.json" "$skill_dir/wiki.json" "$skill_dir/tool.json"; do
      if [ -f "$f" ]; then
        META="$f"
        break
      fi
    done
    if [ -z "$META" ]; then
      continue
    fi

    NAME=$(python3 -c "import json; print(json.load(open('$META'))['name'])" 2>/dev/null || echo "")
    DESC=$(python3 -c "import json; print(json.load(open('$META'))['description'])" 2>/dev/null || echo "")
    TAGS=$(python3 -c "import json; print(' '.join(json.load(open('$META'))['tags']))" 2>/dev/null || echo "")

    MATCH=1
    if [ -n "$TAG" ]; then
      if ! echo "$TAGS" | grep -qi "$TAG"; then
        MATCH=0
      fi
    fi
    if [ -n "$KEYWORD" ]; then
      if ! echo "$NAME $DESC" | grep -qi "$KEYWORD"; then
        MATCH=0
      fi
    fi

    if [ "$MATCH" -eq 1 ]; then
      echo "[$dir] $NAME — $DESC"
      echo "  Tags: $TAGS"
      echo "  Path: $skill_dir"
      echo ""
      FOUND=$((FOUND + 1))
    fi
  done
done

if [ "$FOUND" -eq 0 ]; then
  echo "No skills found."
fi
```

- [ ] **Step 2: 添加执行权限并测试**

```bash
chmod +x scripts/search-skills.sh
./scripts/search-skills.sh --help
```

Expected: 显示帮助信息

- [ ] **Step 3: Commit**

```bash
git add scripts/search-skills.sh
git commit -m "feat: add skill search script with category, tag, and keyword filters"
```

---

### Task 9: 更新 .gitignore

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: 移除 docs/ 忽略规则，允许提交设计文档和计划**

移除 `.gitignore` 中的 `docs/` 行。

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: allow docs/ directory in git tracking"
```

---

### Task 10: 创建 LICENSE

**Files:**
- Create: `LICENSE`

- [ ] **Step 1: 创建 MIT LICENSE**

```
MIT License

Copyright (c) 2026 APAC AI Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Commit**

```bash
git add LICENSE
git commit -m "chore: add MIT license"
```