#!/bin/bash
user1=`who | head -n +1 | awk '{print $1}'`
cp /home/$user1/promtail  /usr/local/bin/promtail
echo "---验证版本---"
promtail --version
IP=`echo $(hostname -I | awk '{print $1}')`
read machine_user < /tmp/machine_user.txt
mkdir -p /etc/promtail/
cat << EOF > /etc/promtail/promtail-local-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://172.30.0.7:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      instance: $IP
      user: $machine_user
      __path__: /var/log/*.log

  - targets:
      - localhost
    labels:
      job: varlogs
      instance: $IP
      user: $machine_user
      __path__: /var/log/syslog

  - targets:
      - localhost
    labels:
      job: varlogs
      instance: $IP
      user: $machine_user
      __path__: /var/log/dmesg

EOF
cat > /etc/systemd/system/promtail.service <<EOF
[Unit]
Description=promtail
After=network.target 

[Service]
Type=simple
ExecStart=/usr/local/bin/promtail --config.file /etc/promtail/promtail-local-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start promtail && systemctl enable promtail
echo "---验证---"
systemctl is-active promtail
echo "---开机自启动---"
systemctl list-unit-files | grep promtail
echo "---监听端口---"
ss -ntlp | grep 9080

