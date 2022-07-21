# expect 

## 使用expect实现无交互操作

## 安装
```
yum -y install expect

```

**1 使用expect创建脚本的方法**

```
#!/usr/bin/expect
```
**2 set timeout 30
设置超时时间 单位秒 set timeout -1 永不超时**

**3 spawn  
spawn 是进入到expect后才有的命令，直接在linux里执行是没有这个命令的。作用：传递交互指令**

**4 expect   
expect 是进入到expect后才有的命令。（一共有两个expect 一个是系统下的expect一个是进入到expect环境后的expect）作用：判断输出结果是否包含某项字符串，没有则立即返回，否则就等待一段时间后返回，等待时间通过timeout进行设置**

**5 send
执行交互动作，将交互要执行的动作进行输入给交互指令，命令字符串结尾要加上“\r” 如果出现异常等待的状态可以进行核查。**

**6 interact 
执行完后保持交互状态，把控制权交给控制台
如果不加这一项，交互完成会自动退出**

**7 exp_continue
继续执行接下来的交互操作**

**8 $argv expect 脚本可以接受从bash传递过来的参数，可以使用[lindex $argv n]获得，n从0开始，分别表示第一个，第二个，第三个.......参数**

## 测试无交互式ssh链接


```
cat <<EOF>> ssh.exp
#!/usr/bin/expect
set ipaddress "10.121.141.113"
set passwd "public"
set timeout 30

spawn ssh root@$ipaddress
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
interact
EOF
```
## 测试无交互式ssh链接 使用占位符
```
cat <<EOF>> ssh2.exp
#!/usr/bin/expect
set ipaddress [ lindex $argv 0 ]
set user [ lindex $argv 1 ]
set passwd [ lindex $argv 2 ]
set timeout 30

spawn ssh $user@$ipaddress
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
interact
```
## 执行
```
expect ssh2.exp 10.121.141.113 root public
```


## 测试无交互式scp并且执行脚本
```
cat <<EOF>> sh.sh
#!/bin/bash
for i in $(seq 0 5); do touch $i; done
EOF
```
```
cat <<EOF>> scp.exp
#!/usr/bin/expect
set ipaddress "10.121.141.113"
set passwd "public"
set timeout 30


spawn scp /root/sh.sh root@$ipaddress:/root
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}

spawn ssh root@$ipaddress
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
expect "*#"
send "chmod +x sh.sh\r"
send "bash sh.sh\r"

interact
EOF

```
## 测试无交互式scp 使用占位符
```
cat <<EOF>> scp.exp
#!/usr/bin/expect
set ipaddress [ lindex $argv 0 ]
set user [ lindex $argv 1 ]
set passwd [ lindex $argv 2 ]
set timeout 30


spawn scp /root/sh.sh $user@$ipaddress:/root
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}

spawn ssh $user@$ipaddress
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
expect "*#"
send "chmod +x sh.sh\r"
send "bash sh.sh\r"

interact
EOF
```
## 执行
```
expect scp.exp 10.121.141.113 root public
```
## for循环调用expect
```
#!/bin/bash
for i in {113..114}
do

        expect <<EOF
        set timeout 10
        spawn ssh root@10.121.141.$i
        expect {
          "yes/no" { send "yes\r";exp_continue }
          "password:" { send "$1\r" }
        }

        expect "#" {send  "touch 123.txt\r"}
        expect "#" {send  "exit\r"}
EOF
done
```
## 执行
```
bash touch.sh public
```
## 创建用户
```
#!/bin/bash 
ip=$1
user=$2
password=$3
    expect <<EOF  
    set timeout 10 
    spawn ssh $user@$ip 
    expect { 
        "yes/no" { send "yes\n";exp_continue } 
        "password" { send "$password\n" }
    } 
    expect "]#" { send "useradd hehe\n" } 
    expect "]#" { send "echo rrr|passwd --stdin hehe\n" }
    expect "]#" { send "exit\n" } 
EOF  
```
## 执行
```
bash useradd.sh 10.121.141.113 root public
```
## 拷贝公钥
```
#!/bin/bash
if [ $UID -ne 0 ]; then
        echo "请使用root用户执行此脚本"
fi
  
which expect
if [ $? -ne 0 ]; then
        yum -y install expect
fi


ls ~/.ssh/ | grep id
if [ $? -ne 0 ];then
        #创建公钥 -P:密码为空 -f：指定公钥位置（实现无交互创建公钥）
        ssh-keygen -P "" -f ~/.ssh/id_rsa
fi




read -p "请输入你远程连接主机的密码(默认密码是public)：" password
if [ ! -z $password ]; then
        password=$password
else
        password=public
fi
read -p "请输入你想远程连接主机网段(默认网段是10.121.141)：(例：10.121.141)" wd
if [ ! -z $wd ]; then
        wd=$wd
else
        wd="10.121.141"
fi
##判断主机是否在线
for i in {113..114}
do
        {
                ip=$wd.$i
                ping -c1 -W1 $ip &> /dev/null
                if [ $? -eq 0 ];then
                        echo "$ip" >> online.txt
                #调用expect
                        /usr/bin/expect <<-EOF
                        spawn ssh-copy-id $ip
                        expect {
                                "*yes/no*" { send "yes\r"; exp_continue }
                                "*password:" { send "$password\r" }
                        }
                        expect eof
                        EOF
                fi
        }
done

```
## 根据指定的文件内容在对应的服务器上创建文件
```
10.121.141.113 public
10.121.141.110 passw0rd
```
```
#!/bin/bash
# 循环在指定的服务器上创建用户和文件
while read ip pass
do
        /usr/bin/expect <<-EOF &>/dev/null
        set timeout 5
        spawn ssh root@$ip
        expect { 
        "yes/no" { send "yes\r";exp_continue }
        "password:" { send "$pass\r" }
        }
        expect "#" { send "touch 999.txt\r" }
        expect eof
        EOF
echo "$ip文件创建完成"
done < ip.txt

```

参考链接：  
http://xstarcd.github.io/wiki/shell/expect.html




