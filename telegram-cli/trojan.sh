#!/bin/sh
###install trojan
yum -y install wget 
cd /usr/src && wget -c https://github.com/trojan-gfw/trojan/releases/download/v1.15.1/trojan-1.15.1-linux-amd64.tar.xz
tar xvf trojan-1.15.1-linux-amd64.tar.xz

cat > /usr/src/trojan/config.json <<-EOF
{
    "run_type": "client",
    "local_addr": "0.0.0.0",
    "local_port": 1111,
    "remote_addr": "yiyi.superdear.top",
    "remote_port": 443,
    "password": [
        "A3DUzDjTwzCHdQ3r"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "",
        "key": "",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 81
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "",
        "cafile": ""
    }
}
EOF

cat > /etc/systemd/system/trojan.service <<-EOF
[Unit]
Description=trojan
After=network.target
[Service]
Type=simple
PIDFile=/usr/src/trojan/trojan.pid
ExecStart=/usr/src/trojan/trojan -c /usr/src/trojan/config.json -l /usr/src/trojan/trojan.log
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=1s
[Install]
WantedBy=multi-user.target
EOF

systemctl start trojan

ps aux | grep trojan | grep -v grep

systemctl enable trojan

###install privoxy
yum -y update
yum -y install epel-release privoxy
cat >> /etc/privoxy/config <<EOF
forward-socks5t / 127.0.0.1:1080 .
EOF
systemctl start privoxy
sleep 5
systemctl enable privoxy
systemctl status privoxy

export https_proxy=http://127.0.0.1:8118 \
http_proxy=http://127.0.0.1:8118 \
all_proxy=socks5://127.0.0.1:1080

echo "验证访问google.com"
curl www.google.com
