#!/bin/bash
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

echo -e "\033[42;37m 用户自定义输入harbor域名 \033[0m"
echo -n '请输入harbor域名(就是刚才安装harbor时输入的域名,如:harbor.lhws.com):'
read domain
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 请输入harbor的密码 \033[0m"
echo -n '请输入harbor的密码(就是刚才安装harbor时输入的密码):'
read passwd
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 获取harbor服务器IP地址 \033[0m"
echo -n "请输入harbor服务器IP地址(就是刚才安装harbor机器的IP地址):"
read ip
echo -e '\033[32m ********************************************************************************** \033[0m'

#echo -e "\033[42;37m 修改配置文件docker.service \033[0m"
# docker login 客户端/服务端都要操作
# 配置文件默认第14行保持不动
#sed -i "14iExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock" /lib/systemd/system/docker.service
# 只添加第15行
#sed -i "15i--insecure-registry=${domain}" /lib/systemd/system/docker.service
## 错误示范
##sed -i "14iExecStart=/usr/bin/dockerd -H unix:// --insecure-registry=${domain}" /lib/systemd/system/docker.service
##sed -i '15d' /lib/systemd/system/docker.service
##echo -e '\033[32m ********************************************************************************** \033[0m'
#echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 重启docker \033[0m"
systemctl daemon-reload
sleep 10
systemctl restart docker
sleep 15
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 修改配置文件daemon.json \033[0m"

# docker login 客户端/服务端都要操作
# 仅适用于docker环境,也就是daemon.json文件是空的情况下
cat << EOF >> /etc/docker/daemon.json
{ "insecure-registries":["${domain}"] }
EOF

echo -e "\033[42;37m 重启docker \033[0m"
systemctl daemon-reload
sleep 10
systemctl restart docker
sleep 15
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 配置hosts信息 \033[0m"
echo ${ip} ${domain} >> /etc/hosts
echo -e '\033[32m ********************************************************************************** \033[0m'

echo -e "\033[42;37m 登陆harbor \033[0m"
docker login ${domain} -u admin -p ${passwd}
echo -e '\033[32m ********************************************************************************** \033[0m'
exit
