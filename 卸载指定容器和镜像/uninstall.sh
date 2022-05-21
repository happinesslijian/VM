#!/bin/bash
#docker stop $(docker ps -a | awk '{ print $1}' | tail -n +2)
#docker rm $(docker ps -a | awk '{ print $1}' | tail -n +2)
#docker rmi $(docker images | awk '{print $3}' |tail -n +2)

#方式一过滤标签来实现
#docker-compose -f /opt/dist/TCI-Agent/docker-compose.yml stop
#docker-compose -f /opt/dist/TCI-Agent/docker-compose.yml rm
#NOlatestTAG=$(docker images | egrep -v 'latest' | awk '{print $3}' | tail -n +2)
#images=$(cat /opt/dist/TCI-Agent/docker-compose.yml | grep 'image: ' | cut -d':' -f 2)
#docker rmi $images
#docker rmi $NOlatestTAG
judge1=镜像
judge2=容器
judge() {
if [ $? -eq 0 ]; then
	echo -e "\033[42;37m HCE${judge1}和${judge2}已经删除 \033[0m"
else
        echo -e "\033[42;37m HCE${judge1}和${judge2}已经删除,请勿重复删除 \033[0m"
fi
}

#方式二先强制删除镜像再删除停止的容器
##说明：正确的删除顺序是：
### 1.先停止容器
### 2.再删除已经停止的容器
### 3.再删除容器镜像
### 因为这里的需求是只能删除某几个容器和镜像，而不删除其他的容器和镜像。所以我采用了先停止容器,再强制删除容器镜像,再删除已经停止的容器 步骤二和三反过来了
### 使用docker-compose如果先停止容器,再删除已经停止的容器,再强制删除容器镜像的话,就没办法通过docker-compose -f docker-compose.yml images看到镜像了,也就没办法删除指定的镜像了
docker-compose -f /opt/dist/TCI-Agent/docker-compose.yml stop
docker-compose -f /opt/dist/TCI-Agent/docker-compose.yml images | awk '{print $4}' | tail -n +2 | xargs docker rmi -f 2>/dev/null 
judge
docker rm $(docker ps -aq) 2>/dev/null
if [ $? -eq 0 ]; then
	judge
else 
	echo -e "\033[41;37m 有其他非HCE容器正在运行 \033[0m"
fi

systemctl stop tcs*
for i in `rpm -qa | grep tci`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep ntfs`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep mysql-libs`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep lampp`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep jquery`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep chartjs`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep bootstrap`;do rpm -e $i --nodeps; done
for i in `rpm -qa | grep bootbox`;do rpm -e $i --nodeps; done

while true; do
read -p "是否备份windows镜像？[y/n] " yn
    case $yn in
        [yY][eE][sS]|[yY] )
        yn="yes"
        mv /opt/tci/diskimages /opt/diskimages-bak
        break
        ;;
        [nN][oO]|[nN] )
        rm -rf /opt/tci/
	rm -rf /opt/lampp
        break
        ;;
        * )
        echo "Please answer yes or no."
        ;;
    esac
done


#rm -rf /opt/tci
#rm -rf /opt/lampp
#
