## 编译telegram-cli

**说明** telegram-cli需要科学上网,先解决科学上网的问题然后在执行脚本！否则编译出来也没办法使用！  
示例：我这里使用Trojan配合privoxy进行科学上网。  
**环境:** centos7
```
# 编译安装telegram-cli
sh install-tg.sh
```
安装好后，我们需要去拿到 telegram 的密钥。访问 telegram 的网站  
https://my.telegram.org/apps

**注意：一定要写上 +86 134xxxxxxx  验证码会发送到telegram里而不是手机短信**  
![微信截图_20210122000029.png](https://i.loli.net/2021/01/22/ZamMSc6JilAW7eP.png)
![微信截图_20210122000107.png](https://i.loli.net/2021/01/22/q5IcfNUZXgOsne2.png)  
我选择创建的application种类为app(这里填什么都行 )  
将 Public keys 复制，回到服务器端。将复制的密钥保存到 tg-server.pub 文件中
```
# 安装Trojan和privoxy
sh trojan.sh
```
**注意：如果重启了Trojan或privoxy服务需要重新执行如下**
```
export https_proxy=http://127.0.0.1:8118 \
http_proxy=http://127.0.0.1:8118 \
all_proxy=socks5://127.0.0.1:1080
```
```
# docker 运行
docker run -it --rm -v /root/.telegram-cli:/home/user/.telegram-cli frankwolf/telegram-cli
```

**参考文档**  
https://github.com/vysheng/tg  
https://www.91yun.co/archives/5691  
https://hub.docker.com/r/frankwolf/telegram-cli  
