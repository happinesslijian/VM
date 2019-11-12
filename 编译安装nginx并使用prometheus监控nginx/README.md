参考文档： \
https://www.jianshu.com/p/affac5f2d56e \
https://www.hi-linux.com/posts/27014.html \
https://www.jianshu.com/p/d72c8f06684a
# 编译安装nginx并使用prometheus监控nginx
- 下载nginx
```
cd /usr/local
useradd nginx
wget http://nginx.org/download/nginx-1.12.2.tar.gz
git clone git://github.com/vozlt/nginx-module-vts.git
yum -y install gcc automake pcre-devel zlib-devel openssl-devel
```
- 编译安装nginx
```
tar -zxvf nginx-1.12.2.tar.gz
cd nginx-1.12.2
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-stream --add-module=/usr/local/nginx-module-vts
echo $?
make && make install
echo $?
```
- 配置环境变量
```
cat >> /etc/profile <<EOF
export PATH=/usr/local/nginx/sbin:$PATH
EOF

#刷新profile
source /etc/profile
ln -s /usr/local/nginx/conf /etc/nginx
```
- 修改nginx配置文件
  - `vim /etc/nginx/nginx.conf`
```
user  nginx; #添加nginx用户
pid  /var/run/nginx.pid; #指定pid目录
```
- 创建工作目录并分配权限
```
mkdir /etc/nginx/conf.d
mkdir /var/log/nginx
chown -R nginx:nginx /var/log/nginx
```
- 使用systemctl管理nginx
```
cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```
- 重启nginx
```
systemctl enable nginx.service
systemctl start nginx.service
systemctl status nginx.service
```

# 填写监控nginx必要参数
```
vim /etc/nginx/nginx.conf


http {
    vhost_traffic_status_zone; #监控nginx必要参数

    ...

    server {

        ...

        location /status {
            vhost_traffic_status_display; #监控nginx必要参数
            vhost_traffic_status_display_format html; #监控nginx必要参数
        }
    }
}
```
- 重启并验证
```
nginx -t
systemctl restart nginx.service

web页面访问
http://IP/status
http://192.168.100.139/status
以json格式访问
http://192.168.100.139/status/format/json
```
[如图所示](https://i.loli.net/2019/11/11/Ue46BklN8cbwy5i.png) \
[如图所示](https://i.loli.net/2019/11/11/QbJO48LqDwVtkxZ.png)
# 下载nginx-vts-exporter
```
cd /usr/local/
wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
tar zxvf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
mv nginx-vts-exporter-0.10.3.linux-amd64 nginx-vts-exporter
cp nginx-vts-exporter/nginx-vts-exporter /usr/local/bin
nginx-vts-exporter -version
```
- 使用systemctl管理nginx_vts_exporter
```
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
```


- 重启并验证
```
systemctl daemon-reload && systemctl start nginx_vts_exporter && systemctl enable nginx_vts_exporter && systemctl status nginx_vts_exporter

web页面访问
http://IP:9913/metrics
http://192.168.100.139:9913/metrics
```
[如图所示](https://i.loli.net/2019/11/11/fY4crQazw7Fg2hx.png)
# prometheus静态监控nginx配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: nginx
    static_configs:
      - targets: ['192.168.100.139:9913']
        labels:
          instance: nginx-web-1
```
重启prometheus
```
systemctl restart prometheus
```
# prometheus基于文件服务发现监控nginx配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: nginx
    file_sd_configs:
      - files:
        - nginx/nginx_vts_exporter.yaml
```
vim /etc/prometheus/nginx/nginx_vts_exporter.yaml
```
- targets:
  - 192.168.100.139:9913
  labels:
    group: nginx-1项目测试
```
grafana模板ID   `2949`



# nginx反向代理并且监控
- 配置nginx
  - 下面是强制跳转https的示例
  - `vim /etc/nginx/nginx.conf`
```
http {
    vhost_traffic_status_zone;   #监控nginx必写参数！
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;


    server {
        listen       80;
        listen       443 ssl;
        ssl_certificate /data/tls.crt;
        ssl_certificate_key /data/tls.key;
        server_name  www.alertmanager.test.com; #指定要代理的服务名称
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        if ($server_port = 80 ) {
                return 301 https://$host$request_uri;
        }
        location /status {
            vhost_traffic_status_display; #监控nginx必写参数！
            vhost_traffic_status_display_format html; #监控nginx必写参数！
        } #下面是配置第二个location模块,用作反向代理
        location / {
            proxy_pass http://192.168.100.139:9093;
        }
        error_page 497  https://$host$request_uri;
        }
```
- 配置nginx
  - 下面是http示例
  - `vim /etc/nginx/nginx.conf`
```
    server {
        listen       80;
        server_name  www.alertmanager.test.com; #自定义域名
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        location /status {
            vhost_traffic_status_display; #监控nginx必写参数！
            vhost_traffic_status_display_format html; #监控nginx必写参数！
        }

        location / {
            proxy_pass http://192.168.100.139:9093; #填写对应主机IP
        }
        }
```
验证：
两个都能打开就正常

http://192.168.100.139/status

www.alertmanager.test.com
