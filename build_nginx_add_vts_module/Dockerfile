# 构建阶段: 安装依赖和编译 nginx
FROM alpine:3.18 AS build

# 安装构建所需的工具和依赖
RUN apk add --no-cache --virtual .build-deps gcc musl-dev make libxslt libxml2-dev pcre-dev git wget openssl-dev build-base zlib-dev linux-headers bash

# 下载 Nginx 1.22.0 源代码
RUN wget http://nginx.org/download/nginx-1.22.0.tar.gz && \
    tar -zxvf nginx-1.22.0.tar.gz && \
    cd nginx-1.22.0 && \
    # 下载 vhost_traffic_status 模块
    git clone -b v0.2.2 https://github.com/vozlt/nginx-module-vts.git && \
    # 编译 Nginx 并包含 vhost_traffic_status 模块
    ./configure --prefix=/var/lib/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --with-http_ssl_module --add-dynamic-module=nginx-module-vts --with-compat --with-stream --with-http_v2_module && \
    make && \
    make install

# 清理不必要的构建依赖
RUN apk del .build-deps && rm -rf nginx-1.22.0 nginx-1.22.0.tar.gz

# 运行阶段: 运行 nginx 和 supervisord
FROM alpine:3.18

# 安装运行所需的工具
RUN apk add --no-cache \
    nginx \
    #nginx-mod-stream \
    supervisor \
    bash \
    curl

# 创建必需的目录
RUN mkdir -p /run/nginx /etc/nginx/stream.d /etc/supervisor.d /var/log/supervisor /var/run/supervisor /etc/letsencrypt/stage

# 复制编译好的 nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /var/lib/nginx /etc/nginx
RUN ls -al /etc/nginx/ && ls -al /usr/lib/nginx/modules/ && ls -al /var/lib/nginx/modules/
COPY --from=build /usr/lib/nginx/modules/ngx_http_vhost_traffic_status_module.so /usr/lib/nginx/modules

# 删除默认的 nginx 配置文件
RUN rm -f /etc/nginx/conf/nginx.conf

# 定义 supervisord.conf 配置文件
RUN echo "[unix_http_server]" > /etc/supervisord.conf && \
    echo "file=/var/run/supervisor/supervisord.sock" >> /etc/supervisord.conf && \
    echo "[supervisord]" >> /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "logfile=/var/log/supervisor/supervisord.log" >> /etc/supervisord.conf && \
    echo "logfile_maxbytes=50MB" >> /etc/supervisord.conf && \
    echo "logfile_backups=10" >> /etc/supervisord.conf && \
    echo "loglevel=info" >> /etc/supervisord.conf && \
    echo "[program:nginx]" >> /etc/supervisord.conf && \
    #echo "command=/usr/sbin/nginx -g \"daemon off;\"" >> /etc/supervisord.conf && \
    echo "command=/usr/sbin/nginx -c /etc/nginx/nginx.conf -g \"daemon off;\"" >> /etc/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/nginx.log" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/nginx_err.log" >> /etc/supervisord.conf

# 创建 supervisord 配置文件
RUN echo '[program:nginx]' > /etc/supervisor.d/nginx.ini && \
    #echo 'command=/usr/sbin/nginx -g "daemon off;"' >> /etc/supervisor.d/nginx.ini && \
    echo 'command=/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"' >> /etc/supervisor.d/nginx.ini && \
    echo 'autostart=true' >> /etc/supervisor.d/nginx.ini && \
    echo 'autorestart=true' >> /etc/supervisor.d/nginx.ini

# 配置 supervisord 启动 nginx
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 设置容器启动时的默认命令
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

