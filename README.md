# oracle-netflix
本脚本功能：

1.检测Oracle Cloud实例是否解锁Netflix非自制剧

2.如不解锁自动更换实例ip并ddns到cloudflare

3.使用tg机器人推送信息

注意事项：

1.需要海外两台服务器，服务器A运行脚本，服务器B提供解锁服务和代理

2.服务器A需配置好oci环境，请参考 https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

3.脚本运行间隔最好不要低于5分钟，否则可能会出现错误

使用方法：


