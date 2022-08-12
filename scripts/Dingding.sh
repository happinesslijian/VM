#!/bin/bash
read -r -p "输入使用人： " User
read -r -p "输入资产编码： " Assetcode
Linkingnic=`nmcli con show | egrep -v 'docker|br|lo|veth' | tail -n +2 | awk '{print $6}'`
Mac=`ifconfig $Linkingnic | awk 'NR==4{print $2}'`
echo -e 使用人是:$User 资产编码是:$Assetcode Mac地址是:$Mac

curl 'https://oapi.dingtalk.com/robot/send?access_token=d5428ea6160c9fc49ae38b6142a5e9d3cc7774673355a39b22f1ee6c1b633lee1' \
	-H 'Content-Type: application/json' \
	-d "{\"msgtype\": \"text\", 
	     \"text\": {\"content\": \"使用人是:$User 资产编码是:$Assetcode Mac地址是:$Mac\"}}"
