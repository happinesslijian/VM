# 安装jdk
链接：https://pan.baidu.com/s/1xY992hgBLP6e8MR1oeApeA 
提取码：xn1q
```
mkdir -p /usr/java && cd /usr/java
rpm -ivh jdk-8u191-linux-x64.rpm
# 编辑环境变量文件
vim /etc/profile
---
export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```
刷新环境变量文件并验证
```
source /etc/profile
java -version
```
# 安装tomcat
安装tomcat
```
mkdir -p /usr/tomcat && cd /usr/tomcat
wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz
tar zxvf apache-tomcat-9.0.27.tar.gz
cd /usr/tomcat/apache-tomcat-9.0.27/bin/
# 启动tomcat
./startup.sh
```
验证
```
ps -ef | grep tomcat
```
# 下载jmx_exporter
```
mkdir /usr/local/jmx && cd /usr/local/jmx
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar
vim tomcat.yml
---
lowercaseOutputLabelNames: true
lowercaseOutputName: true
rules:
- pattern: 'Catalina<type=GlobalRequestProcessor, name=\"(\w+-\w+)-(\d+)\"><>(\w+):'
  name: tomcat_$3_total
  labels:
    port: "$2"
    protocol: "$1"
  help: Tomcat global $3
  type: COUNTER
- pattern: 'Catalina<j2eeType=Servlet, WebModule=//([-a-zA-Z0-9+&@#/%?=~_|!:.,;]*[-a-zA-Z0-9+&@#/%=~_|]), name=([-a-zA-Z0-9+/$%~_-|!.]*), J2EEApplication=none, J2EEServer=none><>(requestCount|maxTime|processingTime|errorCount):'
  name: tomcat_servlet_$3_total
  labels:
    module: "$1"
    servlet: "$2"
  help: Tomcat servlet $3 total
  type: COUNTER
- pattern: 'Catalina<type=ThreadPool, name="(\w+-\w+)-(\d+)"><>(currentThreadCount|currentThreadsBusy|keepAliveCount|pollerThreadCount|connectionCount):'
  name: tomcat_threadpool_$3
  labels:
    port: "$2"
    protocol: "$1"
  help: Tomcat threadpool $3
  type: GAUGE
- pattern: 'Catalina<type=Manager, host=([-a-zA-Z0-9+&@#/%?=~_|!:.,;]*[-a-zA-Z0-9+&@#/%=~_|]), context=([-a-zA-Z0-9+/$%~_-|!.]*)><>(processingTime|sessionCounter|rejectedSessions|expiredSessions):'
  name: tomcat_session_$3_total
  labels:
    context: "$2"
    host: "$1"
  help: Tomcat session $3 total
  type: COUNTER
- pattern: ".*"  #让所有的jmx metrics全部暴露出来
```
- 启动jmx_exporter并指定端口
```
cd /usr/tomcat/apache-tomcat-9.0.27/bin
cat > setenv.sh << EOF
JAVA_OPTS="-javaagent:/usr/local/jmx/jmx_prometheus_javaagent-0.12.0.jar=38081:/usr/local/jmx/tomcat.yml"
EOF
```
重启tomcat
```
sh /usr/tomcat/apache-tomcat-9.0.27/bin/shutdown.sh
sh /usr/tomcat/apache-tomcat-9.0.27/bin/startup.sh
```
# prometheus静态监控tomcat配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: tomcat
    static_configs:
      - targets: ['192.168.100.139:38081']
        labels:
          instance: tomcat
```
# prometheus基于文件服务发现监控tomcat配置
vim /etc/prometheus/prometheus.yml
```
  - job_name: 'java'
    file_sd_configs:
      - files:
        - java/java.yaml
    metrics_path: /metrics
    relabel_configs:
    - source_labels: [__address__]
      regex: (.*)
      target_label: instance
      replacement: $1
    - source_labels: [__address__]
      regex: (.*)
      target_label: __address__
      replacement: $1
```
vim /etc/prometheus/java/java.yaml
```
- targets:
  - 192.168.100.139:38081
  labels:
    instance: tomcat-1
    group: 139项目组使用
```
grafana 模板8563
# 优化tomcat
- tomcat开机自启动
```
vim /etc/rc.local
# 可以写多条
sh /usr/tomcat/apache-tomcat-9.0.27/bin/startup.sh
```
- 分配给rc.local文件可执行权限
```
chmod +x /etc/rc.local
```