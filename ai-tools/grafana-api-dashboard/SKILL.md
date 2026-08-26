---
name: grafana-api-dashboard
description: 基于 JSON 模板快速生成完整的 Grafana API 监控 Dashboard（14 面板标准布局：4 Stat + 4 Table + 6 Timeseries）。当用户提供 Grafana JSON 模板并要求生成/扩展/标准化监控看板时使用。支持 Prometheus 数据源、变量替换和自动布局。
---

# Grafana Dashboard 扩展生成器

## 1. 概述

根据用户提供的 **Grafana Dashboard JSON 模板** 和 **配置参数**，自动生成完整的 API 监控 Dashboard，**输出为 `.json` 文件**。

### 默认模板

如用户未提供 JSON 模板，默认使用 [references/grafana-template.json](references/grafana-template.json) 作为基础模板。

### 自定义模板

用户可以提供任意 Grafana JSON 模板替代默认模板。Skill 会基于用户模板进行变量替换和面板标准化。如用户模板的面板结构与标准布局不同，按标准 14 面板布局重建。

### 标准面板布局（14 个面板）

| 层级 | 面板类型 | 数量 | 说明 |
|------|---------|------|------|
| 顶部 | Stat（统计卡片） | 4 | 总请求数、总失败数、第三方失败数、平均 RT |
| 中部 | Table（排行表格） | 4 | 失败 API、失败第三方、API RT、第三方 RT |
| 底部 | Timeseries（时序图） | 6 | QPS、Latency、QPM、QPM(URI)、成功率、请求量 |

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `json_template` | ✅ | 用户提供的 JSON 模板 | 粘贴 JSON 或引用文件 |
| `ds` | ✅ | 数据源名称或 UID，可选值见下方列表 | `aws-hk-uat` / `aws-jp-prd` |
| `app` | ✅ | 应用/服务名称 | `agent-japan-dinersclub-website` |
| `api` | ⚠️ | 接口列表（正则，`\|` 分隔）。未提供时自动从用户代码/配置中提取 API 路径 | `/base/login\|/base/logout` |
| `api_source` | ⚠️ | API 路径来源文件（代码、配置文件、Swagger 等）。未提供 `api` 且未提供此参数时，移除 URI 过滤 | 项目源码目录、application.yml、swagger.json |
| `dashboard_title` | ⚠️ | 看板标题 | `API监控-项目名-服务名` |
| `time_range` | ⚠️ | 默认时间范围（默认 `now-6h`） | `now-12h` |

**ds 可选值**（也可自定义输入其他数据源）：

| 数据源 | 说明 |
|--------|------|
| `aws-jp-prd` | 日本生产 |
| `aws-sg-prd` | 新加坡生产 |
| `aws-uk-prd` | 英国生产 |
| `aws-ie-prd` | 爱尔兰生产 |
| `aws-hk-prd` | 香港生产 |
| `ali-ai-prd` | 阿里 AI 生产 |
| `aws-jp-visa-apac-prd` | 日本 Visa APAC 生产 |
| `aws-sg-prd-visa-apac` | 新加坡 Visa APAC 生产 |
| `aws-hk-uat` | 香港 UAT |
| `aws-uk-uat` | 英国 UAT |
| `aws-ie-uat` | 爱尔兰 UAT |
| `gz-idc2-prd` | 广州 IDC2 生产 |

---

## 2. 执行流程

### 步骤 1：接收并解析输入

1. 读取用户提供的 JSON 模板（未提供则使用默认模板 `references/grafana-template.json`）
2. 提取 `templating.list` 中的变量结构（`ds`、`app`、`api`）
3. 提取 `panels` 中的现有面板
4. 提取 `uid` / `title` / `time` 等元数据
5. 验证必填参数（`ds`、`app`），缺少则提示用户
6. **解析 API 列表**（按优先级）：
   - 用户直接提供 `api` 参数 → 直接使用
   - 用户提供 `api_source`（代码/配置文件） → 从中提取 API 路径
   - 均未提供 → **清空 api 变量**，移除 PromQL 中的 `uri=~"$api"` 过滤条件（匹配所有 URI）

### 步骤 2：构建输出 JSON

1. **重置元数据**：`id: null`, `version: 1`
2. **更新 templating 变量**：按规则替换 `ds`、`app`、`api` 的 current/query 值
3. **生成/更新面板**：确保 14 个标准面板存在且布局正确
4. **更新 title / time / uid**

### 步骤 3：输出结果

1. **将完整 JSON 写入 `.json` 文件**（使用 Write 工具），文件命名规则：`{app}-dashboard.json`
2. 在对话中输出变更摘要报告
3. 告知用户文件路径和 Grafana 导入方式

---

## 3. 模板映射规则

### 3.1 变量更新规则

更新 `templating.list` 中三个变量：

```json
{
  "name": "ds",
  "current": { "text": "<用户 ds>", "value": "<用户 ds 值或 UID>" },
  "regex": "<保留原正则或更新>"
}
```
```json
{
  "name": "app",
  "current": { "text": "<用户 app>", "value": "<用户 app>" }
}
```
```json
{
  "name": "api",
  "current": { "text": "<用户 api 或从代码中提取或清空>", "value": "<用户 api 或从代码中提取或清空>" },
  "query": "<用户 api 或从代码中提取或清空>"
}
```

**api 变量处理优先级**：
1. 用户直接提供 `api` → 直接使用
2. 用户提供代码/配置文件 → 自动提取 API 路径（见下方提取规则）
3. 均未提供 → **清空 api 变量**，同时移除所有 PromQL 中的 `uri=~"$api"` 条件

> ⚠️ **不继承模板原有 api 值**。模板中的旧 api 列表始终被替换或清空。

### API 路径提取规则

从用户提供的代码/配置文件中提取 API 路径时，按以下模式扫描：

| 来源类型 | 提取模式 |
|----------|----------|
| Java/Kotlin 代码 | 扫描 `@RequestMapping`、`@GetMapping`、`@PostMapping` 等注解中的路径 |
| Spring 配置 | 扫描 `server.servlet.context-path` 和 Controller 注解 |
| application.yml/properties | 扫描 API 相关配置项 |
| Swagger/OpenAPI JSON | 解析 `paths` 对象的所有 key |
| 路由配置文件 | 扫描包含路径模式的行（如 `/api/xxx`） |

提取后自动用 `\|` 拼接为正则表达式格式。

### 3.2 PromQL 变量替换

所有面板 `targets[].expr` 中的变量替换：

| 模板变量 | 替换为 |
|----------|--------|
| `$app` | 用户输入的 `app` 值 |
| `$ds` | 用户输入的 `ds` 值 |
| `$api` | 用户输入的 `api` 值 |
| `$__range` | **保持不变**（Grafana 内置） |

### 3.3 元数据更新

```json
{
  "id": null,
  "version": 1,
  "uid": "<自动生成 32 位随机字符串>",
  "title": "<用户提供或自动生成: API监控-{项目名}-{app}>",
  "time": { "from": "<用户提供或 now-6h>", "to": "now" }
}
```

**UID 生成规则**：始终生成新的 32 位随机 UID（使用小写字母和数字），格式示例：`a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`

---

## 4. 标准 PromQL 查询

### Stat 面板（4 个）

| # | 面板标题 | PromQL |
|---|---------|--------|
| 1 | 总请求数 | `sum(increase(api_request_total{app="$app", uri!="/**"}[$__range]))` |
| 2 | 总失败数 | `sum(increase(api_request_total{app="$app", success="0", uri!="/**"}[$__range]))` |
| 3 | 第三方总失败数 | `sum(increase(dp_biz_operation_total{app="$app", result_type!="OK"}[$__range]))` |
| 4 | 总平均 RT | `sum(increase(api_request_time_sum{app="$app", uri!="/**"}[$__range])) / sum(increase(api_request_time_count{app="$app", uri!="/**"}[$__range]))` |

### Table 面板（4 个）

| # | 面板标题 | PromQL |
|---|---------|--------|
| 1 | 失败 API 排行 | `topk(10, sum by(uri)(increase(api_request_total{app="$app", success="0", uri!="/**"}[$__range])) and sum by(uri)(increase(api_request_total{app="$app", uri!="/**"}[$__range])) > 10)` |
| 2 | 失败第三方排行 | `topk(10, sum by(op_code)(increase(dp_biz_operation_total{app="$app", result_type!="OK"}[$__range])) and sum by(op_code)(increase(dp_biz_operation_total{app="$app"}[$__range])) > 10)` |
| 3 | API RT 排行 | `topk(10, (sum by(uri)(increase(api_request_time_sum{app="$app", uri!="/**"}[$__range])) / sum by(uri)(increase(api_request_time_count{app="$app", uri!="/**"}[$__range]))) and sum by(uri)(increase(api_request_time_count{app="$app", uri!="/**"}[$__range])) > 10)` |
| 4 | 第三方 RT 排行 | `topk(10, (sum by(class,method)(increase(dp_method_exec_time_total{app="$app"}[$__range])) / sum by(class,method)(increase(dp_method_exec_total{app="$app"}[$__range]))) and sum by(class,method)(increase(dp_method_exec_total{app="$app"}[$__range])) > 10)` |

### Timeseries 面板（6 个）

| # | 面板标题 | PromQL |
|---|---------|--------|
| 1 | QPS | `sum(rate(api_request_total{app="$app", uri=~"$api"}[1m]))` |
| 2 | API LATENCY | `sum by(uri)(increase(api_request_time_sum{app="$app", uri=~"$api"}[2m])) / sum by(uri)(increase(api_request_time_count{app="$app", uri=~"$api"}[2m]))` |
| 3 | QPM (总量) | `sum(increase(api_request_total{app="$app", uri=~"$api"}[1m]))` |
| 4 | QPM (按 URI) | `sum by(uri)(increase(api_request_total{app="$app", uri=~"$api"}[1m]))` |
| 5 | API 成功率 | `sum by(uri)(rate(api_request_total{app="$app", uri=~"$api", success="1"}[1m])) / sum by(uri)(rate(api_request_total{app="$app", uri=~"$api"}[1m]))` |
| 6 | 接口请求量统计 | `sum by(uri)(increase(api_request_total{app="$app", uri=~"$api"}[$__range]))` |

> 完整面板 JSON 配置详见 [references/panel-templates.md](references/panel-templates.md)

---

## 5. 布局坐标表

| 面板 | x | y | w | h |
|------|---|---|---|---|
| Stat 1 (总请求数) | 0 | 0 | 6 | 4 |
| Stat 2 (总失败数) | 6 | 0 | 6 | 4 |
| Stat 3 (第三方总失败数) | 12 | 0 | 6 | 4 |
| Stat 4 (总平均 RT) | 18 | 0 | 6 | 4 |
| Table 1 (失败 API 排行) | 0 | 4 | 6 | 7 |
| Table 2 (失败第三方排行) | 6 | 4 | 6 | 7 |
| Table 3 (API RT 排行) | 12 | 4 | 6 | 7 |
| Table 4 (第三方 RT 排行) | 18 | 4 | 6 | 7 |
| Timeseries 1 (QPS) | 0 | 11 | 12 | 8 |
| Timeseries 2 (API LATENCY) | 12 | 11 | 12 | 8 |
| Timeseries 3 (QPM 总量) | 0 | 19 | 12 | 8 |
| Timeseries 4 (QPM 按 URI) | 12 | 19 | 12 | 8 |
| Timeseries 5 (API 成功率) | 0 | 27 | **24** | 8 |
| Timeseries 6 (接口请求量统计) | 0 | 35 | **24** | 8 |

> 注意：Timeseries 5 和 6 为全宽面板（w=24），其余 Timeseries 为半宽（w=12）。

---

## 6. 面板 ID 分配

生成新面板时使用递增 ID，从模板中最大 ID + 1 开始。模板中的面板保留原有 ID：

| 面板 | 模板 ID |
|------|---------|
| Stat 1~4 | 30, 31, 32, 37 |
| Table 1~4 | 33, 34, 35, 36 |
| Timeseries 1~6 | 8, 20, 12, 6, 21, 22 |

---

## 7. 交互示例

### 示例 1：完整参数

> 用这个模板生成 Dashboard：
> - ds: aws-jp-prd
> - app: agent-japan-rakuten-website
> - api: /base/login|/base/logout|/base/getUserInfo
> - title: API监控-日本乐天-agent服务

**输出**：完整 JSON + 变更摘要

### 示例 2：部分参数

> 根据这个 JSON 生成 Dashboard：
> - ds: aws-hk-uat
> - app: agent-japan-dinersclub-website

**行为**：清空模板原有 `api` 值，移除 URI 过滤（匹配所有接口），仅更新 `ds` 和 `app`

### 示例 3：仅 JSON 模板

> 帮我标准化这个 Dashboard

**行为**：检查变量完整性 → 缺少则提示补充 → 完整则直接生成

---

## 8. 输出格式

### 8.1 输出 JSON 文件（主要产物）

**必须将生成的 JSON 写入 `.json` 文件**，而非仅在对话中输出代码块。

- 文件命名：`{app}-dashboard.json`（如 `agent-japan-rakuten-website-dashboard.json`）
- 输出路径：当前工作目录或用户指定目录
- 文件内容：完整的、可直接导入 Grafana 的 JSON

### 8.2 变更摘要（对话中输出）

写入文件后，在对话中输出简要报告：

```markdown
## 变更摘要

✅ 已生成文件：`{app}-dashboard.json`

| 项目 | 变更前 | 变更后 |
|------|--------|--------|
| Dashboard 标题 | `xxx` | `API监控-xxx-xxx` |
| 数据源 (ds) | `xxx` | `aws-jp-prd` |
| 应用 (app) | `xxx` | `agent-japan-rakuten-website` |
| 接口数量 | 0 | 3 |
| 面板总数 | 5 | 14 |

## 导入方式

1. 打开生成的 `.json` 文件，复制全部内容
2. Grafana → Dashboards → New → Import
3. 粘贴 JSON → Load → Import
```

---

## 9. 异常处理

| 异常场景 | 处理方式 |
|----------|----------|
| 未提供 `ds` | 提示：`请提供数据源名称，如 aws-hk-uat 或 aws-jp-prd` |
| 未提供 `app` | 提示：`请提供应用/服务名称，如 agent-japan-xxx` |
| 未提供 `api` 且无代码文件 | **清空 api 变量**，移除 PromQL 中 `uri=~"$api"` 过滤（匹配所有 URI） |
| `panels` 为空 | 生成全部 14 个标准面板 |
| `templating` 缺变量 | 自动补全 `ds`、`app`、`api` |
| 数据源 UID 未知 | 保留 `${ds}` 变量形式 |

---

## 10. 参考资源

- JSON 模板原始文件：[references/grafana-template.json](references/grafana-template.json)
- 面板详细 JSON 配置：[references/panel-templates.md](references/panel-templates.md)

---

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0.0 | 2026-08-26 | 初始版本，14 面板标准布局 |
