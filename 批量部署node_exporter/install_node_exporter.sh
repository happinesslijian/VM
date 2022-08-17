#!/bin/bash
user1=`who | head -n +1 | awk '{print $1}'`
cp /home/$user1/node_exporter  /usr/local/bin/node_exporter
echo "---验证版本---"
node_exporter --version
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=node_exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter
echo "---验证---"
systemctl is-active node_exporter
echo "---开机自启动---"
systemctl list-unit-files | grep node_exporter
echo "---监听端口---"
ss -ntlp | grep 9100

