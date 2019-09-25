# docker-compose安装harbor
更改主机名配置地址解析
```
vim /etc/hosts
```
下载离线安装包
```
wget https://storage.googleapis.com/harbor-releases/release-1.9.0/harbor-offline-installer-v1.9.0.tgz
```
安装docker以及必备插件
```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce
systemctl restart docker
```
创建加速文件
```
mkdir -p /etc/docker

tee /etc/docker/daemon.json <<-'EOF'
{
   "registry-mirrors": ["https://j6o4qczl.mirror.aliyuncs.com"]
}
EOF
```
重新启动docker
```
systemctl daemon-reload && systemctl restart docker && systemctl enable docker
```
下载安装docker-compose
```
curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```
为docker-compose添加可执行权限
```
chmod +x /usr/local/bin/docker-compose
```
验证查看docker-compose版本
```
docker-compose -version
```
解压已经下载好的harbor压缩包
```
tar -xf harbor-offline-installer-v1.9.0.tgz
```
配置harbor
```
cd harbor
vim harbor.yml
# 修改下面参数
# hostname = harbor.xxx.com  #填写你的域名
# harbor_admin_password = 123456 #修改密码
```
安装harbor
```
./prepare
./install.sh
```
[安装完成](https://i.loli.net/2019/09/25/JRx9taMHeBrpPcw.png) \
浏览器登录刚才的域名即可看到登录界面
## 问题说明：
当你登录harbor的时候会提示如下：
![微信截图_20190925110543.png](https://i.loli.net/2019/09/25/InkvDluhKJfMpHT.png)
因为harbor默认使用的是https而我们这是是http，所以要更改下面：
```
vim /lib/systemd/system/docker.service
systemctl daemon-reload && systemctl restart docker
```
![微信截图_20190925111559.png](https://i.loli.net/2019/09/25/a5MvLTEKFnPfASk.png)
更改/etc/docker/daemon.json文件
```
vim /etc/docker/daemon.json
# 添加如下
{ "insecure-registries":["harbor.csii.net"] }
```
![微信截图_20190925111940.png](https://i.loli.net/2019/09/25/F7oVYkmfbjAnezl.png)
因为重启docker的时候harbor相关容器都停止了，所以要重启docker-compose
```
cd /harbor
docker-compose down -v
docker-compose up -d 
```
接下来在hosts里面添加上解析
```
vim /etc/hosts
# 添加如下内容
192.168.100.168 harbor.csii.net
```