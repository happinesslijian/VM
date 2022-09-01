#!/bin/bash
#这里取到的IP不准  后续优化
UUID=`nvidia-smi -q | grep -i 'gpu uuid' | awk '{print $4}' | awk -F 'GPU-' '{print $2}'`
NIC=`nmcli con show --active | egrep -v 'docker|br-|lo|veth' | tail -n1 | awk '{print $6}'`
IP=`ifconfig $NIC | awk 'NR==2{print $2}'`

echo -e IP地址是：$IP UUID是：$UUID
curl 'https://oapi.dingtalk.com/robot/send?access_token=317887bg611541530b8c4335616b323b298728c81898734861af24d7d9a28027' \
		-H 'Content-Type: application/json' \
		-d "{\"msgtype\": \"text\",
	     	     \"text\": {\"content\": \"IP地址是：$IP UUID是：\r$UUID\r\"},
		     \"at\": {\"atMobiles\":[15110264730]}}"
