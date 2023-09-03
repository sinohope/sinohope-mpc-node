# Sinohope MPC Node 

**Sinohope: All-in-one Platform for Digital Assets Custody.**

This project is part of the Sinohope WaaS service. For more information, please refer to [sinohope.com](https://www.sinohope.com/) and [docs.sinohope.com](https://docs.sinohope.com/).

This project contains the scripts and configuration files needed to run the Sinohope MPC Node, located in `env/production`. 

Please make sure `node.sh` and `config.toml` are in the same directory. You can run it directly if you do not need to configure the callback service.

MPC Node currently supports the following platforms:

+ macOS/amd64
+ macOS/arm64  
+ Linux/amd64
+ Linux/arm64


## ❗️❗️IMPORTANT❗️❗️: On Database Backup

The local database file of the MPC Node (filename `asset.db`, stored by default in the deployment directory of the MPC Node) stores important data such as your MPC key share, with all data stored encrypted using a strong key derived from the password you set for the MPC Node via the KDF function. 

The MPC key shares are critical to the security and availability of all your digital assets. The MPC key shares managed by Sinohope are stored and backed up by the platform through a series of highly available and disaster recovery solutions across multiple layers and regions, and you can also apply for backups of all 3 MPC key shares for your organization, thus fully controlling all 3 MPC key shares.

**You must complete secure redundant backups of the MPC key share in your local database file yourself.** Please take adequate security measures, geographically distributed multi-copy backups of your database file, and the password you set for the MPC Node.

**It is recommended to keep the database file and password separately to reduce the risk of data leakage.**

**If your MPC Node server or service fails, or data is damaged, or unavailable, etc. in the future, you can only redeploy the MPC Node service by restoring from your backed up database file and password to recover. Sinohope will be unable to help you restore your MPC Node service!**

## Instructions

The `node.sh` script currently supports the following commands and functions:

- `init`: Initialize the MPC Node, use when first deploying;
- `info`: Query information of an initialized MPC Node, including: node id, public key for callback service;
- `reset`: Reset user password; 
- `start`: Start the MPC Node;
- `stop`: Stop and remove the running MPC Node docker container;

**Command Examples:**

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

  **Explanation**: First, the script will automatically do some environmental checks, such as determining if Docker is installed, checking the user's root permissions, etc. The main tasks of the init command are to initialize account information, including:

   - Set a password for the MPC node. This password is used to protect your MPC key share and other private data. **Please keep it properly and do not leak it, and make secure redundant backups.** The node will require entering this password when starting up.

   - Create a node id. Each MPC Node has a unique id that you will need to use to uniquely associate your MPC node with your WaaS account.

   - Create an ECDSA key pair for communicating with the callback server.

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
     "data":"in-bkey success",
     "status":"ok"
   }
   ```


5. stop

   ```
   ./node.sh stop
   ```

## Running Multiple MPC Node Instances  

The `node.sh` script by default starts an MPC Node instance named `npc-node`. Through the 2nd parameter, it supports running multiple MPC Nodes.

Example: 

### init

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

### start

```
./node.sh start mpc-node-test 
checking update...
mpc-node instance name: mpc-node-test, unseal server address: 127.0.0.1:10081
4c90d02b5378651bda82c685d0bd5bcea8518ff5faad88debec5cbd599c23598
waiting mpc-node to start...
mpc-node-test started
? Enter current password:  
```

```
{
  "data":"in-bkey success",    
  "status":"ok"
}
```

### stop

```
./node.sh stop mpc-node-test
```

## Callback service


You can configure a callback service for the MPC Node to implement business risk control for the MPC Node. For details, please refer to [MPC Node Callback Mechanism](https://docs.sinohope.com/docs/develop/mpc-waas-api/quick-start/qs-2-node#4-mpc-node%E5%9B%9E%E8%B0%83%E6%9C%BA%E5%88%B6).