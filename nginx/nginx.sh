#!/bin/bash
echo -e '\033[1;31m 关闭防火墙 \033[0m'
systemctl stop firewalld
systemctl disable firewalld
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 关闭selinux \033[0m'
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 建立元数据 \033[0m'
yum makecache
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 安装nginx \033[0m'
yum -y install nginx 
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 导入nginx配置文件 \033[0m'
echo -n "请输入文件存放目录(绝对路径开始)(不存在的会自动创建):"
read file_dir
mkdir -p ${file_dir}
cat << EOF > /etc/nginx/nginx.conf
user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        log_format proxy_format '\$remote_addr - \$remote_user [\$time_local] "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_user_agent" "\$http_x_forwarded_for"';

        access_log /var/log/nginx/access.log proxy_format;

        sendfile on;

        keepalive_timeout 65;


        gzip  on;
        autoindex on;# 显示目录
        autoindex_exact_size on;# 显示文件大小
        autoindex_localtime on;# 显示文件时间 
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
        server {
            client_max_body_size 500M;
            listen 8000 default_server;
            root ${file_dir};

            location /api/upload/ {
                proxy_pass_header Server;
                proxy_set_header Host \$http_host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_pass http://127.0.0.1:9876/;
            }

            error_page 404 /404.html;
                location = /40x.html {
            }

            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }

        }

}
EOF
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 重启nginx \033[0m'
systemctl restart nginx 
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m nginx开机自启动 \033[0m'
systemctl enable nginx
echo -e '\033[1;31m ********************************************************************************** \033[0m'

echo -e '\033[1;31m 查看nginx开机列表 \033[0m'
systemctl list-unit-files | grep 'nginx' | grep enabled
echo -e '\033[1;31m ********************************************************************************** \033[0m'
exit

