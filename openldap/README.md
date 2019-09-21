# 部署openldap
### 说明：ldapAdmin或phpldapAdmin选其一来管理即可
1. 安装openldap服务
```
yum -y install openldap-servers openldap-clients
```
- 拷贝默认数据库文件并命名
```
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
```
- 改变文件属组及用户
```
chown ldap. /var/lib/ldap/DB_CONFIG
```
- 开机自启动
```
systemctl start slapd && systemctl enable slapd && systemctl status slapd && systemctl list-unit-files | grep slapd
```
2. 设置openldap密码
```
slappasswd
```
- 创建chrootpw.ldif文件 写入如下内容SSHA复制上面生成的密文到文件内
```
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx
```
[如图所示](https://i.loli.net/2019/09/19/rAydjh2CigsV4nD.png)
- 挂载文件
```
ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
```
[如图所示](https://i.loli.net/2019/09/19/UQwRANiXWHt8mD6.png) \
3. 设置实际环境LDAP DB
- 创建密码  (生成的密码复制粘贴到chdomain.ldif文件内)
```
slappasswd
```
- 创建文件 chdomain.ldif 写入如下内容 \
**注意：** 只有cn dc dc 三个点可以更改
```
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=admin,dc=dycd,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=dycd,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,dc=dycd,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=admin,dc=dycd,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=admin,dc=dycd,dc=com" write by * read
```
[如图所示](https://i.loli.net/2019/09/19/5Gj3PMQiV1olq8E.png)
- 挂载此文件
```
ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif
```
[如图所示](https://i.loli.net/2019/09/19/aDES7u8QTYXVkMJ.png) \
4. 创建basedomain.ldif文件写入如下内容 \
**注意：** 只有cn dc dc 三个点可以更改（根据实际公司需求）
```
dn: dc=dycd,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: Server World
dc: dycd

dn: cn=admin,dc=dycd,dc=com
objectClass: organizationalRole
cn: admin
description: Directory Manager

dn: ou=People,dc=dycd,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=dycd,dc=com
objectClass: organizationalUnit
ou: Group
```
[如图所示](https://i.loli.net/2019/09/19/ifzygGhVInuXW1b.png)
- 加载目录结构
```
ldapadd -x -D cn=admin,dc=dycd,dc=com -W -f basedomain.ldif
```
[如图所示](https://i.loli.net/2019/09/19/YpC4j7hqePxVgvk.png) \
5. 使用windows客户端管理 \
`保持汉化包和ldapadmin客户端程序在同一目录`
- [下载ldapAdmin](https://sourceforge.net/projects/ldapadmin/files/ldapadmin/1.6.1/LdapAdminExe-1.6.1.zip/download)
- [下载汉化包](http://www.ldapadmin.org/download/languages/download.php?id=3)
- [汉化配置过程](https://i.loli.net/2019/09/16/ruCpw1O8JUSYQ25.gif)
- [客户端登陆](https://i.loli.net/2019/09/13/Zpblfejohx54E2S.png)
6. 使用mac客户端管理
- [下载ldapAdmin](http://ldap-admin-mac.mac.novellshareware.com/)
7. 安装web界面phpldapadmin
```
rpm -ivh http://mirrors.ukfast.co.uk/sites/dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
yum install -y phpldapadmin httpd
# 查看apache版本
rpm -qa|grep httpd

cat > /etc/httpd/conf.d/phpldapadmin.conf << EOF
#
#  Web-based tool for managing LDAP servers
#

Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs

<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require all granted
  </IfModule>
  <IfModule !mod_authz_core.c>
    # Apache 2.2
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
    Allow from ::1
  </IfModule>
</Directory>
EOF

vi /etc/phpldapadmin/config.php
# 398行，默认是使用uid进行登录,我这里改为dn

# 启动apache
systemctl start httpd && systemctl enable httpd && systemctl status httpd && systemctl list-unit-files | grep httpd
```
- 网页版登录
```
http://IP/ldapadmin/
```
[如图所示](https://i.loli.net/2019/09/19/BRJ8gvqy9i17xMl.png)

## 接入应用设置
- [接入jumpserver设置](https://i.loli.net/2019/09/20/IRidulCYjp8BPbW.png)
- [接入容器gitlab应用](https://i.loli.net/2019/09/21/eSHlx5pnWf34PIz.png)
  - 这里使用的是helm安装的gitlab，内容填写在values.yaml文件里
  - 代码如下：
```
    LDAP_ENABLED: true
    LDAP_LABEL: LDAP
    LDAP_HOST: 192.168.100.167
    LDAP_PORT: 389
    LDAP_UID: uid
    LDAP_BIND_DN: cn=admin,dc=dycd,dc=com
    LDAP_PASS: passwd
    LDAP_TIMEOUT: 10
    LDAP_METHOD: plain
    LDAP_VERIFY_SSL: false
    LDAP_ACTIVE_DIRECTORY: false
    LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN: false
    LDAP_BASE: ou=gitlab,dc=dycd,dc=com
```
  - 判断LDAP是否连接成功可以连接到pod内查看
```
# kubectl exec -it gitlab-gitlab-core-0 /bin/bash -n gitlab
# ./bin/rake gitlab:ldap:check
```
[如图所示](https://i.loli.net/2019/09/22/pqN2M5rRestVYLc.png)
