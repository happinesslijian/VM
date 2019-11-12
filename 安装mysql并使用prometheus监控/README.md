# 安装mysql
```
centos7自带mariadb数据库,要先卸载mariadb再安装mysql
rpm -qa | grep -i mariadb
yum remove mariadb*
```
- 安装mysql依赖
```
yum install -y perl net-tools
```
- 下载msql
```
cd /opt
mkdir mysql
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
tar xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar -C mysql
cd mysql
$ rpm -ivh mysql-community-common-5.7.28-1.el7.x86_64.rpm
$ rpm -ivh mysql-community-libs-5.7.28-1.el7.x86_64.rpm
$ rpm -ivh mysql-community-client-5.7.28-1.el7.x86_64.rpm
$ rpm -ivh mysql-community-server-5.7.28-1.el7.x86_64.rpm
```
- 设置空密码登录
```
cat >> /etc/my.cnf <<EOF
skip-grant-tables=1
EOF
```
- 重启mysql服务
```
systemctl restart mysqld
```
- 更改mysql`root`用户的密码
```
mysql -u root  #使用命令行连接mysql数据库
 use mysql;  #切换到mysql数据库
 update user set authentication_string = password('nihao123!NIHAO'), password_expired = 'N', password_last_changed = now() where user ='root'; #修改root的密码，密码复杂一点
 exit; #退出
```
- 恢复密码登录
```
vim /etc/my.cnf
删除skip-grant-tables=1
```
- 重启mysql服务
```
systemctl restart mysqld
```
- 设置root远程连接数据库
```
mysql -u root -p 
use mysql;  #切换到mysql数据库
grant all privileges on *.* to 'root'@'%' identified by 'nihao123!NIHAO'; #修改root的密码，密码复杂一点
flush privileges; # 刷新权限
#创建一个用于mysqld_exporter连接到MySQL的用户并赋予所需的权限
GRANT REPLICATION CLIENT, PROCESS ON *.* TO 'mysqld_exporter'@'localhost' identified by 'nihao123!NIHAO';
GRANT SELECT ON performance_schema.* TO 'mysqld_exporter'@'localhost';
flush privileges;
exit; #退出
```
# 安装mysqld_exporter
```
cd /usr/local/
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.10.0/mysqld_exporter-0.10.0.linux-amd64.tar.gz
tar xzvf mysqld_exporter-0.10.0.linux-amd64.tar.gz
mv mysqld_exporter-0.10.0.linux-amd64 mysqld_exporter
cp mysqld_exporter/mysqld_exporter /usr/local/bin/
mysqld_exporter --version
```
- 使用systemctl管理mysqld_exporter
```
cat > /etc/systemd/system/mysqld_exporter.service <<EOF
[Unit]
Description=mysqld_exporter
After=network.target

[Service]
Environment=DATA_SOURCE_NAME=mysqld_exporter:nihao123!NIHAO@(127.0.0.1:3306)/
Restart=on-failure
ExecStart=/usr/local/bin/mysqld_exporter

[Install]
WantedBy=multi-user.target
EOF
```
- 重启并验证
```
systemctl daemon-reload && systemctl start mysqld_exporter && systemctl enable mysqld_exporter && systemctl status mysqld_exporter
web页面访问
http://IP:9104/metrics
http://192.168.100.139:9104/metrics
```
[如图所示](https://i.loli.net/2019/11/12/zrcOnkjhXm7HwJe.png)
# prometheus静态监控mysql配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: mysql
    static_configs:
      - targets: ['192.168.100.139:9104']
        labels:
          instance: db1
```
重启prometheus
```
systemctl restart prometheus
```
# prometheus基于文件服务发现监控mysql配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: 'mysql'
    file_sd_configs:
      - files:
        - mysql/mysqld_exporter.yaml
```
vim /etc/prometheus/mysql/mysqld_exporter.yaml
```
- targets:
  - 192.168.100.159:9104
  labels:
    instance: db123
    group: 某某项目组使用
```
[grafana模板下载]()