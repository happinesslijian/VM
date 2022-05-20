# mailx
```
vim /etc/mail.rc
```
> 添加如下配置:
>>说明：smtp-auth-password使用POP3/SMTP服务的授权码 如图![微信截图_20220520123124.png](https://s2.loli.net/2022/05/20/58DBbSjsTRghp1u.png)
```
set from=1319xxxxxx@qq.com
set smtp=smtp.qq.com
set smtp-auth-user=1319xxxxxx@qq.com
set smtp-auth-password=hzpcortncbrujbjh
set smtp-auth=login
```
验证： 
```
echo "机房巡检通知" | mailx -s "机房巡检通知" 151xxxxxxxx@163.com
```
