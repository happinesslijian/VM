# 安装redis
- 下载解压redis
```
wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar -zxvf redis-5.0.5.tar.gz
```
- 编译安装
```
cd redis-5.0.5
make
cd src/
make install
```
## 前台方式运行
```
redis-server
```
`因为现在不是守护进程启动的。所以界面如果中断redis即关闭（界面无法操作）
redis启动成功，但是这种启动方式需要一直打开窗口，不能进行其他操作，不太方便
`
## 后台方式运行
```
vim redis-5.0.5/redis.conf
```
修改如下: \
[daemonize yes](https://i.loli.net/2019/10/10/o8NlLu7QvsjYJnX.png) \
[bind 127.0.0.1](https://i.loli.net/2019/10/10/DiTG2PHYyfgpvUL.png) \
[protected-mode no](https://i.loli.net/2019/10/10/Cp8NaGHeURdkKF6.png) \
[requirepass foobared](https://i.loli.net/2019/10/10/kQtD8JM1UIv3GqW.png)
## 指定配置文件启动
```
cd src
redis-server /redis-5.0.5/redis.conf
```
## 验证redis是否已经启动
```
ps -ef | grep redis
```
`端口号前面是*表示所有IP都可以访问redis` \
[如图所示](https://i.loli.net/2019/10/10/yLmsPa5M9uYeQo8.png)
## 设置redis开机自启动
```
mkdir -p /etc/redis
cp /mnt/redis-5.0.5/redis.conf /etc/redis/
cd /etc/redis/
mv redis.conf 6379.conf
cp /mnt/redis-5.0.5/utils/redis_init_script /etc/init.d/redisd
vim /etc/init.d/redisd
```
`写上刚才配置过的密码`
[如图所示](https://i.loli.net/2019/10/10/s4uVZpTbF2z7doC.png)
```
cd /etc/init.d/
chkconfig --add redisd
service redisd start
service redisd stop
systemctl start redisd
systemctl stop redisd
```
# 下载安装redis_exporter
- 下载 redis exporter
```
wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.2/redis_exporter-v1.3.2.linux-amd64.tar.gz
tar xf redis_exporter-v1.3.2.linux-amd64.tar.gz
```
- 使用systemctl管理redis_exporter
  - `-redis.addr 127.0.0.1:6379 redis所在IP地址` `-redis.password 123456redis密码`
```
cat > /usr/lib/systemd/system/redis_exporter.service <<EOF
[Unit]
Description=redis_exporter

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/redis_exporter -redis.addr 127.0.0.1:6379 -redis.password 123456

[Install]
WantedBy=multi-user.target

EOF
```
- 重启并验证
```
systemctl daemon-reload && systemctl start redis_exporter && systemctl enable redis_exporter
# web页面访问
http://IP:9121/metrics
```
[如图所示](https://i.loli.net/2019/11/13/MXSGZk4syI6clF2.png)
# prometheus静态监控redis配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: 'redis'
    static_configs:
      - targets: ['192.168.100.139:9121']
        labels:
          instance: redis1
          group: redis
```
重启prometheus
```
systemctl restart prometheus
```
# prometheus基于文件服务发现监控redis配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: redis
    file_sd_configs:
      - files:
        - redis/redis_exporter.yaml
    metrics_path: /metrics
    relabel_configs:
    - source_labels: [__address__]
      regex: (.*)
      target_label: instance
      replacement: $1
    - source_labels: [__address__]
      regex: (.*)
      target_label: __address__
      replacement: $1:9121        
```
vim /etc/prometheus/redis/redis_exporter.yaml
```
- targets:
  - 192.168.100.139
  labels:
    instance: redis-1
    group: redis-1项目测试
```
grafana模板ID 763
