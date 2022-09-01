#!/bin/bash
user1=`who | head -n +1 | awk '{print $1}'`
cp /home/$user1/nvidia_gpu_exporter  /usr/bin/nvidia_gpu_exporter
echo "---验证版本---"
nvidia_gpu_exporter --version
cat > /etc/systemd/system/nvidia_gpu_exporter.service <<EOF
[Unit]
Description=nvidia_gpu_exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/nvidia_gpu_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start nvidia_gpu_exporter && systemctl enable nvidia_gpu_exporter
echo "---验证---"
systemctl is-active nvidia_gpu_exporter
echo "---开机自启动---"
systemctl list-unit-files | grep nvidia_gpu_exporter
echo "---监听端口---"
ss -ntlp | grep 9835

