# VM安装consul
- 下载consul并解压
```
wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_*
cp consul /usr/local/bin/
consul -v
```
- 启动consul `server操作`
  - -server: 指定节点为server
  - -bootstrap-expect: 设定一个数据中心需要的服务节点数
  - -data-dir: 指定agent储存状态的数据目录
  - -node： 节点名称,默认主机名
  - -bind: 绑定通讯地址
  - -client： 客户端模式
  - -ui： 启动ui
```
mkdir -p /var/log/consul
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consulserver -node=master -bind=192.168.100.164 -client 0.0.0.0 -ui >> /var/log/consul/consul.log 2>&1 &
```
- 查看集群成员
```
consul members
```
- web页面查看dashboard
![示例](https://i.loli.net/2019/10/31/PmA1xvGLzNrUwfY.png)
- **使用-config-dir=/etc/consul.d指定了从哪个配置文件启动**
```
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consulmaster -bind=192.168.100.158 -config-dir=/etc/consul.d -client 0.0.0.0 -ui &
```
- 进入consul-node节点启动consul   `client操作`
```
wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_*
cp consul /usr/local/bin/
consul -v
#启动consul
nohup consul agent -data-dir /tmp/consulclient -node=client-1 -bind=192.168.100.165 >> /var/log/consul/consul.log 2>&1 &
#加入集群
consul join 192.168.100.164
```
# prometheus基于consul的自动发现

