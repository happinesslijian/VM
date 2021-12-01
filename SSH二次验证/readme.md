## ssh二次验证

#### 时间同步
```
yum install -y ntpdate
ntpdate pool.ntp.org
```
#### 安装必要软件
```
# Ubuntu
sudo apt install -y libpam-google-authenticator

# CentOS7
yum install -y epel-release
yum install -y google-authenticator
```
#### 生成二次验证代码
```
# 生成验证码
# 哪个账号需要动态验证码，请切换到该账号下操作

# -t: 使用 TOTP 验证
# -f: 将配置保存到 ~/.google_authenticator 文件里面
# -d: 不允许重复使用以前使用的令牌
# -w 3: 使用令牌进行身份验证以进行时钟偏移
# -e 10: 生成 10 个紧急备用代码
# -r 3 -R 30: 限速 - 每 30 秒允许 3 次登录
$ google-authenticator -t -f -d -w 3 -e 10 -r 3 -R 30
```
#### 配置 SSH 服务启用两步验证
```
# 启用两步验证
sudo vim /etc/pam.d/sshd
# 编辑pam.d下的sshd文件，在第一行添加
auth required pam_google_authenticator.so  

# 修改SSH配置文件
$ sudo vim /etc/ssh/sshd_config
ChallengeResponseAuthentication yes

# 重启SSH服务
$ sudo systemctl restart sshd
```
#### 手机安装 Google 身份验证器
```
Google Authenticator
1. 通过此工具扫描上一步生成的二维码图形，获取动态验证码
2. 之后，就可以使用手机进行二次认证了，才能登陆服务器了
```
#### [验证](https://i.loli.net/2021/12/01/a1TDWIuPXslEk5e.gif)
```
使用Xshell登陆的话，使用Keyboard Interactive验证
先输入验证码Verification code:
再输入用户密码Password：
```

#### 使用 Fail2ban 去屏蔽多次尝试密码的 IP
```
# 安装软件
sudo apt install -y fail2ban

# 配置文件
vim /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8
bantime  = 86400
findtime = 600
maxretry = 5
banaction = firewallcmd-ipset
action = %(action_mwl)s

[sshd]
enabled = true
filter  = sshd
port    = 1090
action = %(action_mwl)s
logpath = /var/log/secure

# 重启服务
systemctl restart fail2ban
```
#### 从二次验证锁定中恢复
```
# 禁用特定用户的二步验证(无法访问身份验证器应用程序)
sudo vim /etc/ssh/sshd_config
ChallengeResponseAuthentication no
# 编辑pam配置文件，去掉第一行
vim /etc/pam.d/sshd
auth required pam_google_authenticator.so  

# 重启SSH服务
$ sudo systemctl restart sshd
```
