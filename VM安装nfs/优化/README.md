# nfs优化
- 安装nfs客户端，详情见[安装nfs](https://github.com/happinesslijian/VM/tree/master/VM%E5%AE%89%E8%A3%85nfs/%E5%AE%89%E8%A3%85)
- 执行以下命令,修改同时发起的nfs请求数量
```
echo "options sunrpc tcp_slot_table_entries=128" >> /etc/modprobe.d/sunrpc.conf
echo "options sunrpc tcp_max_slot_table_entries=128" >>  /etc/modprobe.d/sunrpc.conf
```
- 重新启动nfs服务器
```
reboot
```
- 验证
  - 返回值为128说明修改成功
```
cat /proc/sys/sunrpc/tcp_slot_table_entries
```