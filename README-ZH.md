# Sinohope MPC Node

**Sinohope: All-in-one Platform for Digital Assets Custody.**

本项目是 Sinohope WaaS 服务的一部分，更多信息，请参阅 [sinohope.com](https://www.sinohope.com/) 及 [docs.sinohope.com](https://docs.sinohope.com/)。

本项目包含了运行Sinohope MPC Node所需要的脚本和配置文件。位于`env/general`下的程序在普通cpu环境使用，位于`env/intel-sgx`下的程序在intel sgx cpu环境使用。

请确保`node.sh`和`config.toml`在同一目录下，如果不需要配置回调服务则可以直接运行。

MPC Node 目前支持的平台：

+ macOS/amd64
+ macOS/arm64
+ Linux/amd64
+ Linux/arm64
+ Ubuntu 20.04/intel SGX

## 程序说明

- node.sh脚本用于控制mpc-node服务的行为，如生成分片私钥，启动服务等。

```Bash
sinohope-mpc-node
├── config.toml （配置文件）
└── node.sh （管理脚本）
```
- MPC Node初始化成功后，会自动创建asset.db文件和logs目录：

```JSON
sinohope-mpc-node
├── config.toml
├── node.sh
├── asset.db (本地产生的重要数据都存储在这里，备份与恢复就是恢复数据)
└── logs (日志文件目录)
```

## ❗️❗️重要：数据库备份❗️❗️

MPC Node 本地数据库文件 `asset.db` 存储了您的私钥分片 等重要数据，所有数据均使用强密钥加密存储，该强密钥由您为 MPC Node 设置的密码经 KDF 函数派生而来。

私钥分片事关资金安全及可用，Sinohope所掌管的私钥分片由平台基于多层级多区域的一系列高可用及灾备方案加以保管及备份，同时您也可申请对您的组织的所有分片私钥进行备份，从而完全掌控您的所有3片分片私钥。


而**对于您本地的数据库文件中存在的私钥分片，则必须由您自己完成安全冗余备份。请采取足够的安全措施、异地多副本 备份您的数据库文件，以及您为MPC Node设置的 密码**。

**建议数据库文件与密码分开保管，降低数据泄漏风险**。

**后续若您的 MPC Node 服务器或服务发生故障、数据受损、不可用等情况时，只能通过您备份的 数据库 文件及密码 重新部署MPC Node服务来进行恢复。Sinohope 将无法帮您恢复您的MPC Node 服务！！**


## 使用说明

`node.sh`脚本目前支持的命令及作用：
- `start`：在后台启动 mpc-node服务，需要在其他命令之前执行。
- `unseal`：输入密码解锁mpc-node，执行start后需要执行unseal。
- `init`：初始化mpc-node服务基础数据。
- `info`: 显示mpc-node信息，包括node-id和回调服务器公钥等。
- `reset`：启动重置密码任务并将旧密码输入到缓存中。
- `cmreset`：输入新密码并完成重置密码任务。
- `stop`：停止mpc-node。
- `help`：显示命令帮助。

`node.sh`脚本默认启动的MPC Node实例名称为npc-node，通过第2个参数，支持运行多个MPC Node。 如：`./node.sh start mpc-node-test`


## 完整说明

完整说明请参考[MPC Node 使用指南](https://docs.sinohope.com/zh-Hant/docs/develop/mpc-waas-api/quick-start/qs-2-node/)