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


```
#参考如下网站下载新版本docker
https://download.docker.com/linux/static/stable/x86_64/

# 解压
tar xzvf docker-27.1.1.tgz
tar xzvf docker-rootless-extras-27.1.1.tgz

# 将解压后的二进制文件移动到系统的可执行路径中
mv docker/* /usr/local/bin/
mv docker-rootless-extras/* /usr/local/bin/

# 二进制文件不会创建服务文件，需要手动创建一个systemd服务文件来管理docker服务

[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
LimitNPROC=infinity
Restart=on-failure
RestartSec=5
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target

# 重新加载 systemd 配置并启动 Docker 服务
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker

# 检查 Docker 服务的状态
sudo systemctl status docker

# 查看版本
docker --version
```
