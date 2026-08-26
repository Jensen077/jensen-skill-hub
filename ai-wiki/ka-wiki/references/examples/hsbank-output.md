# business-agent-hsbank-personal-equity-website 运维文档

> 自动生成于 2026-05-04

## 1. 项目概述

- **应用名称**：agent-hsbank-personal-equity-website
- **上下文路径**：/agent/api/hsbankPersonalEquity
- **数据源**：bp_hsbank_personal_equity
- **技术栈**：Spring Boot 2.x + MyBatis + RocketMQ + Redis

---

## 2. 环境配置

### 2.1 环境总览
| 环境 | Profile | 域名 | 备注 |
|------|---------|------|------|
| 生产 | prod | https://h5-quanyi.dragonpass.com.cn/ | - |
| 测试 | test | https://quanyi-h5-test.dragonpass.com.cn/ | - |
| UAT | uat | - | 同测试环境 |
| 开发 | dev | localhost | 本地开发 |

### 2.2 数据库配置
| 环境 | 数据库地址 | 库名 | 备注 |
|------|-----------|------|------|
| 生产 | 从配置提取 | bp_hsbank_personal_equity | - |
| 测试 | 从配置提取 | bp_hsbank_personal_equity | - |

### 2.3 中间件配置
- **消息队列**：RocketMQ
  - 生产：rocketmq0.dp.local:9876;rocketmq1.dp.local:9876
  - 测试：192.168.26.46:9876
- **缓存**：Redis（基于 Redisson）

### 2.4 租户信息
| 环境 | 租户编码 | 租户ID | 备注 |
|------|---------|--------|------|
| 生产 | 1039 | 869 | - |
| 测试 | 0916 | 916 | - |
| UAT | 0291 | - | - |

### 2.5 第三方配置

#### 徽商银行
| 配置项 | 值（脱敏） | 环境 | 备注 |
|--------|-----------|------|------|
| api.base.url | https://pbank.hsbank.cc | 生产 | 行方API地址 |
| api.base.url | https://testbh.hsbank.com.cn:11001 | 测试 | 行方API地址 |
| aesKey | *** | 生产 | AES加密密钥 |
| appid | *** | - | 应用ID |

#### SAAS 平台
| 配置项 | 值（脱敏） | 备注 |
|--------|-----------|------|
| business.public.key | MIIBIjANBgkqhkiG9w0... | SAAS公钥 |
| business.private.key | 未配置 | - |
| my.public.key | MIGfMA0GCSqGSIb3DQE... | 本系统公钥 |
| my.private.key | MIICdgIBADANBgkqhki... | 本系统私钥 |

### 2.6 证书/密钥
| 用途 | 文件 | 环境 | 备注 |
|------|------|------|------|
| 商户证书 | merchant_uat.pem | 测试 | - |
| 商户证书 | merchant_prod.pem | 生产 | - |
| 平台证书 | 10600100_open_20220929.cer | 测试/生产 | 注意有效期 |
| 密钥库 | hsmerchant_mobile_ces.jks | 测试 | - |
| 密钥库 | hsmerchant_mobile_pro.jks | 生产 | - |

### 2.7 商品编码映射
| 商品 | 龙腾编码 | 银行编码 | 类型 |
|------|---------|---------|------|
| 境内机场休息室 | EQ{tenant}003001 | 2001 | SL |
| 境外机场休息室 | EQ{tenant}003003 | 2002 | SL |
| 境内高铁休息室 | EQ{tenant}003002 | 2003 | SL |
| 接送机/礼宾车 | LS{tenant}003001 | 2004 | LS |
| 专家导医导诊 | GC{tenant}003003 | 2006 | GC |
| 居家保洁 | SC{tenant}003001 | 2007 | SC |

---

## 3. 配置清单

### 3.1 代码中引用的配置
| 配置项 | 引用位置 | 说明 |
|--------|---------|------|
| dp.pro.code.* | ProductEnum | 龙腾商品编码 |
| bank.product.type.* | ProductEnum | 银行商品编码 |
| front.url.auth | IndexLogic | 授权页面URL |
| front.url.register | IndexLogic | 注册页面URL |
| hsbank.conf.path | Config | 行方配置路径 |
| hsbank.pem.path | Config | 商户证书路径 |
| hsbank.cer.path | Config | 平台证书路径 |

### 3.2 枚举定义
| 枚举类 | 值 | 说明 |
|--------|-----|------|
| CategoryType | SL, LS, GC, SC | 权益类型 |
| ProductEnum | 6种商品 | 商品枚举 |
| OrderStatusEnum | ORDERED, CANCELLED | 订单状态 |

---

## 4. 业务接口

### 4.1 接口清单
| Controller | 路径前缀 | 方法数 | 主要功能 |
|-----------|---------|--------|---------|
| IndexController | /index | 1 | 免登入口 |
| AuthorizedController | /authorized | 1 | 用户授权 |
| RegisterController | /register | 1 | 用户注册 |
| SMSController | /sms | 1 | 短信验证码 |
| ImageController | /captcha | 1 | 图片验证码 |
| PayController | /saas/pay/check | 1 | 支付处理 |
| ErrorController | /error | 4 | 运维工具 |

### 4.2 核心接口详情

#### 免登入口 - IndexController
- **路径**：GET/POST /index/{type}
- **参数**：type（商品类型）、code（用户code）
- **流程**：
  1. 校验参数
  2. 查询行方用户ID
  3. 查询核心客户号
  4. 检查授权状态
  5. 检查实名状态
  6. 跳转到目标页面

#### 支付处理 - PayController
- **路径**：POST /saas/pay/check/handle
- **参数**：BaseReqInfo（订单信息）
- **流程**：
  1. SAAS 签名验签
  2. 分布式锁防重复
  3. 幂等检查
  4. 查询积分余额
  5. 调用积分扣减
  6. 保存订单

---

## 5. 依赖服务

| 服务 | 类型 | 配置 | 备注 |
|------|------|------|------|
| 徽商银行开放平台 | HTTP | api.base.url | 积分查询/扣减 |
| SAAS 平台 | HTTP | business.domain.url | 订单/会员 |
| RocketMQ | MQ | rocketmq.name-server | 消息队列 |
| Redis | Cache | redis 配置 | 缓存/分布式锁 |

---

## 6. 部署信息

- **构建产物**：business-agent-demo-website.jar
- **Maven 私服**：http://maven.dragonpass.com.cn/repository/
- **本地依赖**：
  - hxshPlt-1.8.jar
  - hsbank-java-sdk-1.3.jar
  - dcits-sm-1.0.5.jar
- **启动命令**：`java -jar business-agent-demo-website.jar --spring.profiles.active=prod`

---

## 7. 运维手册

### 7.1 常见问题

**问题1：积分扣减失败**
- 原因：行方接口超时或 Token 失效
- 解决：检查 api.base.url 配置，Token 会自动重试一次

**问题2：证书过期**
- 原因：商户证书或平台证书有效期到期
- 解决：联系行方更新证书，替换 conf/ 目录下的 pem/cer 文件

**问题3：授权页面跳转失败**
- 原因：front.url.auth 配置错误
- 解决：检查配置，确保域名和路径正确

### 7.2 配置变更

**修改租户：**
```
tenant.code=新租户编码
tenant.id=新租户ID
```

**切换环境：**
```
spring.profiles.active=prod/test/uat/dev
```

**更新证书：**
1. 获取新证书文件
2. 替换 `/conf/{env}/` 下的 pem/cer/jks 文件
3. 重启服务

### 7.3 监控要点

**日志关键字：**
- `免登跳转` - 免登流程
- `积分扣减` - 支付流程
- `授权` - 授权流程
- `ERROR` / `Exception` - 异常

**健康检查：**
- `/error/test` - 健康检查接口

**埋点指标：**
- `metrics.bizGroupCode` - 埋点分组编码

---

## 8. 项目结构

```
src/main/java/cn/com/dragonpass/business/agent/
├── controller/          # 控制器层
│   ├── enums/          # 枚举定义
│   └── logic/          # 业务逻辑
├── hsbank/             # 行方相关
│   └── enums/          # 行方枚举
├── service/            # 服务层
├── db/                 # 数据库层
├── config/             # 配置类
├── metrics/            # 埋点监控
└── util/               # 工具类
```
