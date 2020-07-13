#!/bin/bash
systemctl stop firewalld
systemctl disable firewalld
# 临时关闭selinux
setenforce 0
# 永久关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# 建立元数据缓存
yum makecache
# 安装nfs和rpcbind
yum -y install nfs-utils rpcbind
echo -n "请输入需要共享的目录(绝对路径开始)(不存在的会自动创建):"
read share_dir
mkdir -p ${share_dir}
# 添加共享目录
cat <<EOF >> /etc/exports
${share_dir} *(rw,sync,no_root_squash)
EOF
# 启动rpcbind服务
systemctl start rpcbind
systemctl enable rpcbind
# 启动nfs服务
systemctl start nfs
systemctl enable nfs
#ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|egrep -v '172.17.0|127.0.0'|awk '{print $2}'
echo -n "请输入nfs服务器IP地址(本机地址):"
read ip
# 取根路径为开机自动挂载准备
echo -n "请输入上面创建的目录(只需输入[根路径] 如:上面创建的目录是/data/k8s 这里只需输入/data/即可):"
read data_dir
# 开机自动挂载
cat <<EOF >> /etc/fstab
${ip}:${data_dir}       ${share_dir}             nfs     defaults        0 0
EOF
echo "-------------nfs服务已安装完毕-------------"
# 查看rpcbind服务是否运行
systemctl status rpcbind
# 查看nfs服务是否运行
systemctl status nfs
# 查看是否挂载成功(无任何输出即可)
mount -a
# 查看开机自启动列表
systemctl list-unit-files | egrep 'nfs|rpcbind' | grep enabled
exit
