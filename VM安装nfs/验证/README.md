# 验证
客户端192.168.100.159操作
- 关闭防火墙
```
systemctl stop firewalld
systemctl disable firewalld
```
- 安装nfs
```
yum -y install nfs-utils rpcbind
```
先启动rpcbind 再启动nfs
```
systemctl start rpcbind 
systemctl enable rpcbind 
systemctl start nfs    
systemctl enable nfs
```
检查是否有共享目录
```
showmount -e 192.168.100.158
```
随意创建一个目录
```
mkdir -p /data/test
```
挂载目录
```
mount -t nfs 192.168.100.158:/data/k8s /data/test
```
创建文件进行验证
```
touch /data/test/test.txt
```
nfs服务端查看
```
ll /data/k8s/
```
