<!--
  Render as `# CLAUDE.md` or `# AGENTS.md` depending on the target file.
-->
# CLAUDE.md

## 项目概述
- **项目名称**：{project_name}
- **项目目标**：{project_goal}
- **项目类型**：{project_type}

## 技术栈
- **Frontend**: {frontend_stack}
- **Backend**: {backend_stack}
- **Other**: {other_stack}

## 编码规则
<!--
  If docs/project-rule.md was generated:
    - 规则汇总：`docs/project-rule.md`（含代码风格、架构约束、行为边界）
    - 规则来源：项目代码推断
  Else:
    - 当前未生成独立规则文档，规则信息以内联摘要为准。
-->
{coding_rules_section}

## 项目结构
- 仓库根目录：`{repo_root}`
- 核心代码目录：
<!--
  Render as a list. Each item: `- `path/` — 用途`.
  For sub-directories, indent one level: `  - `path/sub/` — 用途`.
-->
{core_directories}

## 关键入口
<!--
  Render as a list. Each item: `- `path/to/entry` — 角色说明`
  Example: `- `src/main.ts` — 应用启动入口`
  Merge startup and business entry into one flat list.
-->
{key_entries}

## 构建与测试命令
- 构建命令：`{build_command}`
- 测试命令：`{test_command}`
- 其他约束：{command_notes}

## 核心功能
<!--
  If docs/project-info.md was generated:
    - 核心功能：`docs/project-info.md`
  Else:
    - Render a short bullet list: `- 功能名 — 一句话说明`
-->
{core_features_section}

## 补充说明
- {notes}
