#!/bin/bash
#################################
###By LiJian#####################
###DATE 2017-11-09###############
#################################
cd `dirname "$0"`
###初始化IP地址、NETMASK、网关和主DNS
mobanname="centos7moban"
read -p "Enter your DomainName: " DomainName
read -p "Enter "$DomainName"'s IP (defaults IP is DomainName :" IP 
IP=${IP:-"$DomainName"}
#read -p "Enter "$DomainName"'s HOSTNAME, default HOSTNAME is IP : " HOSTNAME
echo $IP |tr '.' '-' >./hostname
read -p "Enter "$DomainName"'s NETMASK, default is 255.255.255.0  :" NETMASK
NETMASK=${NETMASK:-"255.255.255.0"}
read -p "Enter "$DomainName"'s GATEWAY :" GATEWAY
read -p "Enter "$DomainName"'s DNS1 :" DNS1
read -p "Enter "$DomainName"'s DNS2 :" DNS2
###进行克隆
virt-clone -o $mobanname -n "$DomainName" -f /var/lib/libvirt/images/"$DomainName".qcow2
###将得到的网络配置参数配到ifcfg-eth0里
cat >>ifcfg-eth0<<EOF
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=no
PEERROUTES=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
EOF
echo -e "IPADDR=$IP\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=$DNS1\nDNS2=$DNS2">>./ifcfg-eth0
###将ifcfg-eth0配置文件导入虚机
###如果没有virt-copy-in则参考安装yum install -y libguestfs-tools-c  参考链接：http://pkgs.loginroot.com/errors/notFound/virt-copy-in
/usr/bin/virt-copy-in  -d $DomainName ./ifcfg-eth0 /etc/sysconfig/network-scripts/
/usr/bin/virt-copy-in  -d $DomainName ./hostname /etc/
#/usr/bin/virt-copy-in  -d $DomainName ./zabbix_agentd.conf /etc/zabbix/

##设置开机自启动
echo "The $DomainName Will  set autostart !!!"
virsh autostart "$DomainName"
###开机
echo "The $DomainName will be Starting!!!"
virsh start "$DomainName"
###恢复初始化配置文件，为下次clone做准备
rm -f ./ifcfg-eth0 ./hostname
###判断是否需要做快照
while true
do
echo -n "Whether to create a snapshot for the virtual machine(yes/no):  ";read xx
if [ $xx == yes ]; then
    read -p "Enter snapshot name:  " snapshotname
    virsh snapshot-create-as $DomainName $snapshotname
    exit 0
elif [ $xx == no ]; then
    echo -n "Choose not to take a snapshot  "
    exit 0
else echo -n "Please enter again  "
fi
done