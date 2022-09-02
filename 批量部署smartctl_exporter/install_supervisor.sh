#!/bin/bash
#设定钉钉机器人通知
successDingDing() {
Time=`date +%Y-%m-%d-%H:%M:%S`
curl 'https://oapi.dingtalk.com/robot/send?access_token=317477bc611531630b8f4336506b323a298728c81898734861bf24dslo87r026' \
        -H 'Content-Type: application/json' \
        -d "{\"msgtype\": \"text\", 
             \"text\": {\"content\": \" 执行时间: $Time\r $success \"},
             \"at\": {\"isAtAll\": true}}"
}
failDingDing() {
Time=`date +%Y-%m-%d-%H:%M:%S`
curl 'https://oapi.dingtalk.com/robot/send?access_token=317477bc611531630b8f4336506b323a298728c81898734861bf24dslo87r026' \
        -H 'Content-Type: application/json' \
        -d "{\"msgtype\": \"text\", 
             \"text\": {\"content\": \" 执行时间: $Time\r $fail \"},
             \"at\": {\"isAtAll\": true}}"
}
#定义函数
iplist() {
for i in `ip a | egrep -v 'docker|br-|lo|veth|virbr' | grep UP | awk -F: '{print $2}'`
do
ip a show $i | grep inet  | awk '{print $2}' | awk -F/ '{print $1}' | head -n 1
done
}
count=`iplist | wc -l`
if [ $count > 1 ]; then
        for ip in `iplist`
        do
                netstat -nat | grep -i :22 | grep -o $ip | uniq -d
        done
fi > /tmp/.tmp
current_connection=`cat /tmp/.tmp`
user1=`who | head -n +1 | awk '{print $1}'`
apt install -y supervisor
if [ $? -eq 0 ]; then 
	echo -e "\033[42;37m $current_connection 已经成功安装supervisor \033[0m"
else
	echo -e "\033[41;37m $current_connection supervisor安装失败 \033[0m"
fi
mv /home/$user1/smartctl /usr/sbin/smartctl
mv /home/$user1/smartctl_exporter.conf /etc/supervisor/conf.d/
mkdir -p /etc/smartctl_exporter/
/bin/cp /home/$user1/smartctl_exporter /etc/smartctl_exporter/
if [ $? -ne 0 ]; then
        mv /etc/smartctl_exporter /etc/smartctl_exporter_bak_`date +%Y-%m-%d-%H:%M:%S`
	mkdir -p /etc/smartctl_exporter/
	/bin/cp /home/$user1/smartctl_exporter /etc/smartctl_exporter/
fi
#定义函数
diskname() {
lsblk -d | grep sd | awk '{print $1}'
}

#函数赋值变量i
for i in `diskname`
do 
cat >>/etc/smartctl_exporter/smartctl_exporter.yaml <<-EOF
smartctl_exporter:
  bind_to: "[0.0.0.0]:9633"
  url_path: "/metrics"
  fake_json: no
  smartctl_location: /usr/sbin/smartctl
  devices:
EOF
#计算行数后,输出到文件
number=`diskname | wc -l`
for j in $(seq $number);
do
        echo "  - /dev/$i" >> /etc/smartctl_exporter/smartctl_exporter.yaml
done    
done
#按自然顺序去重
sort -uV /etc/smartctl_exporter/smartctl_exporter.yaml -o /etc/smartctl_exporter/smartctl_exporter.yaml
#sed重写yaml顺序
sed -i '/^url_path/'d /etc/smartctl_exporter/smartctl_exporter.yaml
sed -i '/^  devices/'d /etc/smartctl_exporter/smartctl_exporter.yaml
sed -i '/^  url_path:/a\  devices:' /etc/smartctl_exporter/smartctl_exporter.yaml
systemctl enable supervisor.service
systemctl restart supervisor.service
supervisorctl status smartctl_exporter
echo -e "查看端口"
sleep 8
netstat -ntlp | grep 9633
if [ $? -eq 0 ]; then
        success=`echo -e "\033[42;37m $current_connection supervisor启动成功 \033[0m"`
	echo $success 
	successDingDing
else
        fail=`echo -e "\033[41;37m $current_connection supervisor启动失败 \033[0m"`
	echo $fail
	failDingDing
fi


