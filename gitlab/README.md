# 安装gitlab
**注意： 内存要求推荐4G以上，最低2G，不然容易各种原因报502错误**
- 主程序
```
wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ee/packages/sles/12.2/gitlab-ee-12.3.1-ee.0.sles12.x86_64.rpm/download.rpm

rpm -ivh gitlab-ee-12.3.1-ee.0.sles12.x86_64.rpm
```
[如图所示](https://i.loli.net/2019/09/28/K1ktvVw26AuCpYO.png)
- 安装依赖ruby2.0
```
yum -y install ruby
```
- 配置 /etc/gitlab/gitlab.rb设置git库路径
```
# git_data_dirs({
#   "default" => {
#     "path" => "/mnt/nfs-01/git-data"
#    }
# })
```
[如图所示](https://i.loli.net/2019/09/28/3IA5zxHYat8bpNo.png)
- 安装查看状态
```
gitlab-ctl reconfigure
gitlab-ctl (start|stop|status)
```
[如图所示](https://i.loli.net/2019/09/28/ZYpcWCtsdgbX79q.png)
- 访问gitlab 80端口，页面设置密码，用户root

[如图所示](https://i.loli.net/2019/09/28/Yh4rDWu75eCMpdS.png)