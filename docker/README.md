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
### centos8.2离线安装docker
```
# centos8.2自带podman 所以要先卸载掉
yum erase -y podman buildah
# 添加阿里源
REPO=https://mirrors.aliyun.com/docker-ce
dnf config-manager --add-repo $REPO/linux/centos/docker-ce.repo
# 下载必要的安装包
wget -P /root/docker https://mirrors.aliyun.com/docker-ce/linux/centos/8.0/x86_64/stable/Packages/containerd.io-1.4.4-3.1.el8.x86_64.rpm
# 为安装包安装依赖
yum localinstall containerd.io-1.4.4-3.1.el8.x86_64.rpm --downloadonly --downloaddir=/root/docker
yum localinstall container-selinux-2.167.0-1.module_el8.5.0+911+f19012f9.noarch.rpm --downloadonly --downloaddir=/root/docker
# 下载必要的安装包
wget -P /root/docker https://mirrors.aliyun.com/docker-ce/linux/centos/8.0/x86_64/stable/Packages/docker-ce-20.10.9-3.el8.x86_64.rpm
# 为安装包安装依赖
yum localinstall docker-ce-20.10.9-3.el8.x86_64.rpm --downloadonly --downloaddir=/root/docker
# 删除重复的
rm -rf containerd.io-1.4.12-3.1.el8.x86_64.rpm
# 离线安装docker
cd /root/docker
rpm -ivh ./*
```

### centos8.5 离线安装docker
```
# centos8.5自带podman 所以要先卸载掉
yum erase -y podman buildah
# centos8使用yum install docker -y时，默认安装的是podman-docker软件 所以我们这样做：
# 下载docker-ce源
curl https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
yum install docker-ce --downloadonly --downloaddir=./
rpm -ivh ./*
```
