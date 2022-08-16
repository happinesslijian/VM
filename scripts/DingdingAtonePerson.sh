#!/bin/bash
read -r -p "输入使用人： " User
read -r -p "输入资产编码： " Assetcode
Linkingnic=`nmcli con show --active | egrep -v 'docker|br-|lo|veth' | tail -n1 | awk '{print $6}'`
Mac=`ifconfig $Linkingnic | awk 'NR==4{print $2}'`
echo -e 使用人是:$User 资产编码是:$Assetcode Mac地址是:$Mac

curl 'https://oapi.dingtalk.com/robot/send?access_token=b9574a51821f6f1a2ad1pls689522b8edcvfa5b308730a61627d5580bfXXXXXX' \
	-H 'Content-Type: application/json' \
	-d "{\"msgtype\": \"text\", 
	     \"text\": {\"content\": \"使用人是:$User 资产编码是:$Assetcode Mac地址是:$Mac\"},
	     \"at\": {\"atMobiles\": [\"151XXXXXXXX\"]}}"
