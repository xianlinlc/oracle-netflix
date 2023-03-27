# oracle-netflix
本脚本功能：

1.检测Oracle Cloud实例是否解锁Netflix非自制剧

2.如不解锁自动更换实例ip并ddns到cloudflare

3.使用tg机器人推送信息

注意事项：

1.需要海外两台服务器，服务器A运行脚本，服务器B提供解锁服务和代理

2.服务器A需配置oci环境，参考 https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

3.脚本运行间隔最好不要低于5分钟，否则可能会出现错误

使用方法：

1.脚本运行依赖jq，请安装jq

`sudo apt install jq`

2.在脚本中填写配置信息

```instance_id="实例的ocid"

CONFIG_FILE='oci配置文件，默认为/root/.oci/config，请自行设置填写'

BOT_TOKEN="tg机器人的api_token"

CHAT_ID="tg CHAT_ID"

ZONE_ID="域名的Zone ID"

API_KEY="cloudflareAPIkey"

CF_EMAIL="cloudflare注册邮箱"

DOMAIN="域名，此处填写完整域名"

curl -x "此处填写服务器B的代理"(curl -x的用法请自行google)
```

3.使用crontab设置定时任务，如(请根据需求自行设置)

```
*/5 * * * * /bin/bash /root/netflix.sh

0 0 * * *  echo "" > /root/netflix_ip_not_change.log

0 0 0 * *  echo "" > /root/netflix_ip_change.log
```
