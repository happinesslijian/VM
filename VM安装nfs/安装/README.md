# install-nfs
服务端192.168.100.158操作 \
1.安关闭防火墙 \
`systemctl stop firewalld` \
`systemctl disable firewalld` \
2.安装配置nfs \
`yum -y install nfs-utils rpcbind` \
3. 创建共享目录分配权限 \
`mkdir -p /data/k8s/` \
`vi /etc/exports`
> /data/k8s  *(rw,sync,no_root_squash) 

先启动rpcbind
```
systemctl start rpcbind
systemctl enable rpcbind
systemctl status rpcbind
```
再启动nfs
```
systemctl start nfs
systemctl enable nfs
systemctl status nfs
```
通过命令确认
`rpcinfo -p|grep nfs`
