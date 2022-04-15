#!/bin/bash
#通过ping来判断网络中哪些是开机，哪些是关机
for i in {1..254}
do 
ping -c 2 -i 0.5 -W 1 10.121.141.$i &> /dev/null
	if [ $? -eq 0 ]; then
		echo "10.121.141.$i is up" >> 1.txt
	else 
		echo "10.121.141.$i is down" >> 1.txt
	fi
done
