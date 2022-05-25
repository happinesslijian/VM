#!/bin/bash
txt=/srv/p.txt
cat /dev/null > $txt
check() {
##这里和云服务器有差距 获取IP不准确
if [ $? -eq 0 ]; then
        successmsg=" 
        TIME:$(date +%F-%T) \n
        HOSTNAME:$(hostname) \n
	IPADDR:$(ifconfig | grep inet | egrep -v 'inet6|127' | awk 'NR==4{print $2}') \n
        SERVICENAME:$i \n
	SERVICESTATUS:$status \n
        "
        echo -e $successmsg >> $txt
else
        failmsg="
        TIME:$(date +%F-%T) \n
        HOSTNAME:$(hostname) \n
	IPADDR:$(ifconfig | grep inet | egrep -v 'inet6|127' | awk 'NR==4{print $2}') \n
        SERVICENAME:$i \n
	SERVICESTATUS:$status \n
        "
        echo -e $failmsg >> $txt 
fi

}

for i in tes-web.service tcs-mudf-server.service tcs-delivery-tracker.service tcs-disk-server.service tcs-setup.service tcs-delivery-server.service tcs-ccontro-server.service tcs-data.service tcs-dnsmasq.service;
do 
	status=$(systemctl is-active $i)
	check
done
#通过邮件通知
mail=$(cat $txt | grep -B 5 -w inactive)
if [ $? -eq 0 ]; then
        echo -e "${mail}" | mailx -c wzb201xxxx@163.com -s "TCI服务定时巡检" 151xxxxxxxx@163.com
else
        echo -e "TCI服务都运行正常" | mailx -c wzb201xxxx@163.com -s "TCI服务定时巡检" 151xxxxxxxx@163.com
fi

#通过pushplus通知到微信
TOKEN="90aa4ee226b74c81af109593292cxxxx"
title="监控TCS进程"
URLPUSHPLUS="http://www.pushplus.plus/send/"
template="json"
if [ -n "${TOKEN}" ]; then
	content=$(cat $txt)
	wget -q --output-document=/dev/null --post-data="title=${title}&content=${content}" ${URLPUSHPLUS}${TOKEN}.send
fi


