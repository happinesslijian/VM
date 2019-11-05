# VM安装consul
**说明：我这里都是在VM里面安装的consul包括prometheus-server** \
**参考文档：https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config**
- 下载consul并解压
```
wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_*
cp consul /usr/local/bin/
consul -v
```
#### 启动consul `server操作`
  - -server: 指定节点为server
  - -bootstrap-expect: 设定一个数据中心需要的服务节点数
  - -data-dir: 指定agent储存状态的数据目录
  - -node： 节点名称,默认主机名
  - -bind: 绑定通讯地址
  - -client： 客户端模式
  - -ui： 启动ui
```
mkdir -p /var/log/consul
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consulserver -node=server -bind=127.0.0.1 -client 0.0.0.0 -ui >> /var/log/consul/consul.log 2>&1 &
```
- 查看集群成员
```
consul members
```
- web页面查看dashboard
![示例](https://i.loli.net/2019/10/31/PmA1xvGLzNrUwfY.png)
- **使用-config-dir=/etc/consul.d指定了从哪个配置文件启动**
```
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consulserver -node=server -bind=127.0.0.1 -config-dir=/etc/consul.d -client 0.0.0.0 -ui >> /var/log/consul/consul.log 2>&1 &
```
#### 进入consul-client节点启动consul   `client操作`
```
wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_*
cp consul /usr/local/bin/
consul -v
#启动consul
nohup consul agent -data-dir /tmp/consulclient -node=client-1 -bind=127.0.0.1 >> /var/log/consul/consul.log 2>&1 &
#加入集群
consul join 192.168.100.164
```
# consul自动发现
### **consul服务发现，首先要把服务（被监控项）注册到consul里去,所以要编写如下配置文件,然后指定该目录启动consul,接着刷新浏览器就可以看到被注册到consul的服务了。**
- 配置文件示例1
  - 配置文件写到/etc/consul.d/目录下,方便以后指定目录启动（一个文件对应一个被监控项，做到见名知意）
  - [见名知意](https://i.loli.net/2019/11/01/Oj3EHRpPX9qI56b.png)
  - 如果某一个机器下线了不再需要被监控了从/etc/consul.d/目录下删除该文件即可,然后重新指定目录启动consul即可
```
{
  "service": {
  "id": "Nextcloud on Kubernetes 私有云",
  "name": "consul",
  "address": "192.168.100.158",
  "port": 9115, #blackbox_exporter监控监控网站,使用http协议,端口是9115
  "tags": [
    "prod",
    "prome",
    "node"
  ],
  "checks": [
    {
      "http": "http://192.168.100.158:9115/probe?module=http_2xx&target=https://715fb689.cpolar.cn",
      "interval": "15s"
    }
  ]
}
}
```
- 配置文件示例2
  - 配置文件写到/etc/consul.d/目录下,方便以后指定目录启动（一个文件对应一个被监控项，做到见名知意）
```
{
  "service": {
  "id": "windows办公区台式机",
  "name": "consul",
  "address": "10.2.0.199",
  "port": 9182, #wmi_exporter监控windows操作系统,端口是9182
  "tags": [
    "prod",
    "prome",
    "node"
  ],
  "checks": [
    {
      "http": "http://10.2.0.199:9182/metrics",
      "interval": "15s"
    }
  ]
}
}
```
- 配置文件示例3
  - 配置文件写到/etc/consul.d/目录下,方便以后指定目录启动（一个文件对应一个被监控项，做到见名知意）
```
{
  "service": {
  "id": "master-192-168-100-150",
  "name": "consul",
  "address": "192.168.100.150",
  "port": 9100, #node_exporter监控linux主机,端口是9100
  "tags": [
    "prod",
    "prome",
    "node"
  ],
  "checks": [
    {
      "http": "http://192.168.100.150:9100/metrics",
      "interval": "15s"
    }
  ]
}
}
```
# prometheus基于consul自动发现
- 上面的操作只是把服务注册到consul里了,但是和prometheus还没有任何关系,所以现在要把prometheus和consul关联起来,然后重新启动prometheus服务即可。
刷新浏览器即可看到来自consul的服务都被监控了。
  - 在prometheus的配置文件里添加：
```
  - job_name: 'consul'
    consul_sd_configs:
      - server: 'localhost:8500'
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*,prome,.*
        action: keep
      - source_labels: [__meta_consul_service]
        target_label: job
      - source_labels: [__meta_consul_service_id]
        target_label: group
```
# systemctl管理consul服务

```
cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description=consul
After=syslog.target network.target

[Service]
Type=simple
RemainAfterExit=no
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/consul agent -ui -server -node=server -bootstrap -bind 127.0.0.1 -client 0.0.0.0
  -data-dir /tmp/consulserver -config-dir=/etc/consul.d 
  -log-file /var/log/consul/

[Install]
WantedBy=multi-user.target

EOF
```
systemctl daemon-reload \
systemctl start consul \
systemctl status consul
