---
name: ka-wiki
description: Use when user asks to generate ops docs, project wiki, view project config, understand project structure, or deploy info for Spring Boot projects. Triggers: "生成运维文档"、"项目文档"、"生成 wiki"、"查看配置"、"了解项目"、"怎么部署"。
---

# ka-wiki - 项目运维文档生成器

扫描 Spring Boot 项目，生成运维文档。自动识别项目架构、配置方式、业务特性。

**核心原则：** 按实际扫描结果输出，没有的特性不输出空章节。先扫描，后输出。

## 扫描流程

### 1. 项目识别

**读取 pom.xml 识别：**
- Parent POM（saas-parent-website / saas-parent / ka-common / 其他）
- Java 版本
- artifactId、context-path
- 打包方式

**识别包结构：**
- 扫描 `src/main/java` 下的包结构
- 识别 Controller、Service、Logic、Mapper 等分层

### 2. 配置扫描

**配置文件：**
- bootstrap.yaml（Nacos 配置中心）
- application.properties / application-{env}.properties
- conf/{env}/config.properties

**配置读取方式（自动识别）：**
- `LocalGlobal.getConfig("xxx")` → 老项目静态读取
- `@Value("${xxx}")` → Spring 注入
- `@ConfigurationProperties(prefix="xxx")` → 配置类绑定
- `${xxx.yyy}` Nacos 占位符 → 远程配置

**配置项提取（按语义分类，按优先级扫描）：**

| 优先级 | 分类 | 匹配关键词 |
|--------|------|-----------|
| 必扫 | 基础配置 | application.name、context-path、port、profiles |
| 必扫 | 数据库 | datasource、jdbc、url、username、driver |
| 重要 | 消息队列 | mq、rocketmq、kafka、topic、consumer |
| 重要 | 缓存 | redis、cache、redisson |
| 重要 | 密钥/证书 | key、secret、cert、password、pem、jks |
| 可选 | 租户 | tenant、code |
| 可选 | 域名 | domain、url、host、front.url |
| 可选 | 第三方API | api、gateway、appid |
| 可选 | 支付 | pay、payment、pci、order |
| 可选 | 消息中心 | message.center、msg-center |
| 可选 | 定时任务 | job、cron、schedule、xxl |

### 3. 业务特性识别

**自动识别（按文件/代码模式）：**

| 特性 | 文件/代码模式 |
|------|--------------|
| 免登 | 日志含"免登"、code参数、跳转逻辑 |
| 核销 | writeOff、状态变更、MQ消息 |
| 支付 | pay/order、金额处理、订单状态 |
| MQ消费 | @RocketMQMessageListener、*Consumer.java、*Listener.java |
| 定时任务 | @Scheduled、@XxlJob、*Task.java、*Job.java |
| 授权 | authorized、token、JWT、interceptor |
| 邮件/短信 | msg-center-sdk、消息中心、email/sms |
| PDF生成 | OpenPDF、FreeMarker、PdfUtil |
| 文件存储 | AWS S3、OSS、AwsUploadProvider |
| 加密 | RSA、SM2、SM4、AES、encry/*.java |
| 分布式锁 | RedisLock、DistributedLock |
| 限流 | RateLimiter、@RateLimiter |
| 多语言 | i18n、language、locale |
| 3DS验证 | 3DS、threeDS、challenge |
| 飞书通知 | webhook、feishu、lark |

**兜底策略（未匹配到已知模式时）：**
1. 扫描所有 Controller 类的 @RequestMapping 路径和方法名
2. 扫描所有 Service/Logic 类的 public 方法名
3. 扫描所有带 @Component/@Service 注解的类
4. 从方法名和注释推断业务特性（如 pay→支付、auth→授权）
5. 在输出中标注"（推断）"，说明是基于代码分析推断而非确定性匹配

### 4. 枚举/常量扫描

扫描 `*Enum.java`、`Constants.java`、`*Constant.java`：
- 订单状态枚举
- 支付状态枚举
- 商品类型枚举
- Redis Key 前缀
- 配置项常量

### 5. 部署信息扫描

**CI/CD（按优先级）：**
- .gitlab-ci.yml → 提取 variables、script、artifacts、environment
- Jenkinsfile → 提取 environment、stages、post
- Dockerfile → 提取 FROM、ENTRYPOINT（含JVM参数）、ENV、EXPOSE

**K8s 部署（如存在）：**
- Deployment → replicas、resources.limits、env
- Service → port、targetPort
- Ingress → host、path

**启动脚本（如存在）：**
- java -jar 命令中的 JVM 参数（-Xms、-Xmx、-XX:*）
- --spring.profiles.active 参数

**资源配置：**
- Pod 副本数、CPU、内存限制

## 输出路径

**默认输出到当前项目 docs/ 目录：**
```
docs/{项目名称}-wiki-doc.md
```

**如果 docs/ 目录不存在，自动创建。**

**用户可以指定自定义路径：**
- "生成运维文档到 wiki/"
- "输出到 README.md"

## 输出质量校验

生成文档后，执行以下检查：

1. **占位符检查**：扫描文档中是否残留 `{xxx}` 占位符，如有则补充数据
2. **"待扫描"检查**：扫描文档中是否残留"待扫描"字样，如有则补充扫描
3. **空章节检查**：如果某章节只有标题没有内容，删除该章节
4. **一致性检查**：配置项引用的值是否与配置文件一致

## 输出文档

**结构（灵活组织，不强制固定）：**

```markdown
# {项目名称} 运维文档

> 自动生成于 {日期}

## 1. 项目概述
- 应用名称、上下文路径、技术栈、端口

## 2. 环境配置
- 环境列表（Profile、域名、租户）
- 数据库配置
- 中间件配置（MQ、Redis）
- 第三方配置（API地址、密钥）

## 3. 配置清单
- 配置文件列表
- 配置项分类（按语义）
- 密钥/证书配置
- Nacos 共享配置

## 4. 业务接口
- Controller 列表
- 核心接口详情

## 5. 依赖服务
- 内部依赖（SaaS 组件）
- 外部依赖（第三方 SDK）

## 6. 部署信息
- CI/CD 配置
- JVM 参数
- 资源配置

## 7. 运维手册
- 常用命令
- 健康检查
- 监控埋点
- 故障排查

## 8. 风险提示
- 安全隐患（明文密码、硬编码密钥）
- 配置问题（命名不统一、冗余配置）
- 依赖风险（版本冲突、过期依赖）
```

**灵活输出：**
- 根据项目实际情况调整章节
- 没有的特性不输出空章节
- 重点突出异常和风险

## 6个项目参考模式

### hsbank（徽商银行）
- Parent: saas-parent-website
- 配置读取: LocalGlobal.getConfig()
- 特性: 免登、支付、授权、注册、短信、图片验证码
- 密钥: 配置文件硬编码

### cpicgiftbag（太保礼宾车）
- Parent: saas-parent
- 配置读取: LocalGlobal.getConfig()
- 特性: 免登、核销、MQ消费(3个)、定时任务
- 密钥: 配置文件硬编码
- 特点: RSA+AES双重加密

### ebridge（新加坡eBridge）
- Parent: ka-common
- 配置读取: @Value
- 特性: 免登、核销、支付、MQ、定时任务、邮件、PDF、AWS S3
- 密钥: AWS KMS
- 特点: 国际化、飞书通知

### japan-smcc（日本SMCC）
- Parent: saas-parent-website
- 配置读取: @Value + @ConfigurationProperties
- 特性: 免登、支付(3DS)、MQ、定时任务、邮件、XSS防护
- 密钥: AWS KMS
- 特点: JWT认证、防腐层、日志脱敏

### quanzhou（泉州银行）
- Parent: ka-common
- 配置读取: @Value
- 特性: 免登、SM2+SM4加密、限流
- 密钥: 配置文件
- 特点: 极简架构、国密算法

### alipay-voyager（Alipay+ Voyager）
- Parent: ka-common
- 配置读取: @Value
- 特性: 多平台免登、JWT、支付、MQ、核销、PDF、汇率缓存
- 密钥: Nacos 占位符
- 特点: 多平台支持、策略模式、本地缓存

## 使用场景

用户说：
- "生成运维文档"
- "这个项目怎么部署"
- "查看项目配置"
- "了解下这个项目"
- "生成项目 wiki"

## 参考文件

- 输出模板：`references/output-template.md`
- 扫描模式：`references/scan-patterns.md`
- 输出示例：`references/examples/hsbank-output.md`
