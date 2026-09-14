# 面板详细 JSON 配置

本文档提供 Row + 6 Timeseries 面板的完整 JSON 配置片段。

---

## Row 面板

```json
{
  "collapsed": false,
  "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 },
  "id": 2,
  "panels": [],
  "repeat": "api",
  "title": "$api",
  "type": "row"
}
```

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
      "thresholds": {
        "mode": "absolute",
        "steps": [
          { "color": "green", "value": null },
          { "color": "red", "value": 80 }
        ]
      }
    },
    "overrides": []
  },
  "options": {
    "legend": { "calcs": [], "displayMode": "list", "placement": "bottom", "showLegend": true },
    "tooltip": { "hideZeros": false, "mode": "multi", "sort": "none" }
  },
  "pluginVersion": "11.5.1",
  "type": "timeseries"
}
```

---

## Panel 1: Success Rate/成功率

- **gridPos**: `{ "h": 8, "w": 12, "x": 0, "y": 1 }`
- **title**: `Success Rate/成功率`
- **id**: 6
- **unit**: `percentunit`
- **max**: 1
- **axisSoftMax**: -3
- **legend**: `{ "calcs": [], "displayMode": "list", "placement": "bottom" }`

**Target A** (Http Success Rate):
```promql
(
  sum(rate(api_request_total{app="$app", uri="${api:raw}",http_code="200"}[$__rate_interval])) 
  /sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval])) 
  and sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval])) >0
) or vector(1)
```

**Target C** (Bussiness Success Rate):
```promql
(
  sum(rate(api_request_total{app="$app", uri="${api:raw}",success="1"}[$__rate_interval]))
  /sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval]))
  and sum(rate(api_request_total{app="$app",uri="${api:raw}"}[$__rate_interval]))>0
) or vector(1)
```

---

## Panel 2: API LATENCY (1 min AVG)

- **gridPos**: `{ "h": 8, "w": 12, "x": 12, "y": 1 }`
- **title**: `API LATENCY (1 min AVG)/接口平均响应时间`
- **id**: 8
- **unit**: `ms`
- **legend**: `{ "calcs": [], "displayMode": "list", "placement": "bottom" }`

**Target A**:
```promql
sum(increase(api_request_time_sum{app="$app",uri="${api:raw}"}[$__interval]))/sum(increase(api_request_time_count{app="$app",uri="${api:raw}"}[$__interval]))
```
- **legendFormat**: `AVG TIME`
- **interval**: `1m`

---

## Panel 3: QPM

- **gridPos**: `{ "h": 8, "w": 12, "x": 0, "y": 9 }`
- **title**: `QPM`
- **id**: 12
- **unit**: `rotrpm`
- **decimals**: 0
- **legend**: `{ "calcs": [], "displayMode": "list", "placement": "bottom" }`
- **tooltip sort**: `desc`

**Target A** (total):
```promql
sum (increase(api_request_total{app="$app",uri="${api:raw}"}[$__interval]))
```
- **legendFormat**: `total`

**Target B** (fail):
```promql
sum (increase(api_request_total{app="$app",success="0",uri="${api:raw}"}[$__interval]))
```
- **legendFormat**: `fail`

**Target C** (success):
```promql
sum (increase(api_request_total{app="$app",success="1",uri="${api:raw}"}[1m]))
```
- **legendFormat**: `success`

---

## Panel 4: API LATENCY(5 min) - 百分位

- **gridPos**: `{ "h": 8, "w": 12, "x": 12, "y": 9 }`
- **title**: `API LATENCY(5 min)`
- **id**: 19
- **unit**: `ms`
- **legend**: `{ "calcs": ["lastNotNull", "max"], "displayMode": "list", "placement": "right" }`

**Target A**:
```promql
max by(quantile)(api_request_time{app="$app",uri="${api:raw}"})
```
- **legendFormat**: `{{quantile}}`

**overrides**（displayName 映射）：

| 原始值 | 显示名 |
|--------|--------|
| 0.2 | P20 |
| 0.5 | P50 |
| 0.8 | P80 |
| 0.9 | p90 |
| 0.95 | P95 |
| 0.99 | P99 |

---

## Panel 5: 错误码次数

- **gridPos**: `{ "h": 8, "w": 12, "x": 0, "y": 17 }`
- **title**: `错误码次数`
- **id**: 21
- **unit**: `reqpm`
- **decimals**: 0
- **legend**: `{ "calcs": ["lastNotNull"], "displayMode": "list", "placement": "right" }`
- **tooltip sort**: `desc`

**Target A**:
```promql
sum by (error_code,error_code2) (increase(api_request_total{app="$app",uri="${api:raw}",error_code!~"0|NULL"}[1m]))
```
- **format**: `time_series`
- **legendFormat**: `{{error_code}} - {{error_code2}}`

---

## Panel 6: API异常错误次数

- **gridPos**: `{ "h": 8, "w": 12, "x": 12, "y": 17 }`
- **title**: `API异常错误次数`
- **id**: 18
- **unit**: `reqpm`
- **decimals**: 0
- **legend**: `{ "calcs": ["lastNotNull"], "displayMode": "list", "placement": "right" }`
- **tooltip sort**: `desc`

**Target A**:
```promql
sum by (exception)(
  increase(api_request_total{app="$app",uri="${api:raw}",exception!="NULL"}[1m])
)
```
- **legendFormat**: `{{exception}}`
