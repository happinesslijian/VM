# ==============================
# 🔧 Build Stage
# ==============================
FROM alpine:3.18 AS build

RUN apk add --no-cache --virtual .build-deps \
    gcc musl-dev make libxslt libxml2-dev \
    pcre-dev git wget openssl-dev build-base \
    zlib-dev linux-headers bash libmaxminddb-dev

# 使用清华镜像下载 Nginx 源码
RUN wget http://nginx.org/download/nginx-1.27.0.tar.gz && \
    tar -zxvf nginx-1.27.0.tar.gz && \
    cd nginx-1.27.0 && \
    # 下载 vhost_traffic_status 模块
    git clone -b v0.2.2 https://github.com/vozlt/nginx-module-vts.git && \
    # 下载 geoip2 模块
    git clone https://github.com/leev/ngx_http_geoip2_module.git && \
    # 编译 Nginx 模块
    ./configure \
      --prefix=/var/lib/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/opt/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_realip_module \
      --with-http_stub_status_module \
      --with-compat \
      --with-stream \
      --add-dynamic-module=nginx-module-vts \
      --add-dynamic-module=ngx_http_geoip2_module && \
    make && make install

RUN apk del .build-deps && rm -rf nginx-1.27.0 nginx-1.27.0.tar.gz

# ==============================
# 🚀 Runtime Stage
# ==============================
FROM alpine:3.18

RUN apk add --no-cache \
    nginx supervisor bash curl libmaxminddb

ENV GEOIP_PATH=/opt/nginx/geoip

RUN mkdir -p /run/nginx /etc/nginx/conf.d /etc/nginx/stream.d \
    /opt/nginx/modules /opt/nginx/logs \
    /etc/supervisor.d /var/log/supervisor /var/run/supervisor \
    $GEOIP_PATH /etc/letsencrypt/stage

COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /var/lib/nginx /etc/nginx
COPY --from=build /opt/nginx/modules/* /opt/nginx/modules/

# 👇 替换为我们改过的 nginx.conf 和入口脚本
COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 🔧 配置 supervisord
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "logfile=/var/log/supervisor/supervisord.log" >> /etc/supervisord.conf && \
    echo "[program:nginx]" >> /etc/supervisord.conf && \
    echo "command=/usr/sbin/nginx -c /etc/nginx/nginx.conf -g 'daemon off;'" >> /etc/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/nginx.log" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/nginx_err.log" >> /etc/supervisord.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

