# {项目名称} 接口文档规范

## 目录

- [公共说明](#公共说明)
- [模块一：{模块名}](#模块一{模块名})
- [模块二：{模块名}](#模块二{模块名})
- [使用流程](#使用流程)
- [附录：枚举](#附录枚举)

---

# 公共说明

## 1. 环境

| 环境 | 域名 |
|---|---|
| UAT | {protocol}://{domain}/{context-path} |
| PROD | {protocol}://{domain}/{context-path} |

## 2. 通用 Header

> 注意：按接口来，以下为通用项，特殊接口在具体章节标注

| Header | 必填 | 说明 |
|---|---|---|
| `Content-Type` | 是 | 固定为 `application/json` |

## 3. 加密与签名

> 根据项目实际安全配置填写；若无加密方案填 `[待定]`

### 加密模式

{加密模式，如 `content + sign` 模式，或 `[待定]`}

```json
{加密请求体示例，如无加密则填 `N/A`}
```

| 字段 | 说明 |
|---|---|
| `content` | {加密算法描述} |
| `sign` | {签名算法描述} |

### 算法

| 类型 | 算法 |
|---|---|
| AES | {aes-algorithm} |
| RSA | {rsa-algorithm} |
| 签名 | {sign-algorithm} |

### 时间戳

- `timeStamp` 为毫秒级 Unix 时间戳，请求时间与服务端时间偏差 ≤{time-diff} 分钟

### 响应

- {响应是否加密的说明}

## 4. 统一响应结构

```json
{
  "code": "{success-code}",
  "data": {},
  "msg": "SUCCESS"
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `code` | string | 响应码，`{success-code}` 表示成功 |
| `data` | object | 响应数据 |
| `msg` | string | 响应说明 |

### 响应码说明

| 错误码 | 说明 |
|---|---|
| `{success-code}` | 成功 |
| `{error-code-1}` | {错误说明} |
| `{error-code-2}` | {错误说明} |

---

# 模块一：{模块名}

## 1. {接口名称}

### 接口地址

- **路径**: `{context-path}/{uri}`
- **请求方式**: `{GET|POST|PUT|DELETE}`
- **完整地址**:
  - UAT: `{protocol}://{domain}/{context-path}/{uri}`
  - PROD: `{protocol}://{domain}/{context-path}/{uri}`
- **加密**: [{加密|不加密}] [如接口加密方式与全局不同，在此标注]

### 接口描述

{接口功能描述}

### 权限说明

{说明登录态要求、角色限制、IP白名单等；若无特殊权限要求，填"无"}

### Header

| Header | 必填 | 说明 |
|---|---|---|
| `Content-Type` | 是 | `application/json` |
| `Authorization` | {是|否} | {token说明} |

### 请求

#### 明文业务报文

```json
{
  {fields}
}
```

#### 字段说明

| 字段 | 类型 | 必填 | 长度 | 说明 |
|---|---|---|---|---|
| {field-name} | {type} | {是|否|条件必填} | {长度} | {说明} |

#### 参数校验规则

1. {规则1}
2. {规则2}

#### 实际请求体

> 若接口无加密，直接使用明文业务报文；若有加密，使用以下格式：

```json
{
  "content": "Base64 encrypted string",
  "sign": "Base64 signature string"
}
```

### 响应

#### 成功响应

```json
{
  "code": "{success-code}",
  "data": {
    {response-fields}
  },
  "msg": "SUCCESS"
}
```

#### 字段说明

| 字段 | 类型 | 说明 |
|---|---|---|
| {field-name} | {type} | {说明} |

#### 错误响应

| 错误码 | 说明 |
|---|---|
| `{error-code}` | {错误说明} |

### 响应示例

#### 成功

```json
{
  "code": "{success-code}",
  "data": {
    {response-example}
  },
  "msg": "SUCCESS"
}
```

#### {错误场景}

```json
{
  "code": "{error-code}",
  "data": null,
  "msg": "{error-message}"
}
```

#### 302 跳转 [如有]

```json
{
  "code": "{redirect-code}",
  "data": {
    "url": "{redirect-url}"
  },
  "msg": "{redirect-message}"
}
```

### 权限和边界条件

- {边界条件1}
- {边界条件2}

---

# 使用流程

## 对接步骤

{步骤说明}

## 时序图

```mermaid
sequenceDiagram
    participant Client as {调用方}
    participant Server as {服务方}

    {时序图内容}
```

## 注意事项

- {注意事项1}
- {注意事项2}

---

# 附录：枚举

## 1. {枚举名称}

| 值 | 说明 |
|---|---|
| `{enum-value}` | {说明} |
| `{enum-value}` | {说明} |
