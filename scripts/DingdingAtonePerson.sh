#!/bin/bash
UUID=`nvidia-smi -q | grep -i 'gpu uuid' | awk '{print $4}' | awk -F 'GPU-' '{print $2}'`
NIC=`nmcli con show --active | egrep -v 'docker|br-|lo|veth' | tail -n1 | awk '{print $6}'`
IP=`ifconfig $NIC | awk 'NR==2{print $2}'`

echo -e IP地址是：$IP UUID是：$UUID
curl 'https://oapi.dingtalk.com/robot/send?access_token=317778bc611531plkh8f4336506b323a298728c81898734861bf24d7d9axxx26' \
		-H 'Content-Type: application/json' \
		-d "{\"msgtype\": \"text\",
	     	     \"text\": {\"content\": \"IP地址是：$IP UUID是：\r$UUID\r\"},
		     \"at\": {\"atMobiles\":[151xxxxxxxx]}}"

