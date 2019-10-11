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

