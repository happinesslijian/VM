#!/bin/bash
#关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
#关闭selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
#查看selinux状态
sestatus
#定义函数体
function install_docker() {
	dnf remove -y podman
	export REPO=https://mirrors.aliyun.com/docker-ce
	dnf config-manager --add-repo $REPO/linux/centos/docker-ce.repo
	dnf install --allowerasing -y $REPO/linux/centos/8/x86_64/stable/Packages/containerd.io-1.4.4-3.1.el8.x86_64.rpm docker-ce docker-ce-cli
	docker --version
	systemctl start docker
	systemctl enable docker
	#使用七牛云加速器
	echo -e '{
        "experimental": true,
        "registry-mirrors": ["https://reg-mirror.qiniu.com","https://registry.docker-cn.com", "http://hub-mirror.c.163.com","https://docker.mirrors.ustc.edu.cn"]
}' > /etc/docker/daemon.json
	systemctl daemon-reload
	systemctl restart docker
	#安装docker-compose
	timedatectl set-timezone Asia/Shanghai
	echo -e "server 210.72.145.44 iburst \nserver ntp.aliyun.com iburst" >> /etc/chrony.conf
	systemctl restart chronyd
	chronyc sources -y
	sudo curl -L "https://ghproxy.com/https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	docker-compose -v 
}
#centos8.2默认自带podman所以要卸载掉
dnf list installed podman
if [ $? -eq 0 ]; then
	echo "卸载podman"
	install_docker
elif [ $? -gt 0 ]; then 
	echo "podman不存在"
	install_docker
fi
