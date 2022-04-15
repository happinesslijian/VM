#!/bin/bash

# 统计当前 Linux 系统中可以登录计算机的账户有多少个
#方法 1:
grep "bash$" /etc/passwd | wc -l
#方法 2：
awk -f : '/bash$/{x++}end{print x}' /etc/passwd
