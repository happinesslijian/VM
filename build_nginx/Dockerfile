# 构建阶段: 安装依赖和编译 nginx
FROM alpine:3.18 as build

# 安装构建所需的工具和依赖
RUN apk add --no-cache --virtual .build-deps gcc musl-dev make libxslt libxml2-dev pcre-dev

# 安装 nginx
RUN apk add --no-cache nginx nginx-mod-stream

# 清理不必要的构建依赖
RUN apk del .build-deps

# 复制 nginx 配置文件
#COPY conf.d/cuckoo.conf /etc/nginx/conf.d/
#COPY example.conf /etc/nginx/

# 运行阶段: 运行 nginx 和 supervisord
FROM alpine:3.18

# 安装运行所需的工具
RUN apk add --no-cache \
    nginx \
    nginx-mod-stream \
    supervisor \
    bash \
    curl

# 定义supervisord.conf配置文件
RUN echo "[unix_http_server]" > /etc/supervisord.conf && \
    echo "file=/var/run/supervisor/supervisord.sock" >> /etc/supervisord.conf && \
    echo "[supervisord]" >> /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "logfile=/var/log/supervisor/supervisord.log" >> /etc/supervisord.conf && \
    echo "logfile_maxbytes=50MB" >> /etc/supervisord.conf && \
    echo "logfile_backups=10" >> /etc/supervisord.conf && \
    echo "loglevel=info" >> /etc/supervisord.conf && \
    #echo "pidfile=/var/run/supervisor/supervisord.pid" >> /etc/supervisord.conf && \
    echo "[program:nginx]" >> /etc/supervisord.conf && \
    echo "command=/usr/sbin/nginx -g \"daemon off;\"" >> /etc/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/nginx.log" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/nginx_err.log" >> /etc/supervisord.conf

# 创建必需的目录
RUN mkdir -p /run/nginx /etc/nginx/stream.d /etc/supervisor.d /var/log/supervisor /var/run/supervisor /etc/letsencrypt/stage

# 复制编译好的 nginx 配置文件
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx

# 创建 supervisord 配置文件
RUN echo '[program:nginx]' > /etc/supervisor.d/nginx.ini && \
    echo 'command=/usr/sbin/nginx -g "daemon off;"' >> /etc/supervisor.d/nginx.ini && \
    echo 'autostart=true' >> /etc/supervisor.d/nginx.ini && \
    echo 'autorestart=true' >> /etc/supervisor.d/nginx.ini

# 配置 supervisord 启动 nginx
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 设置容器启动时的默认命令
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
