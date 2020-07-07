# 安装docker(在线安装)
- centos

关闭防火墙
```
systemctl stop firewalld
systemctl disable firewalld
```
查看已经存在的docker
```
rpm -qa | grep docker
```
卸载docker
```
yum remove docker-*
```
使用curl升级到最新版
```
curl -fsSL https://get.docker.com/ | sh
```
重启Docker
```
systemctl restart docker
```
开机自启动
```
systemctl enable docker
```
开机自启动
```
docker version
```
# 安装docker(在线安装)
- ubuntu

使用curl升级到最新版
```
curl -fsSL https://get.docker.com/ | sh
```
重启Docker
```
systemctl restart docker
```
开机自启动
```
systemctl enable docker
```
开机自启动
```
docker version
```
# 安装docker(离线安装)
```
# centos
https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
# ubuntu
https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/
```
- cenots
```
mkdir docker_install
cd docker_install
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-19.03.11-3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-19.03.11-3.el7.x86_64.rpm
rpm -ivh *.rpm
```
- ubuntu
```
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-19.03.11-3.el7.x86_64.rpm
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce-cli_19.03.11~3-0~ubuntu-xenial_amd64.deb
dpkg -i *.deb
```