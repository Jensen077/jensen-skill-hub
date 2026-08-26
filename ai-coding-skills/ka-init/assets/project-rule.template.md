# 项目编码规则

## 代码风格
<!--
  输出示例：
  - 命名：组件用 PascalCase，工具函数用 camelCase，常量用 UPPER_SNAKE_CASE
  - 缩进：2 空格，不使用 tab
  - Import 顺序：第三方库 → 内部模块 → 相对路径，各组之间空行
  - 注释语言：中文注释，关键函数需 JSDoc
-->
{style_rules}

## 架构约束
<!--
  输出示例：
  - 分层：controller → service → dao，禁止跨层调用
  - API：RESTful，响应格式统一为 { code, data, message }
  - 状态管理：全局状态用 Redux，局部状态用 useState
  - 错误处理：业务异常用自定义 Error 类，统一在 middleware 捕获
  - 安全：输入校验在 service 层，SQL 参数化查询，敏感配置走环境变量
-->
{architecture_rules}

## 行为边界
<!--
  输出示例：
  - 不要修改 `config/production.yml`，生产配置由运维管理
  - 不要直接操作数据库，所有数据变更走 API
  - 删除或重命名公共 API 前需确认下游影响
  - 修改核心模块需同步更新测试
-->
{behavioral_boundary}
