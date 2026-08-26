# AGENTS.md

APAC 团队 AI 技能资产库。纯内容仓库，非代码项目。

## 目录结构

```
ai-agent-skills/   # AI Agent 交互技能（brainstorming, debugging 等）
ai-coding-skills/  # AI 编码规范与实践（ka-init, frontend-design 等）
ai-tools/          # AI 工具使用指南
ai-wiki/           # AI 业务知识库（ka-wiki, ka-generator-api-doc 等）
templates/         # Skill/Wiki/Tool 创建模板
scripts/           # 工具脚本
```

## Skill 结构规范

每个 skill 是一个子目录，必须包含：

| 类型 | 元数据文件 | 说明文件 |
|------|-----------|---------|
| Skill | `skill.json` | `README.md` |
| Wiki | `wiki.json` | `README.md` |
| Tool | `tool.json` | `README.md` |
| Agent Skill | `skill.json` | `SKILL.md`（带 YAML frontmatter） |

**元数据字段**（所有类型通用）：`name`, `version`, `description`, `category`, `tags`, `author`, `team`, `dependencies`, `platform`, `lastUpdated`, `rating`, `usageCount`

## 创建新 Skill

1. 从 `templates/` 复制对应模板（skill-template / wiki-template / tool-template）
2. 放入对应 category 目录（`ai-agent-skills/`、`ai-coding-skills/`、`ai-tools/`、`ai-wiki/`）
3. 填写元数据 JSON 和说明文档
4. Agent Skill（被 AI agent 调用的）使用 `SKILL.md` 并加 YAML frontmatter：`name` + `description`

## 搜索 Skill

```bash
./scripts/search-skills.sh --category ai-agent-skills
./scripts/search-skills.sh --tag debugging
./scripts/search-skills.sh --keyword brainstorm
```

## 约束

- 语言：中文为主，代码/命令保持英文
- 不提交 `.claude/`、`.gstack/`、`.codegraph/`、`.specify/`、`.vscode/` 等 AI 工具目录
- 元数据 JSON 中 `category` 必须与实际所在目录一致
