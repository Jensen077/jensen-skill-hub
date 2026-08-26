# 扫描模式参考

## 一、通用配置扫描模式

### 1.1 基础配置（必扫）
```properties
spring.application.name=
server.servlet.context-path=
server.port=
spring.profiles.active=
```

### 1.2 数据库配置（必扫）
```properties
spring.datasource.url=
spring.datasource.username=
spring.datasource.password=
spring.datasource.driver-class-name=
spring.datasource.name=
```

### 1.3 消息队列（重要）
```properties
# RocketMQ
rocketmq.name-server=
rocketmq.producer.group=
rocketmq.consumer.group=

# Kafka
spring.kafka.bootstrap-servers=
spring.kafka.consumer.group-id=
```

### 1.4 缓存（重要）
```properties
spring.redis.host=
spring.redis.port=
spring.redis.password=
spring.redis.database=
```

### 1.5 租户信息
```properties
tenant.code=
tenant.id=
```

### 1.6 域名配置
```properties
business.domain.url=
front.url.*=
```

### 1.7 密钥/证书（重要）
```properties
# 通用模式
*.key=
*.secret=
*.password=
*.cert=
*.pem=
```

### 1.8 第三方 API
```properties
api.base.url=
api.path.*=
appid=
app.secret=
```

### 1.9 定时任务
```properties
# XXL-JOB
xxl.job.admin.addresses=
xxl.job.executor.appname=

# Spring Scheduled
spring.task.scheduling.pool.size=
```

### 1.10 Nacos 配置中心
```properties
spring.cloud.nacos.config.server-addr=
spring.cloud.nacos.config.namespace=
spring.cloud.nacos.config.shared-configs=
```

---

## 二、配置读取方式识别模式

### 2.1 LocalGlobal（老项目）
```java
// 特征：静态方法调用
LocalGlobal.getConfig("xxx")
LocalGlobal.getProperty("xxx")
```

### 2.2 @Value（Spring 注入）
```java
// 特征：字段注解
@Value("${xxx.yyy}")
private String xxx;
```

### 2.3 @ConfigurationProperties（配置类绑定）
```java
// 特征：类注解 + prefix
@ConfigurationProperties(prefix = "xxx")
public class XxxProperties { ... }
```

### 2.4 Nacos 占位符（远程配置）
```java
// 特征：配置文件中的占位符引用
${xxx.yyy:default}
```

---

## 三、业务特性识别模式（通用）

| 特性 | 文件/代码模式 |
|------|--------------|
| 免登 | 日志含"免登"/"GoUse"、code参数、跳转逻辑、reload(url) |
| 核销 | writeOff、状态变更、MQ消息回传 |
| 支付 | pay/order、金额处理、订单状态机 |
| MQ消费 | @RocketMQMessageListener、*Consumer.java、*Listener.java |
| 定时任务 | @Scheduled、@XxlJob、*Task.java、*Job.java |
| 授权 | authorized、token、JWT、interceptor、AuthFilter |
| 邮件/短信 | msg-center-sdk、消息中心、email/sms、SmsSender |
| PDF生成 | OpenPDF、FreeMarker、PdfUtil、iText |
| 文件存储 | AWS S3、OSS、AwsUploadProvider、MinIO |
| 加密 | RSA、SM2、SM4、AES、encry/*.java、EncryptUtil |
| 分布式锁 | RedisLock、DistributedLock、RedissonLock |
| 限流 | RateLimiter、@RateLimiter、Sentinel |
| 多语言 | i18n、language、locale、MessageSource |
| 3DS验证 | 3DS、threeDS、challenge、Cardinal |
| 飞书通知 | webhook、feishu、lark、FeiShuUtil |
| XSS防护 | XssFilter、HtmlUtils、Jsoup |
| 日志脱敏 | Sensitive、desensitize、LogPattern |
| JWT认证 | JWT、JwtUtil、TokenProvider |

---

## 四、部署信息扫描模式

### 4.1 .gitlab-ci.yml
```yaml
# 关注点
variables:          # 环境变量、JVM参数
script:             # 构建/部署命令
artifacts:          # 构建产物
environment:        # 部署环境
```

### 4.2 Dockerfile
```dockerfile
# 关注点
FROM                # 基础镜像
ENTRYPOINT          # 启动命令（含JVM参数）
ENV                 # 环境变量
EXPOSE              # 端口
```

### 4.3 K8s YAML
```yaml
# 关注点
resources.limits    # CPU/内存限制
resources.requests  # CPU/内存请求
replicas            # 副本数
env                 # 环境变量
livenessProbe       # 存活探针
readinessProbe      # 就绪探针
```

### 4.4 启动脚本
```bash
# 关注点
java -jar           # JVM参数：-Xms、-Xmx、-XX:*
--spring.profiles.active  # 激活的环境
```

---

## 五、项目特定模式参考

以下为已分析项目的特定配置模式，供识别类似项目时参考。

### 5.1 hsbank（徽商银行）
**Parent:** saas-parent-website | **配置读取:** LocalGlobal.getConfig()
```properties
# 行方特有
aesKey=
appid=
api.base.url=
api.path.getToken=
cafile=
store_password=
alias_key=
key_alias=
key_password=
alias_paygate=

# 商品编码映射
dp.pro.code.domesticAirport=
dp.pro.code.internationalAirport=
dp.pro.code.domesticTrain=
dp.pro.code.limousine=
dp.pro.code.drivingService=
dp.pro.code.medicalGuide=
dp.pro.code.householdService=
bank.product.type.*=

# 证书路径
hsbank.conf.path=
hsbank.pem.path=
hsbank.cer.path=

# 公私钥
business.public.key=
business.private.key=
my.public.key=
my.private.key=
```

### 5.2 cpicgiftbag（太保礼宾车）
**Parent:** saas-parent | **配置读取:** LocalGlobal.getConfig()
- 特性: 免登、核销、MQ消费(3个)、定时任务
- 加密: RSA+AES 双重加密

### 5.3 ebridge（新加坡eBridge）
**Parent:** ka-common | **配置读取:** @Value
- 特性: 免登、核销、支付、MQ、定时任务、邮件、PDF、AWS S3
- 密钥管理: AWS KMS
- 特点: 国际化、飞书通知

### 5.4 japan-smcc（日本SMCC）
**Parent:** saas-parent-website | **配置读取:** @Value + @ConfigurationProperties
- 特性: 免登、支付(3DS)、MQ、定时任务、邮件、XSS防护
- 密钥管理: AWS KMS
- 特点: JWT认证、防腐层、日志脱敏

### 5.5 quanzhou（泉州银行）
**Parent:** ka-common | **配置读取:** @Value
- 特性: 免登、SM2+SM4加密、限流
- 特点: 极简架构、国密算法

### 5.6 alipay-voyager（Alipay+ Voyager）
**Parent:** ka-common | **配置读取:** @Value
- 特性: 多平台免登、JWT、支付、MQ、核销、PDF、汇率缓存
- 密钥管理: Nacos 占位符
- 特点: 多平台支持、策略模式、本地缓存
