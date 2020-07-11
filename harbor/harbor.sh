#!/bin/bash
echo -e "\033[42;37m 关闭防火墙 \033[0m"
systemctl stop firewalld
systemctl disable firewalld
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 临时关闭selinux \033[0m"
setenforce 0
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 永久关闭selinux \033[0m"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 建立元数据缓存 \033[0m"
yum makecache
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 定义主机名 \033[0m"
hostnamectl set-hostname harbor
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 获取本机IP \033[0m"
echo -n "请输入harbor服务器IP地址(本机IP地址):"
read ip
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 把IP输出到hosts文件 \033[0m"
echo ${ip} harbor >> /etc/hosts
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 添加docker源 \033[0m"
curl -o /etc/yum.repos.d/Docker-ce-Ali.repo  https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 查看docker版本列表 \033[0m"
yum list docker-ce --showduplicates | sort -r
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 安装指定版本 \033[0m"
# 安装指定版本(可以根据实际情况选择,一般来说没太大影响)
yum -y install --setopt=obsoletes=0 docker-ce-19.03.1-3.el7
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 重启Docker \033[0m"
systemctl daemon-reload
sleep 10
systemctl restart docker
sleep 8
systemctl enable docker
sleep 8
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 查看docker版本 \033[0m"
docker version
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 安装docker-compose \033[0m"
curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m docker-compose添加可执行权限 \033[0m"
chmod +x /usr/local/bin/docker-compose
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 验证查看docker-compose版本 \033[0m"
docker-compose -version
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 用户自定义输入harbor域名 \033[0m"
echo -n '请输入harbor域名(也就是在浏览器中访问harbor的dashboard的域名,如:harbor.lhws.com):'
read domain
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -n '请输入密码(登陆harbor的dashboard的密码):'
read passwd
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 解压已经下载好的离线包 \033[0m"
# harbor下载地址(请下载离线包)
# https://github.com/goharbor/harbor/releases
# 我这里已经准备好了harbor的离线安装包
tar -zxvf harbor-offline-installer-v1.7.0.tgz && cd harbor
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 更改域名 \033[0m"
sed -i "8ihostname = ${domain}" harbor.cfg
sed -i '9d' harbor.cfg
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 更改密码 \033[0m"
sed -i "69iharbor_admin_password = ${passwd}" harbor.cfg
sed -i '70d' harbor.cfg
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 配置harbor \033[0m"
./prepare
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 安装harbor \033[0m"
./install.sh
echo -e '\033[32m ********************************************************************************** \033[0m'


echo -e "\033[42;37m 修改配置文件docker.service \033[0m"
# docker login 客户端/服务端都要操作
# 配置文件默认第14行保持不动
#sed -i "14iExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock" /lib/systemd/system/docker.service
# 只添加第15行
sed -i "15i--insecure-registry=${domain}" /lib/systemd/system/docker.service
## 错误示范
##sed -i "14iExecStart=/usr/bin/dockerd -H unix:// --insecure-registry=${domain}" /lib/systemd/system/docker.service
##sed -i '15d' /lib/systemd/system/docker.service
##echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 重启docker \033[0m"
systemctl daemon-reload
sleep 8
systemctl restart docker
sleep 15
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 修改配置文件daemon.json \033[0m"
# docker login 客户端/服务端都要操作
cat << EOF >> /etc/docker/daemon.json
{ "insecure-registries":["${domain}"] }
EOF
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 重启docker \033[0m"
systemctl daemon-reload
sleep 8
systemctl restart docker
sleep 8
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 重启docker-compose \033[0m"
# 重启docker-compose服务端操作
docker-compose down -v
sleep 40
docker-compose up -d
sleep 40
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 配置hosts信息 \033[0m"
echo ${ip} ${domain} >> /etc/hosts
echo -e '\033[32m ********************************************************************************** \033[0m'
exit
