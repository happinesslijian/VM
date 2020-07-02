#!/bin/bash
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
yum makecache
yum -y install nfs-utils rpcbind
echo -n "请输入需要共享的目录(绝对路径)(不存在的会自动创建):"
read share_dir
mkdir -p ${share_dir}
# 添加共享目录
cat <<EOF >> /etc/exports
${share_dir} *(rw,sync,no_root_squash)
EOF
# 重启nfs服务
systemctl restart rpcbind
# 设置nfs开机自启动
systemctl start nfs
systemctl enable nfs
#ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|egrep -v '172.17.0|127.0.0'|awk '{print $2}'
echo -n "请输入nfs服务器IP地址:"
read ip
# 开机自动挂载
cat <<EOF >> /etc/fstab
${ip}:${share_dir}       /mnt${share_dir}              nfs     defaults        0 0
EOF
echo "-------------nfs服务已安装完毕-------------"
systemctl status rpcbind
systemctl status nfs
exit
