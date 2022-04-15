#!/bin/bash
while true; do
cat << EOF
********please enter your choise:(1-6)****
(1) 安装NFS存储服务.
(2) 安装docker.
(3) 安装gitlab.
(4) Exit Menu.
(5) 是否重启计算机.
EOF
read -p "Now select the top option to: " input
case $input in 

1) echo "安装nfs存储服务"
sh ./nfs.sh;;

2) echo "安装docker"
curl -fsSL https://get.docker.com/ | bash -s docker --mirror Aliyun && \
systemctl restart docker && \
sleep 5 && \
systemctl enable docker;;

3) echo "安装gitlab:"
sh ./gitlab.sh;;

4) echo "Exit Bye-Bye"
exit;;

5) echo "是否重启计算机"
function choose_reboot(){
    echo -n "是否重启？(y or n)"
    read choice
    if [ ${choice} == "y" ];then
        echo -e '\033[1;31m 你选择了重启 \033[0m'
        reboot
    elif [ ${choice} == "n" ];then
        echo "你选择不重启"
    else
        echo "输入有误，请重新输入"
        choice
    fi
}
choose_reboot;;
esac
done
