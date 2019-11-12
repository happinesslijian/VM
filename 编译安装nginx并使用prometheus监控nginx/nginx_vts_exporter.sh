#!/bin/bash
#配置开机启动nginx_vts_exporter
#下载安装包并解压
wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    while true
    do
        wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
        if [ $? -eq 0 ]; then
            break
        fi
    done
else
    tar -zxf nginx-vts-exporter-*.tar.gz
    cp -R nginx-vts-exporter-*/nginx-vts-exporter /usr/local/bin/nginx-vts-exporter
fi
echo "---验证版本---"
nginx-vts-exporter --version
#创建并编写配置启动项配置文件
cat > /etc/systemd/system/nginx_vts_exporter.service <<EOF
[Unit]
Description=nginx_exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/nginx-vts-exporter -nginx.scrape_uri=http://localhost/status/format/json
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start nginx_vts_exporter && systemctl enable nginx_vts_exporter && systemctl status nginx_vts_exporter
echo "---验证---"
systemctl status nginx_vts_exporter
echo "---开机自启动---"
systemctl list-unit-files | grep nginx_vts_exporter
echo "---监听端口---"
ss -ntlp | grep 9913
#清除无用包
rm -rf ./nginx-vts-exporter-*
