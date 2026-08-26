---
name: grafana-api-detail-dashboard
description: 基于 JSON 模板生成 Grafana API 详细监控 Dashboard，按 API 逐行展示（Row repeat），每行包含成功率、延迟、QPM、百分位延迟、错误码、异常错误 6 个 Timeseries 面板。当用户提供 Grafana JSON 模板并要求生成按接口维度的详细监控看板时使用。
---

# Grafana API 详细监控 Dashboard 生成器

## 1. 概述

根据用户提供的 **Grafana Dashboard JSON 模板** 和 **配置参数**，自动生成按 **API 逐行展示** 的详细监控 Dashboard，**输出为 `.json` 文件**。

### 与 grafana-api-dashboard 的区别

| 特性 | grafana-api-dashboard | grafana-api-detail-dashboard（本 Skill） |
|------|----------------------|----------------------------------------|
| 面板类型 | 4 Stat + 4 Table + 6 Timeseries | 1 Row + 6 Timeseries（per API） |
| 展示维度 | 全局聚合 + 排行 | 按 API 逐行，每行 6 面板 |
| Row repeat | 无 | `repeat: "api"` |
| api 变量类型 | custom（手动列表） | query（`label_values` 动态查询） |
| 特色面板 | 失败排行、第三方 RT | 百分位延迟、错误码分布、异常错误 |

### 标准面板布局（每个 API 一行，6 个面板）

| # | 面板标题 | 类型 | 位置 | 说明 |
|---|---------|------|------|------|
| 0 | `$api` | Row | y=0, w=24, h=1 | 行标题，自动按 api 重复 |
| 1 | Success Rate/成功率 | Timeseries | y+0, w=12, h=8 | HTTP + 业务成功率 |
| 2 | API LATENCY (1 min AVG) | Timeseries | y+0, w=12, h=8 | 平均响应时间 |
| 3 | QPM | Timeseries | y+8, w=12, h=8 | 总量/失败/成功 三条线 |
| 4 | API LATENCY(5 min) | Timeseries | y+8, w=12, h=8 | 百分位延迟 P20-P99 |
| 5 | 错误码次数 | Timeseries | y+16, w=12, h=8 | 错误码分布 |
| 6 | API异常错误次数 | Timeseries | y+16, w=12, h=8 | 异常错误分布 |

### 默认模板

如用户未提供 JSON 模板，默认使用 [references/grafana-template.json](references/grafana-template.json)。

### 自定义模板

用户可提供任意 Grafana JSON 模板替代默认模板。Skill 基于用户模板进行变量替换和面板标准化。

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `json_template` | ✅ | JSON 模板（未提供则用默认） | 粘贴 JSON 或引用文件 |
| `ds` | ✅ | 数据源名称或 UID，可选值见下方列表 | `aws-sg-prd` / `aws-hk-uat` |
| `app` | ✅ | 应用/服务名称 | `ebridge-integration` |
| `api` | ⚠️ | 接口列表。未提供时从代码/配置中提取或清空 | `/order/booking` |
| `api_source` | ⚠️ | API 路径来源文件 | 项目源码目录、swagger.json |
| `dashboard_title` | ⚠️ | 看板标题 | `API监控看板-{项目名}-{app}` |
| `time_range` | ⚠️ | 默认时间范围（默认 `now-5m`） | `now-1h` |

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
   - 均未提供 → **保留 api 为 label_values 动态查询**（由 Prometheus 运行时填充）

### 步骤 2：构建输出 JSON

1. **重置元数据**：`id: null`, `version: 1`
2. **更新 templating 变量**：按规则替换 `ds`、`app` 的值
3. **生成 Row + 6 Timeseries 面板**：确保每个 API 行包含 6 个标准面板
4. **更新 title / time / uid**

### 步骤 3：输出结果

1. **将完整 JSON 写入 `.json` 文件**（使用 Write 工具），文件命名：`{app}-detail-dashboard.json`
2. 在对话中输出变更摘要报告
3. 告知用户文件路径和 Grafana 导入方式

---

## 3. 模板映射规则

### 3.1 变量更新规则

**ds 变量**（datasource 类型）：
```json
{
  "name": "ds",
  "current": { "text": "<用户 ds>", "value": "<用户 ds UID>" },
  "regex": "<保留原正则或更新>"
}
```

**app 变量**（custom 类型）：
```json
{
  "name": "app",
  "current": { "text": "<用户 app>", "value": "<用户 app>" },
  "query": "<用户 app>"
}
```

**api 变量**（query 类型 - 关键区别）：
```json
{
  "name": "api",
  "datasource": { "type": "prometheus", "uid": "${ds}" },
  "definition": "label_values(api_request_total{app=~\"$app\"},uri)",
  "query": {
    "qryType": 1,
    "query": "label_values(api_request_total{app=~\"$app\"},uri)",
    "refId": "PrometheusVariableQueryEditor-VariableQuery"
  },
  "refresh": 1,
  "regex": "",
  "type": "query"
}
```

> ⚠️ **api 变量默认为 query 类型**（`label_values` 动态查询），由 Prometheus 在运行时自动填充可用 API 列表。用户无需手动维护 API 列表。如用户明确要求固定 API 列表，则改为 custom 类型。

### 3.2 PromQL 变量替换

| 模板变量 | 替换为 |
|----------|--------|
| `$app` | 用户输入的 `app` 值 |
| `${api:raw}` | 保持不变（由 Grafana Row repeat 自动注入当前行 API） |
| `$__rate_interval` | 保持不变（Grafana 内置） |
| `$__interval` | 保持不变（Grafana 内置） |

### 3.3 元数据更新

```json
{
  "id": null,
  "version": 1,
  "uid": "<自动生成 32 位随机字符串>",
  "title": "<用户提供或自动生成: API监控看板-{项目名}-{app}>",
  "time": { "from": "<用户提供或 now-5m>", "to": "now" },
  "refresh": "1m"
}
```

**UID 生成规则**：始终生成新的 32 位随机 UID（小写字母和数字）。

---

## 4. 标准 PromQL 查询

### Row 面板

- **title**: `$api`（Grafana 自动替换为当前重复的 api 值）
- **repeat**: `api`
- **type**: `row`

### Panel 1: Success Rate/成功率

- **title**: `Success Rate/成功率`
- **gridPos**: `{ "h": 8, "w": 12, "x": 0 }`
- **unit**: `percentunit`, **max**: 1
- **Target A** (Http Success Rate):
  ```promql
  (
    sum(rate(api_request_total{app="$app", uri="${api:raw}",http_code="200"}[$__rate_interval]))
    /sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval]))
    and sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval])) >0
  ) or vector(1)
  ```
- **Target C** (Bussiness Success Rate):
  ```promql
  (
    sum(rate(api_request_total{app="$app", uri="${api:raw}",success="1"}[$__rate_interval]))
    /sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval]))
    and sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval]))>0
  ) or vector(1)
  ```

### Panel 2: API LATENCY (1 min AVG)

- **title**: `API LATENCY (1 min AVG)/接口平均响应时间`
- **gridPos**: `{ "h": 8, "w": 12, "x": 12 }`
- **unit**: `ms`
- **expr**: `sum(increase(api_request_time_sum{app="$app",uri="${api:raw}"}[$__interval]))/sum(increase(api_request_time_count{app="$app",uri="${api:raw}"}[$__interval]))`

### Panel 3: QPM

- **title**: `QPM`
- **gridPos**: `{ "h": 8, "w": 12, "x": 0 }`
- **unit**: `rotrpm`
- **Target A** (total): `sum (increase(api_request_total{app="$app",uri="${api:raw}"}[$__interval]))`
- **Target B** (fail): `sum (increase(api_request_total{app="$app",success="0",uri="${api:raw}"}[$__interval]))`
- **Target C** (success): `sum (increase(api_request_total{app="$app",success="1",uri="${api:raw}"}[1m]))`

### Panel 4: API LATENCY(5 min) - 百分位

- **title**: `API LATENCY(5 min)`
- **gridPos**: `{ "h": 8, "w": 12, "x": 12 }`
- **unit**: `ms`
- **expr**: `max by(quantile)(api_request_time{app="$app",uri="${api:raw}"})`
- **legendFormat**: `{{quantile}}`
- **overrides**: P20(0.2), P50(0.5), P80(0.8), p90(0.9), P95(0.95), P99(0.99)

### Panel 5: 错误码次数

- **title**: `错误码次数`
- **gridPos**: `{ "h": 8, "w": 12, "x": 0 }`
- **unit**: `reqpm`
- **expr**: `sum by (error_code,error_code2) (increase(api_request_total{app="$app",uri="${api:raw}",error_code!~"0|NULL"}[1m]))`
- **legendFormat**: `{{error_code}} - {{error_code2}}`

### Panel 6: API异常错误次数

- **title**: `API异常错误次数`
- **gridPos**: `{ "h": 8, "w": 12, "x": 12 }`
- **unit**: `reqpm`
- **expr**: `sum by (exception)(increase(api_request_total{app="$app",uri="${api:raw}",exception!="NULL"}[1m]))`
- **legendFormat**: `{{exception}}`

> 完整面板 JSON 配置详见 [references/panel-templates.md](references/panel-templates.md)

---

## 5. 布局坐标表

每个 API Row 的相对布局（y 值为 Row 内相对偏移，实际 y 由 Grafana repeat 自动计算）：

| 面板 | x | y 偏移 | w | h |
|------|---|--------|---|---|
| Row ($api) | 0 | 0 | 24 | 1 |
| Success Rate | 0 | +1 | 12 | 8 |
| API LATENCY (1m) | 12 | +1 | 12 | 8 |
| QPM | 0 | +9 | 12 | 8 |
| API LATENCY (5m) | 12 | +9 | 12 | 8 |
| 错误码次数 | 0 | +17 | 12 | 8 |
| 异常错误次数 | 12 | +17 | 12 | 8 |

---

## 6. 面板 ID 分配

模板中的面板保留原有 ID，新增面板从最大 ID + 1 开始：

| 面板 | 模板 ID |
|------|---------|
| Row | 2 |
| Success Rate | 6 |
| API LATENCY (1m) | 8 |
| QPM | 12 |
| API LATENCY (5m) | 19 |
| 错误码次数 | 21 |
| 异常错误次数 | 18 |

---

## 7. 交互示例

### 示例 1：完整参数

> 用这个模板生成 Dashboard：
> - ds: aws-jp-prd
> - app: agent-japan-rakuten-website
> - title: API监控-日本乐天-agent服务

**输出**：完整 JSON 文件 + 变更摘要

### 示例 2：仅必填参数

> 生成 Dashboard：
> - ds: aws-hk-uat
> - app: ebridge-integration

**行为**：使用默认模板，api 保持 `label_values` 动态查询

### 示例 3：自定义模板

> 用这个 JSON 生成 Dashboard：[粘贴 JSON]
> - ds: aws-sg-prd
> - app: my-service

**行为**：基于用户 JSON 进行变量替换和面板标准化

---

## 8. 输出格式

### 8.1 输出 JSON 文件（主要产物）

**必须将生成的 JSON 写入 `.json` 文件**。

- 文件命名：`{app}-detail-dashboard.json`
- 输出路径：当前工作目录或用户指定目录

### 8.2 变更摘要（对话中输出）

```markdown
## 变更摘要

✅ 已生成文件：`{app}-detail-dashboard.json`

| 项目 | 变更前 | 变更后 |
|------|--------|--------|
| Dashboard 标题 | `xxx` | `API监控看板-xxx-xxx` |
| 数据源 (ds) | `xxx` | `aws-sg-prd` |
| 应用 (app) | `xxx` | `ebridge-integration` |
| 面板总数 | 7 | 7（1 Row + 6 Timeseries） |

## 导入方式

1. 打开生成的 `.json` 文件，复制全部内容
2. Grafana → Dashboards → New → Import
3. 粘贴 JSON → Load → Import
```

---

## 9. 异常处理

| 异常场景 | 处理方式 |
|----------|----------|
| 未提供 `ds` | 提示：`请提供数据源名称` |
| 未提供 `app` | 提示：`请提供应用/服务名称` |
| 未提供 `api` 且无代码文件 | **保留 api 为 label_values 动态查询**（Prometheus 运行时自动填充） |
| `panels` 为空 | 生成 Row + 6 标准 Timeseries 面板 |
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
| 1.0.0 | 2026-08-26 | 初始版本，Row repeat + 6 Timeseries 标准布局 |
