# Sinohope MPC Node

本项目包含了运行Sinohope MPC Node所需要的脚本和配置文件，位于`env/production`。

请确保`node.sh`和`config.toml`在同一目录下，如果不需要配置回调服务则可以直接运行。

MPC Node 目前支持的平台：

+ macOS/amd64
+ macOS/arm64
+ Linux/amd64
+ Linux/arm64

### 使用说明

`node.sh`脚本目前支持的命令及作用：

+ init: 初始化MPC Node，首次部署时使用；
+ info: 查询已经初始化过的MPC Node信息，包括：node id、回调服务通信公钥；
+ reset: 重置用户密码；
+ start: 启动MPC Node；
+ stop: 停止并移除正在运行的MPC Node docker实例；

**命令示例：**

1. init

   ```
   ./node.sh init
   ```

   ```
   ./node.sh init
   checking update...
   mpc-node instance name: mpc-node, unseal server address: 127.0.0.1:10080
   af026c805a03aa7bd1915ba944dbb710019e6a5cdb543311c31a29db03c4be95
   waiting mpc-node to start...
   mpc-node started
   New password:
   Retype new password:
   {"data":{"node_id":"sinoMzA1OTMwMTMwNjA3MmE4NjQ4Y2UzZDAyMDEwNjA4MmE4NjQ4Y2UzZDAzMDEwNzAzNDIwMDA0MmFmNGY0Y2I5ZmM1MGFjMWUzNzIxMzM2Y2IyMmJmYzMzMDg4YjJmNGM4OTEyZjZhNDE4ZmNlY2JmZWFhMzIwMjNlMzg0MGE1YjBkODI3YWE5ODE1N2Y1MTE5Y2M2YTdiYzQ2NWNmN2EzNzc0MTkwNjdmYzc5ZGNjMjQ0YjgxZTU=","public_key":"-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEKvT0y5/FCsHjchM2yyK/wzCIsvTI\nkS9qQY/Oy/6qMgI+OEClsNgnqpgVf1EZzGp7xGXPejd0GQZ/x53MJEuB5Q==\n-----END PUBLIC KEY-----\n"},"status":"ok"}
   ```

   说明：首先脚本会自动做一些环境的检查工作，如判断是否安装了Docker，判断用户的控住权限等。init命令的主要任务是初始化账户信息，包括：说明：首先脚本会自动做一些环境的检查工作，如判断是否安装了Docker，判断用户的控住权限等。init命令的主要任务是初始化账户信息，包括：

   - 给 MPC 节点设置一个密码，这个密码用于保护您的私钥分片 及其他私密数据，**请您妥善保管，切勿泄漏，并且做好安全冗余备份**。节点启动时会要求输入该密码。
     - 您可采用如下措施实现密码自动输入：打开config.toml配置文件，[storage]配置项中增加password字段：
     - ```Shell
       [storage]
       db-file-path = "/tmp/mpc-node/asset.db"
       unseal-server-address = "0.0.0.0:8080"
       ```
   - 创建node id， 每一个MPC Node都有一个唯一标识id，您将需要使用该 node id 将您的MPC 节点与您的 WaaS 组织账号做唯一关联。
   - 创建与callback-server通信时的ECDSA密钥对。

2. info

   ```
   ./node.sh info   
   checking update...
   ```

   ```
   {
     "data": {
       "node_id": "sinoMzA1OTMwMTMwNjA3MmE4NjQ4Y2UzZDAyMDEwNjA4MmE4NjQ4Y2UzZDAzMDEwNzAzNDIwMDA0MmFmNGY0Y2I5ZmM1MGFjMWUzNzIxMzM2Y2IyMmJmYzMzMDg4YjJmNGM4OTEyZjZhNDE4ZmNlY2JmZWFhMzIwMjNlMzg0MGE1YjBkODI3YWE5ODE1N2Y1MTE5Y2M2YTdiYzQ2NWNmN2EzNzc0MTkwNjdmYzc5ZGNjMjQ0YjgxZTU=",
       "public_key": "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEKvT0y5/FCsHjchM2yyK/wzCIsvTI\nkS9qQY/Oy/6qMgI+OEClsNgnqpgVf1EZzGp7xGXPejd0GQZ/x53MJEuB5Q==\n-----END PUBLIC KEY-----\n",
       "state": "unsealed"
     },
     "status": "ok"
   }
   ```

   

3. reset

   ```
   ./node.sh reset
   checking update...
   ? Enter current password: 
   New password:
   Retype new password:
   ```

   ```
   {"status": "ok", "data": "re-bkey success"}
   ```

   

4. start

   ```
   ./node.sh start
   checking update...
   mpc-node instance name: mpc-node, unseal server address: 127.0.0.1:10080
   4c90d02b5378651bda82c685d0bd5bcea8518ff5faad88debec5cbd599c23598
   waiting mpc-node to start...
   mpc-node started
   ? Enter current password: 
   ```

   ```
   {
     "data":"in-bkey success",    // 密码校验成功
     "status":"ok"
   }
   ```

   

5. stop

   ```
   ./node.sh stop
   ```

### 运行多个MPC Node实例

`node.sh`脚本默认启动的MPC Node实例名称为npc-node，通过第2个参数，支持运行多个MPC Node。

示例：

####  init

```
./node.sh init mpc-node-test
```

```
./node.sh init
checking update...
mpc-node instance name: mpc-node, unseal server address: 127.0.0.1:10080
af026c805a03aa7bd1915ba944dbb710019e6a5cdb543311c31a29db03c4be95
waiting mpc-node to start...
mpc-node started
New password:
Retype new password:
{"data":{"node_id":"sinoMzA1OTMwMTMwNjA3MmE4NjQ4Y2UzZDAyMDEwNjA4MmE4NjQ4Y2UzZDAzMDEwNzAzNDIwMDA0MmFmNGY0Y2I5ZmM1MGFjMWUzNzIxMzM2Y2IyMmJmYzMzMDg4YjJmNGM4OTEyZjZhNDE4ZmNlY2JmZWFhMzIwMjNlMzg0MGE1YjBkODI3YWE5ODE1N2Y1MTE5Y2M2YTdiYzQ2NWNmN2EzNzc0MTkwNjdmYzc5ZGNjMjQ0YjgxZTU=","public_key":"-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEKvT0y5/FCsHjchM2yyK/wzCIsvTI\nkS9qQY/Oy/6qMgI+OEClsNgnqpgVf1EZzGp7xGXPejd0GQZ/x53MJEuB5Q==\n-----END PUBLIC KEY-----\n"},"status":"ok"}
```

#### start

```
./node.sh start
checking update...
mpc-node instance name: mpc-node, unseal server address: 127.0.0.1:10080
4c90d02b5378651bda82c685d0bd5bcea8518ff5faad88debec5cbd599c23598
waiting mpc-node to start...
mpc-node started
? Enter current password: 
```

```
{
  "data":"in-bkey success",    // 密码校验成功
  "status":"ok"
}
```

#### stop

```
./node.sh stop mpc-node-test
```



