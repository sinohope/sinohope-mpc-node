# Sinohope MPC Node 

**Sinohope: All-in-one Platform for Digital Assets Custody.**

This project is part of the Sinohope WaaS service. For more information, please refer to [sinohope.com](https://www.sinohope.com/) and [docs.sinohope.com](https://docs.sinohope.com/).

This project contains the scripts and configuration files needed to run the Sinohope MPC Node. The programs located under `env/general` are used in the normal CPU environment, and the programs located under `env/intel-sgx` are used in the Intel sgx CPU environment.

Please make sure `node.sh` and `config.toml` are in the same directory. You can run it directly if you do not need to configure the callback service.

MPC Node currently supports the following platforms:

+ macOS/amd64
+ macOS/arm64  
+ Linux/amd64
+ Linux/arm64
+ Ubuntu 20.04/intel SGX

## Program Description

- The node.sh script is used to control the behavior of the mpc-node service, such as generating shard private keys, starting services, etc.

```Bash
sinohope-mpc-node
├── config.toml （Configuration File）
└── node.sh （Manage Scripts）
```

- After successful initialization of MPC Node, the asset.db file and logs directory will be automatically created.

```Bash
sinohope-mpc-node
├── config.toml
├── node.sh
├── asset.db (Important locally generated data is stored here, and backup and recovery are the process of restoring data)
└── logs (Log file directory)
```

## ❗️❗️ important:❗️❗️  database backup

The MPC Node local database file  `asset.db`  stores important data such as your private key sharding, all encrypted using a strong key derived from the password you set for MPC Node via the KDF function.

Private key sharding is related to the security and availability of funds. The private key sharding managed by Sinohope is safeguarded and backed up by a series of highly available and disaster recovery solutions based on multi-level and multi-region platforms. At the same time, you can also apply for backup of all sharding private keys of your organization, thus fully controlling all three sharding private keys.


**And for the private key sharding that exists in your local database file, you must complete the Safety Redundancy backup by yourself. Please take sufficient security measures, remote multiple copies, backup your database file, and the password you set for MPC Node.**

**It is recommended that database files be kept separate from passwords to reduce the risk of data leakage.**

**If your MPC Node server or service fails, data is damaged, or becomes unavailable in the future, you can only restore it by redeploying the MPC Node service with the database, files, and passwords you backed up. Sinohope will not be able to help you restore your MPC Node service!!**


## Instructions

The `node.sh` script currently supports the following commands and functions:
- `start`:     start mpc node service in the background. this should be executed before other commands.
- `unseal`:    enter password to unlock mpc-node, unseal needs to be executed after start.
- `init`:      initialize mpc node service base data.
- `info`:      show mpc node info, include node id and callback-server public key, etc.
- `reset`:     start the reset password task and enter the old password into the cache.
- `cmreset`:   enter new password and complete the reset password task.
- `stop`:      stop mpc node.
- `help`:      show command help.


The `node.sh` script by default starts an MPC Node instance named `npc-node`. Through the 2nd parameter, it supports running multiple MPC Nodes. For example: `./node.sh start mpc-node-test`

## Fully Description

For complete instructions please refer to [MPC Node User Guide](https://docs.sinohope.com/docs/develop/mpc-waas-api/quick-start/qs-2-node/)