#!/bin/bash
#配置开机启动redis_exporter
#下载安装包并解压
wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.2/redis_exporter-v1.3.2.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    while true
    do
        wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.2/redis_exporter-v1.3.2.linux-amd64.tar.gz
        if [ $? -eq 0 ]; then
            break
        fi
    done
else
    tar -zxf redis_exporter-*.tar.gz
    cp -R redis_exporter-*/redis_exporter /usr/local/bin/redis_exporter
fi
echo "---验证版本---"
redis_exporter --version
#创建工作目录
#mkdir -p /var/lib/node_exporter
#创建并编写配置启动项配置文件
cat > /usr/lib/systemd/system/redis_exporter.service <<EOF
[Unit]
Description=redis_exporter

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/redis_exporter -redis.addr 127.0.0.1:6379 -redis.password 123456

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start redis_exporter && systemctl enable redis_exporter
echo "---验证---"
systemctl status redis_exporter
echo "---开机自启动---"
systemctl list-unit-files | grep redis_exporter
echo "---监听端口---"
ss -ntlp | grep 9121
#清除无用包
rm -rf ./redis_exporter-*
