#!/bin/bash
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

echo -e "\033[42;37m 更改daemon.json文件 \033[0m"
#说明 下面10.244.64.0/18要根据实际情况去换仅适用于k8s集群,因为k8s集群已经成型,daemon.json文件已经生成内容
sed -i 's#10.244.64.0/18"#&,"'${domain}'"#g' /etc/docker/daemon.json
echo -e '\033[32m ********************************************************************************** \033[0m'

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
