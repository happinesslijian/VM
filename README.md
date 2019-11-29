# 此项目都在VM里部署
|应用名称|作用|端口|服务|部署环境|
|:--:|:--:|:--:|:--:|:--:|
|[KVM-webvirtmgr](https://github.com/happinesslijian/VM/tree/master/KVM-webvirtmgr)|图形化管理KVM|80/6080/8000|nginx/supervisord|CentOS Linux release 7.6.1810|
|[openldap](https://github.com/happinesslijian/VM/tree/master/openldap)|统一认证用户|389/80|slapd/httpd|CentOS Linux release 7.6.1810|
|[nfs](https://github.com/happinesslijian/VM/tree/master/VM%E5%AE%89%E8%A3%85nfs)|持久化存储|2049|rpcbind/nfs|CentOS Linux release 7.6.1810|
|[harbor](https://github.com/happinesslijian/VM/tree/master/harbor)|镜像仓库|80|docker-proxy|CentOS Linux release 7.6.1810|
|[gitlab](https://github.com/happinesslijian/VM/tree/master/gitlab)|代码托管仓库|80/8080|gitlab-ctl|CentOS Linux release 7.6.1810|
|[redis](https://github.com/happinesslijian/VM/tree/master/redis)|缓存中间件|6379|redisd|CentOS Linux release 7.6.1810|
|[grafana](https://github.com/happinesslijian/VM/tree/master/grafana)|图形化展示|3000|grafana-server|CentOS Linux release 7.6.1810|
|[consul](https://github.com/happinesslijian/VM/tree/master/consul)|服务注册|8300/8500|consul|CentOS Linux release 7.6.1810|
|[mysql/mysqld_exporter](https://github.com/happinesslijian/VM/tree/master/%E5%AE%89%E8%A3%85mysql%E5%B9%B6%E4%BD%BF%E7%94%A8prometheus%E7%9B%91%E6%8E%A7)|监控mysql|3306/9104|mysqld/mysqld_exporter|CentOS Linux release 7.6.1810|
|[redis/redis_exporter](https://github.com/happinesslijian/VM/tree/master/%E5%AE%89%E8%A3%85redis%E5%B9%B6%E4%BD%BF%E7%94%A8prometheus%E7%9B%91%E6%8E%A7)|监控redis|6379/9121|redisd/redis_exporter|CentOS Linux release 7.6.1810|
|[tomcat/jmx_exporter](https://github.com/happinesslijian/VM/tree/master/%E5%AE%89%E8%A3%85tomcat%E5%B9%B6%E4%BD%BF%E7%94%A8prometheus%E7%9B%91%E6%8E%A7)|监控tomcat|8080/38081||CentOS Linux release 7.6.1810|
|[nginx/nginx_vts_exporter](https://github.com/happinesslijian/VM/tree/master/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85nginx%E5%B9%B6%E4%BD%BF%E7%94%A8prometheus%E7%9B%91%E6%8E%A7nginx)|监控nginx|80/9913|nginx/nginx_vts_exporter|CentOS Linux release 7.6.1810|
