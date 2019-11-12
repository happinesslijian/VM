#!/bin/bash
#配置开机启动node_exporter
#下载安装包并解压
cd /usr/local
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.10.0/mysqld_exporter-0.10.0.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    while true
    do
        wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.10.0/mysqld_exporter-0.10.0.linux-amd64.tar.gz
        if [ $? -eq 0 ]; then
            break
        fi
    done
else
    tar -zxf mysqld_exporter-*.tar.gz
    cp -R mysqld_exporter-*/mysqld_exporter /usr/local/bin/mysqld_exporter
fi
echo "---验证版本---"
mysqld_exporter --version
cat > /etc/systemd/system/mysqld_exporter.service <<EOF
[Unit]
Description=mysqld_exporter
After=network.target

[Service]
Environment=DATA_SOURCE_NAME=mysqld_exporter:nihao123!NIHAO@(127.0.0.1:3306)/
Restart=on-failure
ExecStart=/usr/local/bin/mysqld_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl start mysqld_exporter && systemctl enable mysqld_exporter && systemctl status mysqld_exporter
echo "---验证---"
systemctl status mysqld_exporter
echo "---开机自启动---"
systemctl list-unit-files | grep mysqld_exporter
echo "---监听端口---"
ss -ntlp | grep 9104
#清除无用包
rm -rf ./mysqld_exporter-*
