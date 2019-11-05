wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
if [ $? -ne 0 ]; then
    while true
    do
        wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
        if [ $? -eq 0 ]; then
            break
        fi
    done
else
    unzip consul_*
    cp consul /usr/local/bin/
fi
consul --version
mkdir -p /var/log/consul
mkdir -p /etc/consul.d
cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description=consul
After=syslog.target network.target

[Service]
Type=simple
RemainAfterExit=no
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/consul agent -ui -server -node=server -bootstrap -bind 127.0.0.1 -client 0.0.0.0 \\
  -data-dir /tmp/consulserver -config-dir=/etc/consul.d \\
  -log-file=/var/log/consul

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload && systemctl start consul && systemctl enable consul
systemctl status consul
systemctl list-unit-files | grep consul
ss -ntlp | grep 8300
rm -rf ./consul_*
