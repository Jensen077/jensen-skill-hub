# 面板详细 JSON 配置

本文档提供 14 个标准面板的完整 JSON 配置片段。生成 Dashboard 时，按以下模板构建每个面板。

---

## Stat 面板通用配置

```json
{
  "datasource": { "type": "prometheus", "uid": "${ds}" },
  "fieldConfig": {
    "defaults": {
      "color": { "mode": "thresholds" },
      "mappings": [],
      "thresholds": {
        "mode": "absolute",
        "steps": [{ "color": "blue", "value": null }]
      },
      "unit": "short"
    },
    "overrides": []
  },
  "gridPos": { "h": 4, "w": 6, "x": 0, "y": 0 },
  "options": {
    "colorMode": "value",
    "graphMode": "area",
    "justifyMode": "auto",
    "orientation": "auto",
    "percentChangeColorMode": "standard",
    "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false },
    "showPercentChange": false,
    "textMode": "auto",
    "wideLayout": true
  },
  "pluginVersion": "11.5.1",
  "targets": [{
    "datasource": { "type": "prometheus", "uid": "${ds}" },
    "editorMode": "code",
    "expr": "<PromQL>",
    "legendFormat": "<标签>",
    "range": true,
    "refId": "A"
  }],
  "title": "<标题>",
  "type": "stat"
}
```

### Stat 1: 总请求数

- **gridPos**: `{ "h": 4, "w": 6, "x": 0, "y": 0 }`
- **title**: `📊 总请求数`
- **thresholds**: `[{ "color": "blue", "value": null }]`
- **unit**: `short`
- **expr**: `sum(increase(api_request_total{app="$app", uri!="/**"}[$__range]))`

### Stat 2: 总失败数

- **gridPos**: `{ "h": 4, "w": 6, "x": 6, "y": 0 }`
- **title**: `❌ 总失败数`
- **thresholds**: `[{ "color": "green", "value": null }, { "color": "red", "value": 1 }]`
- **unit**: `short`
- **expr**: `sum(increase(api_request_total{app="$app", success="0", uri!="/**"}[$__range]))`

### Stat 3: 第三方总失败数

- **gridPos**: `{ "h": 4, "w": 6, "x": 12, "y": 0 }`
- **title**: `🔌 第三方总失败数`
- **thresholds**: `[{ "color": "green", "value": null }, { "color": "red", "value": 1 }]`
- **unit**: `short`
- **expr**: `sum(increase(dp_biz_operation_total{app="$app", result_type!="OK"}[$__range]))`

### Stat 4: 总平均 RT

- **gridPos**: `{ "h": 4, "w": 6, "x": 18, "y": 0 }`
- **title**: `⏱️ 总平均RT`
- **thresholds**: `[{ "color": "blue", "value": null }]`
- **unit**: `ms`
- **expr**: `sum(increase(api_request_time_sum{app="$app", uri!="/**"}[$__range])) / sum(increase(api_request_time_count{app="$app", uri!="/**"}[$__range]))`

---

## Table 面板通用配置

```json
{
  "datasource": { "type": "prometheus", "uid": "${ds}" },
  "fieldConfig": {
    "defaults": {
      "color": { "mode": "thresholds" },
      "custom": { "align": "auto", "cellOptions": { "type": "auto" }, "inspect": false },
      "mappings": [],
      "thresholds": { "mode": "absolute", "steps": [{ "color": "green", "value": null }] }
    },
    "overrides": [{
      "matcher": { "id": "byName", "options": "<指标列名>" },
      "properties": [
        { "id": "custom.cellOptions", "value": { "type": "color-background" } },
        { "id": "color", "value": { "mode": "thresholds" } },
        { "id": "thresholds", "value": {
          "mode": "absolute",
          "steps": [
            { "color": "green", "value": null },
            { "color": "yellow", "value": 10 },
            { "color": "red", "value": 50 }
          ]
        }}
      ]
    }]
  },
  "gridPos": { "h": 7, "w": 6, "x": 0, "y": 4 },
  "options": {
    "cellHeight": "sm",
    "footer": { "countRows": false, "fields": "", "reducer": ["sum"], "show": false },
    "showHeader": true,
    "sortBy": [{ "desc": true, "displayName": "<指标列名>" }]
  },
  "pluginVersion": "11.5.1",
  "targets": [{
    "datasource": { "type": "prometheus", "uid": "${ds}" },
    "editorMode": "code",
    "expr": "<PromQL>",
    "format": "table",
    "instant": true,
    "legendFormat": "<标签>",
    "range": false,
    "refId": "A"
  }],
  "title": "<标题>",
  "transformations": [{
    "id": "organize",
    "options": {
      "excludeByName": {},
      "indexByName": {},
      "renameByName": { "Value": "<指标列名>", "<分组字段>": "<显示名>" }
    }
  }],
  "type": "table"
}
```

### Table 1: 失败 API 排行

- **gridPos**: `{ "h": 7, "w": 6, "x": 0, "y": 4 }`
- **title**: `🔥 失败 API 排行 (Top 10)`
- **指标列名**: `失败次数`
- **分组字段**: `uri` → `URI`
- **expr**: `topk(10, sum by(uri)(increase(api_request_total{app="$app", success="0", uri!="/**"}[$__range])) and sum by(uri)(increase(api_request_total{app="$app", uri!="/**"}[$__range])) > 10)`

### Table 2: 失败第三方 API 排行

- **gridPos**: `{ "h": 7, "w": 6, "x": 6, "y": 4 }`
- **title**: `🔥 失败第三方 API 排行 (Top 10)`
- **指标列名**: `失败次数`
- **分组字段**: `op_code` → `操作码`
- **expr**: `topk(10, sum by(op_code)(increase(dp_biz_operation_total{app="$app", result_type!="OK"}[$__range])) and sum by(op_code)(increase(dp_biz_operation_total{app="$app"}[$__range])) > 10)`

### Table 3: API RT 排行

- **gridPos**: `{ "h": 7, "w": 6, "x": 12, "y": 4 }`
- **title**: `🐢 API RT 排行 (Top 10)`
- **指标列名**: `平均耗时 (ms)`
- **分组字段**: `uri` → `URI`
- **unit**: `ms`
- **thresholds**: `[{ "color": "green", "value": null }, { "color": "yellow", "value": 2000 }, { "color": "red", "value": 5000 }]`
- **expr**: `topk(10, (sum by(uri)(increase(api_request_time_sum{app="$app", uri!="/**"}[$__range])) / sum by(uri)(increase(api_request_time_count{app="$app", uri!="/**"}[$__range]))) and sum by(uri)(increase(api_request_time_count{app="$app", uri!="/**"}[$__range])) > 10)`

### Table 4: 第三方 API RT 排行

- **gridPos**: `{ "h": 7, "w": 6, "x": 18, "y": 4 }`
- **title**: `🐢 第三方 API RT 排行 (Top 10)`
- **指标列名**: `平均耗时 (ms)`
- **分组字段**: `class` → `类`, `method` → `方法`
- **excludeByName**: `{ "class": true }`
- **unit**: `ms`
- **thresholds**: `[{ "color": "green", "value": null }, { "color": "yellow", "value": 2000 }, { "color": "red", "value": 5000 }]`
- **expr**: `topk(10, (sum by(class,method)(increase(dp_method_exec_time_total{app="$app"}[$__range])) / sum by(class,method)(increase(dp_method_exec_total{app="$app"}[$__range]))) and sum by(class,method)(increase(dp_method_exec_total{app="$app"}[$__range])) > 10)`

---

## Timeseries 面板通用配置

```json
{
  "datasource": { "type": "prometheus", "uid": "${ds}" },
  "fieldConfig": {
    "defaults": {
      "color": { "mode": "palette-classic" },
      "custom": {
        "axisBorderShow": false,
        "axisCenteredZero": false,
        "axisColorMode": "text",
        "axisLabel": "",
        "axisPlacement": "auto",
        "barAlignment": 0,
        "barWidthFactor": 0.6,
        "drawStyle": "line",
        "fillOpacity": 0,
        "gradientMode": "none",
        "hideFrom": { "legend": false, "tooltip": false, "viz": false },
        "insertNulls": false,
        "lineInterpolation": "linear",
        "lineWidth": 1,
        "pointSize": 5,
        "scaleDistribution": { "type": "linear" },
        "showPoints": "auto",
        "spanNulls": false,
        "stacking": { "group": "A", "mode": "none" },
        "thresholdsStyle": { "mode": "off" }
      },
      "mappings": [],
      "thresholds": { "mode": "absolute", "steps": [{ "color": "green", "value": null }, { "color": "red", "value": 80 }] }
    },
    "overrides": []
  },
  "gridPos": { "h": 8, "w": 12, "x": 0, "y": 11 },
  "options": {
    "legend": { "calcs": [], "displayMode": "list", "placement": "bottom", "showLegend": true },
    "tooltip": { "hideZeros": false, "mode": "multi", "sort": "none" }
  },
  "pluginVersion": "11.5.1",
  "targets": [{
    "datasource": { "type": "prometheus", "uid": "${ds}" },
    "editorMode": "code",
    "expr": "<PromQL>",
    "legendFormat": "<标签>",
    "range": true,
    "refId": "A"
  }],
  "title": "<标题>",
  "type": "timeseries"
}
```

### Timeseries 1: QPS

- **gridPos**: `{ "h": 8, "w": 12, "x": 0, "y": 11 }`
- **title**: `📈 QPS`
- **unit**: `reqps`
- **legendFormat**: `total`
- **expr**: `sum(rate(api_request_total{app="$app",uri=~"$api"}[1m]))`

### Timeseries 2: API LATENCY

- **gridPos**: `{ "h": 8, "w": 12, "x": 12, "y": 11 }`
- **title**: `⏱️ API LATENCY (2 min)`
- **unit**: `ms`
- **legend**: `{ "displayMode": "table", "placement": "right" }`
- **legendFormat**: `{{uri}}`
- **expr**: `sum by(uri)(increase(api_request_time_sum{app="$app",uri=~"$api"}[2m]))/sum by(uri)(increase(api_request_time_count{app="$app",uri=~"$api"}[2m]))`

### Timeseries 3: QPM (总量)

- **gridPos**: `{ "h": 8, "w": 12, "x": 0, "y": 19 }`
- **title**: `📊 QPM`
- **unit**: `rotrpm`
- **scaleDistribution**: `{ "log": 2, "type": "symlog" }`
- **legendFormat**: `total`
- **expr**: `sum (increase(api_request_total{app="$app",uri=~"$api"}[1m]))`

### Timeseries 4: QPM (按 URI)

- **gridPos**: `{ "h": 8, "w": 12, "x": 12, "y": 19 }`
- **title**: `📊 QPM (按 URI)`
- **unit**: `rotrpm`
- **legend**: `{ "calcs": ["lastNotNull"], "displayMode": "table", "placement": "right" }`
- **legendFormat**: `{{uri}}`
- **expr**: `sum by(uri)(increase(api_request_total{app="$app",uri=~"$api"}[1m]))`

### Timeseries 5: API 成功率

- **gridPos**: `{ "h": 8, "w": 24, "x": 0, "y": 27 }` ⚠️ 全宽
- **title**: `✅ API 成功率`
- **unit**: `percentunit`
- **max**: `1`
- **axisSoftMax**: `-3`
- **legend**: `{ "calcs": ["lastNotNull"], "displayMode": "table", "placement": "right" }`
- **legendFormat**: `{{uri}}`
- **expr**: `sum by(uri)(rate(api_request_total{app="$app", uri=~"${api}",success="1"}[1m]))/sum by(uri)(rate(api_request_total{app="$app",uri=~"${api}"}[1m]))`

### Timeseries 6: 接口请求量统计

- **gridPos**: `{ "h": 8, "w": 24, "x": 0, "y": 35 }` ⚠️ 全宽
- **title**: `📊 接口请求量统计看板`
- **description**: `按选择的时间周期统计`
- **unit**: 无（默认）
- **legend**: `{ "calcs": ["lastNotNull"], "displayMode": "table", "placement": "right" }`
- **legendFormat**: `__auto`
- **expr**: `sum by(uri)(increase(api_request_total{app="$app",uri=~"$api"}[$__range]))`
