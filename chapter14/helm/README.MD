# 通过传值的方式来DIY安装redis
helm install db bitnami/redis --set master.persistence.enabled=false --set replica.persistence.enabled=false
# 查看通过helm部署的服务状态
helm status db
# 通过配置文件DIY安装redis
 helm install redis-db1 bitnami/redis -f redis-valuse.yaml

 # redis 简单使用命令
 ## 连接redis
 redis-cli -h redis地址 -a 密码

 ## 输入数据
 SET mykey www.magedu.com

 ## 保存数据
 bgsave

 ## 查看数据
 get mykey

 # 修改默认存储类
 kubectl annotate sc longhorn storageclass.kubernetes.io/is-default-class=true
