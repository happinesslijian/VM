# 安装grafana
- 下载安装grafana
```
wget https://dl.grafana.com/oss/release/grafana-6.4.2-1.x86_64.rpm
sudo yum localinstall grafana-6.4.2-1.x86_64.rpm
```
- 启动grafana-server
```
systemctl start grafana-server
systemctl status grafana-server
```
- 访问grafana Dashboard
```
IP:3000
```
`默认用户名密码admin/admin`
# grafana接入ldap
[参考链接](https://grafana.com/docs/auth/ldap/) \
[参考链接](https://blog.frognew.com/2017/07/config-grafana-with-ldap.html)
- 修改grafana的配置文件`grafana.ini`
```
vim /etc/grafana/grafana.ini
```
  - 开启enabled=true，指定ldap配置文件
```
[auth.ldap]
enabled = true
config_file = /etc/grafana/ldap.toml
;allow_sign_up = true

# LDAP backround sync (Enterprise only)
# At 1 am every day
;sync_cron = "0 0 1 * * *"
;active_sync_enabled = true
```
- 修改grafana的ldap配置文件`ldap.toml`
```
vim /etc/grafana/ldap.toml
```
   - 填写如下内容
```
# To troubleshoot and get more log info enable ldap debug logging in grafana.ini
# [log]
# filters = ldap:debug

[[servers]]
# Ldap server host (specify multiple hosts space separated)
# 填写ldap服务器IP
host = "192.168.100.167"
# Default port is 389 or 636 if use_ssl = true
# 填写ldap服务端口
port = 389
# Set to true if ldap server supports TLS
use_ssl = false
# Set to true if connect ldap server with STARTTLS pattern (create connection in insecure, then upgrade to secure connection with TLS)
start_tls = false
# set to true if you want to skip ssl cert validation
ssl_skip_verify = false
# set to the path to your root CA certificate or leave unset to use system defaults
# root_ca_cert = "/path/to/certificate.crt"
# Authentication against LDAP servers requiring client certificates
# client_cert = "/path/to/client.crt"
# client_key = "/path/to/client.key"

# Search user bind dn
# 填写ldap信息
bind_dn = "cn=admin,dc=dycd,dc=com"
# Search user bind password
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
# 填写ldap服务密码
bind_password = 'passwd'

# User search filter, for example "(cn=%s)" or "(sAMAccountName=%s)" or "(uid=%s)"
search_filter = "(cn=%s)"

# An array of base dns to search through
# 填写ldap信息
search_base_dns = ["ou=grafana,dc=dycd,dc=com"]

## For Posix or LDAP setups that does not support member_of attribute you can define the below settings
## Please check grafana LDAP docs for examples
group_search_filter = "(&(objectClass=posixGroup)(memberUid=%s))"
# group_search_base_dns = ["ou=groups,dc=grafana,dc=org"]
# group_search_filter_user_attribute = "uid"

# Specify names of the ldap attributes your ldap uses
[servers.attributes]
name = "givenName"
surname = "sn"
username = "cn"
member_of = "cn"
email =  "email"

# Map ldap groups to grafana org roles
[[servers.group_mappings]]
group_dn = "cn=admin,dc=grafana,dc=com"
org_role = "Admin"
# To make user an instance admin  (Grafana Admin) uncomment line below
# grafana_admin = true
# The Grafana organization database id, optional, if left out the default org (id 1) will be used
# org_id = 1

[[servers.group_mappings]]
group_dn = "cn=users,dc=grafana,dc=com"
org_role = "Editor"

[[servers.group_mappings]]
# If you want to match all (or no ldap groups) then you can use wildcard
group_dn = "*"
org_role = "Viewer"
```
- 重启grafana-server
```
systemctl restart grafana-server
```
- 重新打开grafana Dashboard,输入ldap已经存在的用户点击run可以看到如下效果即为成功 \
[如图所示]()
  - 接下来可以使用ldap创建出来的用户进行登录了
## [安装openldap](https://github.com/happinesslijian/VM/tree/master/openldap)
