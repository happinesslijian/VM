# 此项目都在VM里部署
|应用名称|作用|端口|服务|部署环境|
|:--:|:--:|:--:|:--:|:--:|
|[KVM-webvirtmgr](https://github.com/happinesslijian/VM/tree/master/KVM-webvirtmgr)|图形化管理KVM|80/6080/8000|nginx/supervisord|CentOS Linux release 7.6.1810|
|[openldap](https://github.com/happinesslijian/VM/tree/master/openldap)|统一认证用户|389/80|slapd/httpd|CentOS Linux release 7.6.1810|
|[nfs](https://github.com/happinesslijian/VM/tree/master/VM%E5%AE%89%E8%A3%85nfs)|持久化存储|2049|rpcbind/nfs|CentOS Linux release 7.6.1810|
|[harbor](https://github.com/happinesslijian/VM/tree/master/harbor)|镜像仓库|80|docker-proxy|CentOS Linux release 7.6.1810|
|[gitlab](https://github.com/happinesslijian/VM/tree/master/gitlab)|代码托管仓库|80/8080|gitlab-ctl|CentOS Linux release 7.6.1810|
|[redis](https://github.com/happinesslijian/VM/tree/master/redis)|缓存中间件|6379|redisd|CentOS Linux release 7.6.1810|
