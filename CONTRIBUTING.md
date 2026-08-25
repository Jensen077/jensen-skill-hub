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
