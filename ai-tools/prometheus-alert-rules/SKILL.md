---
name: prometheus-alert-rules
description: 根据 Prometheus 指标规范生成 API 服务告警规则 YAML（6 维度 × P0-P3 分级：总/单URI 成功率、总/单URI 平均 RT、第三方 API 成功率与耗时、最低流量门槛）。当用户需要为新服务创建/调整告警规则，或按 api-agent-vces-rakuten.yml 模板生成 rules yml 时使用。
---

# Prometheus 告警规则生成器

生成可直接落库的 **Prometheus 告警规则 `.yml` 文件**（非说明文档），基于 [references/alert-rules-template.yml](references/alert-rules-template.yml)（源自日本乐天 vces 生产配置）做占位符替换。用户可提供其他规则文件替代。

## 1. 模板结构：6 维度 × P3/P2/P1/P0 = 24 条

| 组 | 维度 | 指标 | 窗口 | 聚合维度 | 告警名后缀 |
|----|------|------|------|---------|-----------|
| 1 | 总接口成功率（兜底） | `api_request_total` | `[2m]` | `namespace,app` | `TotalSuccessRate` |
| 2 | 单 URI 成功率 | `api_request_total` | `[2m]` | `namespace,app,uri` | `UriSuccessRate` |
| 3 | 总接口平均 RT | `api_request_time_sum/_count` | `[2m]` | `namespace,app` | `TotalAvgRt` |
| 4 | 单 URI 平均 RT | `api_request_time_sum/_count` | `[2m]` | `namespace,app,uri` | `UriAvgRt` |
| 5 | 第三方 API 成功率 | `dp_biz_operation_total` | `[10m]` | `namespace,app,op_code,op_name` | `BizOpSuccessRate` |
| 6 | 第三方 API 耗时 | `dp_method_exec_time_total/_total` | `[10m]` | `namespace,app,class,method` | `MethodExecAvgRt` |

> 1~4 组是自身接口指标，用 `[2m]` 保检出速度；5~6 组是第三方埋点指标、调用频次低，用 `[10m]` 保百分比统计有意义。

## 2. 占位符（模板已内置，只需替换）

| 占位符 | 必填 | 说明 | 示例 |
|--------|------|------|------|
| `{{app}}` | ✅ | 应用名，所有 PromQL 的 `app` 过滤值 | `back-business-vces-rakuten-website` |
| `{{appSlug}}` | ✅ | **告警名前缀**，app 名的业务短 slug（去掉 `back-business-`、`-website` 等前后缀） | `vces-rakuten` |
| `{{serviceName}}` | ✅ | 中文服务名，用于 summary/description 文案 | `日本乐天vces服务` |
| `{{groupName}}` | ✅ | alert group 名称 | `agent-vces-rakuten-api-monitor` |

缺少任一必填项**必须向用户询问**，不得猜测；`app_slug` 取值需与用户确认。

- `labels.team` 固定 `BY`，`alertType` 固定 `qw`（P3~P1）/ `tel`（P0），均为字面值、非占位符。
- ⚠️ `name` / `alert` / annotations 中以 `{{` 开头的值，模板已加引号 —— `{` 作为 YAML 值首字符非法，**引号不可去掉**。

## 3. 执行流程

1. **收集参数** —— 只需第 2 节的 4 个必填占位符，缺失才询问；`app_slug` 由 `app` 派生后确认

   > ℹ️ **环境与区域目录不是参数**：只有要把文件放进 prometheus-rule 仓库时才涉及（见第 6 节），其余情况默认落在当前目录。
   > ℹ️ **阈值覆盖不主动询问**：默认沿用第 4 节梯度，仅当用户明确要求时才改。

2. **替换占位符** —— 全局纯文本替换，不做结构性改写：

   ```bash
   sed -i '' -e 's/{{app}}/<app>/g' -e 's/{{appSlug}}/<app_slug>/g' \
             -e 's/{{serviceName}}/<service_name>/g' \
             -e 's/{{groupName}}/<group_name>/g' <output_file>
   ```

   > ⚠️ 保留 `uri!="/**"` 过滤、`namespace` 聚合、`success="0"` / `result_type!="OK"` 判定口径。
   > ⚠️ 不要动 annotations 里的 `{{ $labels.app }}` / `{{ $labels.uri }}` —— 那是 Prometheus 模板语法；本模板占位符不含 `$`。

3. **校验** —— 全部通过才交付

   ```bash
   grep -c '{{[a-zA-Z]' <output_file>          # 必须为 0
   promtool check rules <output_file>           # 预期 SUCCESS: 24 rules found
   ```

   > ⚠️ 残留的 `{{serviceName}}` 会被当作 **Go 模板函数**，导致**整个 rule group 加载失败**（不是单条失效）—— 这是模板唯一的"整组炸"风险点。
   > ℹ️ 占位符模板本身**必然** promtool 失败，只要求替换后的产物通过。
   > 另外检查每条 `expr` 的分组标签与 `AND` 子句一致（PromQL 的 `AND` 按全部标签匹配，标签集不一致会静默失配）。

4. **输出** —— 写入当前目录 `<appSlug>-alerts.yml`，并在对话中输出摘要（app、app_slug、规则数、是否覆盖阈值、输出路径）

## 4. 默认阈值梯度

| 级别 | for | 通知 | ① 总成功率 | ② 单URI成功率 | ③ 总RT | ④ 单URI RT | ⑤ 三方成功率 | ⑥ 三方RT |
|------|-----|------|-----------|--------------|--------|------------|-------------|----------|
| P3 | 5m | qw | < 0.90 | < 0.90 | > 2000ms | > 3000ms | < 0.90 | > 3000ms |
| P2 | 3m | qw | < 0.85 | < 0.82 | > 4000ms | > 5000ms | < 0.85 | > 5000ms |
| P1 | 2m | qw | < 0.70 | < 0.70 | > 10000ms | > 12000ms | < 0.70 | > 10000ms |
| P0 | 1m | tel | < 0.40 | < 0.30 | > 20000ms | > 25000ms | < 0.40 | > 25000ms |

最低流量门槛（不满足则不告警）：

| 级别 | ①~④ 自身接口 | ⑤ 三方成功率 | ⑥ 三方耗时 |
|------|-------------|-------------|-----------|
| P3 / P2 | 总调用 > 10 | 总调用 > 10 | 总调用 ≥ 2 |
| P1 | 总调用 > 10 | **失败数 ≥ 3** | 总调用 ≥ 3 |
| P0 | 总调用 > 10 | **失败数 ≥ 5** | 总调用 ≥ 5 |

> ⑤ 的低级别用总调用量门槛防噪（保证百分比统计有意义），高级别改用失败数门槛保召回（低频 `op_code` 出故障时不静默）。

## 5. 命名与标签

- **告警名**：`{app_slug}{后缀}{级别}`，如 `vces-rakutenTotalSuccessRateP3`（后缀见第 1 节表）
- **labels**：`severity: p3|p2|p1|p0`（小写）、`alertType: qw|tel`、`team: 'BY'`
- **summary 前缀**：P3 `【提示】`、P2 `【预警】`、P1 `【严重】`、P0 `【故障】`
- **annotations**：`description` 必须回带分组标签（`uri` / `op_code` / `op_name` / `method`）便于定位，例：

  ```yaml
  summary: "【预警】日本乐天vces服务-单URI {{ $labels.uri }} 成功率低于82%"
  description: "app={{ $labels.app }}, uri={{ $labels.uri }}，成功率={{ $value }}，持续3分钟低于82%"
  ```

> ⚠️ **`app_slug` 是运维契约**：`env/<ENV>/alertmanager-config.yml` 中存在按前缀匹配的路由（如 `matchers: 'alertname=~"^uk-dpa-"'`）。改已上线服务的前缀前，必须先查该文件的路由与静默规则，否则告警会进错群或漏发。

## 6. 输出

**默认当前工作目录**，文件名 `<appSlug>-alerts.yml`（如 `vces-rakuten-alerts.yml`）—— 由第 2 步已确认的 `app_slug` 派生，不需要额外命名决策。

用户指定落点则从其指定。若目标是 prometheus-rule 仓库，常规路径为 `env/<ENV>/AWS/<REGION_DIR>/rules/<文件名>`（如 `env/PRD/AWS/AWS-JP-VISA/rules/api-agent-vces-rakuten.yml`），文件名沿用该仓库既有命名 —— 只有这种场景才需要确认环境与区域。

## 7. 边界情况

| 场景 | 处理方式 |
|------|----------|
| 未提供模板文件 | 用 `references/alert-rules-template.yml` |
| 用户只给部分维度 | 按指定维度生成，说明未覆盖维度 |
| 用户要求写入规则仓库但未指明环境/区域 | 询问；并提示该仓库可能存在同名文件需同步修改 |
| 规则数 ≠ 24 或重名 | 不交付，先定位是复制遗漏还是结构改写错误 |
| 用户要求第 6 组按 `op_code/op_name` 分组 | 拒绝：该指标来自 common-metrics SDK，只有 `class,method` 标签 |
| `promtool` 报 `function "xxx" not defined` | 占位符未替换干净，回到步骤 2 补齐 |

## 参考

- 规则模板（占位符版，24 条规则）：[references/alert-rules-template.yml](references/alert-rules-template.yml)

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0.0 | 2026-09-22 | 初始版本 |
