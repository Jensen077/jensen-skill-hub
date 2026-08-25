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