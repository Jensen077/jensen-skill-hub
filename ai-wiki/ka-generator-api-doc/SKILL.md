---
name: ka-generator-api-doc
description: 从 Java/Spring Boot 项目代码自动生成标准化 API 接口文档。当用户提供项目代码路径并要求输出接口文档、生成 API 文档、输出接口说明、根据代码生成接口文档时，必须使用此 skill。支持的框架：Spring Boot（Controller/DTO/Entity），输入为项目路径，输出为 `{项目根目录}/docs/{project-name}-api-{YYYYMMDD}.md`。触发词：接口文档、API文档、生成文档、输出文档。
---

# API 文档生成器

从项目代码中提取接口信息，生成标准化的 API 接口文档。

## 工作流程

### 第一步：读取配置文件

先读取以下文件提取全局配置：

| 配置项 | 提取来源 | 示例 |
|---|---|---|
| `{project-name}` | `pom.xml` 的 `<artifactId>` 或项目根目录名 | `chat-master` |
| `{protocol}` | `application.yml` 的 `server.ssl.enabled` 或默认 `http` | `https` |
| `{domain}` | `application.yml` 的 `server.address` 或留空 | `api.example.com` |
| `{context-path}` | `application.yml` 的 `server.servlet.context-path` | `/chat-master` |
| `{success-code}` | `ResponseEnum` 或统一响应类中的成功码 | `200` |
| `{加密模式}` | Security 配置类、Filter 类、`**/encrypt/**/*.java`、`**/sign/**/*.java` | `content + sign` |
| `{aes-algorithm}` | 加密配置类中 AES 使用的算法 | `AES/GCM/NoPadding` |
| `{sign-algorithm}` | 签名配置类中签名算法 | `SHA256withRSA` |

### 第二步：读取模板

读取 `{当前skill根目录}/references/api-template.md` 作为输出模板，所有 `{占位符}` 必须一一对应填充。

### 第三步：扫描文件（按优先级）

| 优先级 | 文件类型 | 提取内容 |
|---|---|---|
| 1 | `**/*Controller.java` | Endpoint、Method、认证方式、权限注解 |
| 2 | `**/*DTO.java` / `**/*Request.java` / `**/*Response.java` / `**/*Command.java` / `**/*VO.java` | 请求/响应字段、类型、校验注解 |
| 3 | `**/schema/*.sql` / `**/entity/*.java` | 数据库字段定义、枚举值 |
| 4 | `**/error/*.java` / `**/exception/*.java` / `**/enums/*.java` / `**/enums.java` | 错误码定义及说明 |
| 5 | `**/constants/*.java` / `**/config/*.java` / `**/security/*.java` / `**/encrypt/*.java` / `**/filter/*.java` | 枚举类、状态码常量、加密配置、签名过滤器 |

### 第四步：信息提取规则

| 信息类型 | 提取来源 |
|---|---|
| Endpoint 路径 | `@RequestMapping`、`@GetMapping`、`@PostMapping`、`@PutMapping`、`@DeleteMapping` 注解 |
| HTTP Method | 注解类型推断（GET/POST/PUT/DELETE） |
| 认证要求 | `@PreAuthorize`、`@Authenticated`、Security 配置 |
| 请求字段 | DTO/Request/Command/VO 类的成员变量 + `@NotNull`、`@Size`、`@Length`、`@Min`、`@Max`、`@Pattern` 等校验注解（含长度约束） |
| 响应字段 | Response/VO 类或接口返回值类型 |
| 错误码 | 自定义异常类或错误码枚举 |
| 枚举值 | `@Enumerated`、`Enum` 类、`constants` 类 |

### 长度列填充规则

字段表中的"长度"列按以下规则填充：

| 注解 | 填充格式 | 示例 |
|---|---|---|
| `@Size(max=50)` | `最大50字符` | `最大50字符` |
| `@Size(min=2, max=50)` | `2-50字符` | `2-50字符` |
| `@Length(max=100)` | `最大100字符` | `最大100字符` |
| `@Min(1) @Max(100)` | `1-100` | `1-100` |
| `@Column(length=64)` | `最大64字符` | `最大64字符` |
| 数据库字段定义有长度 | 按数据库定义 | `最大32字符` |
| 无长度约束 | `-` | `-` |

### 第五步：模块划分

- **按业务域划分**，而非按技术层划分
- 同一业务域的接口归为同一模块
- 模块命名：`{业务域名称}`（如"用户"、"订单"、"鉴权"）
- 模块内接口按调用链路排序（鉴权 → 业务 → 查询）

### 第六步：填充模板

将提取的信息按模板结构填入对应占位符。无法从代码提取的占位符标注 `[待定]`。

## 输出

- 输出路径：`{项目根目录}/docs/{project-name}-api-{YYYYMMDD}.md`（即 `docs/` 目录下，文件名带日期后缀）
- 若 `docs/` 目录不存在，自动创建
- 用户指定路径时按指定路径输出
- 严格按模板结构输出，不得删除或跳过任何章节

## 生成规则

1. **模块划分**：按业务模块拆分，每个模块单独一个章节
2. **接口排序**：按调用链路排序（鉴权 → 业务 → 查询）
3. **枚举提取**：将所有字段的枚举值抽取到附录
4. **遗漏检查**：对照项目结构确认所有 Controller 均有对应文档
5. **加密标注**：全局加密放公共说明，接口级差异在接口下标注

## 枚举提取要求

- 所有字段的枚举值必须抽取到附录
- 每个枚举单独一个子章节，命名格式：`{枚举类名}（{中文说明}）`
- 枚举值从 `@Enumerated`、`Enum` 类、`constants` 类提取

## 遗漏检查

生成完成后，对照项目结构检查：
- [ ] 所有 Controller 均有对应文档
- [ ] 所有接口均有请求/响应示例
- [ ] 所有枚举字段均有附录说明
- [ ] 公共说明章节（环境、Header、加密、错误码）已填写
