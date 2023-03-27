#!/bin/bash


instance_id="实例的ocid"
compartmentId=$(oci iam user list  | jq -r '.[][0]."compartment-id"')
CONFIG_FILE='/root/.oci/config'
BOT_TOKEN="tg机器人的api_token"
CHAT_ID="CHAT_ID"
ZONE_ID="域名的Zone ID"
API_KEY="cloudflareAPIkey"
CF_EMAIL="cloudflare注册邮箱"
DOMAIN="域名"


readonly compartmentId
readonly CONFIG_FILE
readonly BOT_TOKEN
readonly CHAT_ID
readonly instance_id

function main {
	local result=$(  curl  -x "此处填写服务器B的代理"  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" -fsL --write-out %{http_code} --output /dev/null  "https://www.netflix.com/title/80000603" 2>&1)

	if  [ "$result" == "404" ]

	then

	changeip

    elif [ "$result" == "200" ]; then

	echo "$(date +%Y-%m-%d" "%H:%M:%S) 无需更换" >> /root/netflix_ip_not_change.log

	#给tg bot发信息
	curl -X POST "https://api.telegram.org/"$BOT_TOKEN"/sendMessage" -d "CHAT_ID="$CHAT_ID"&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S)已检测，无需更换🥹"

	return

	else

	#给tg bot发信息
	curl -X POST "https://api.telegram.org/"$BOT_TOKEN"/sendMessage" -d "CHAT_ID="$CHAT_ID"&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S)好像出现了点问题，HTTP状态码是"$result""

	main

    fi
}


function changeip {

			#获取公共ip地址
				local public_ip=$(oci compute instance list-vnics --instance-id $instance_id --config-file $CONFIG_FILE | jq -r '.[][]."public-ip"')



			#获取公共ip ID
				local json=$(oci network public-ip get --public-ip-address $public_ip --config-file $CONFIG_FILE)
				local publicipId=$(echo $json | jq -r '.data.id')



			#获取私有ip ID
				local privateipId=$(echo $json | jq -r '.data."private-ip-id"')		


			#删除原公共ip
				oci network public-ip delete --public-ip-id $publicipId --force --config-file $CONFIG_FILE	

			#新建公共ip
				oci network public-ip create -c $compartmentId --private-ip-id $privateipId --lifetime EPHEMERAL --config-file $CONFIG_FILE

				sleep 10
			#获取当前新ip		
				local new_public_ip=$(oci compute instance list-vnics --instance-id $instance_id --config-file $CONFIG_FILE | jq -r '.[][]."public-ip"')
			#记录日志	
				echo "$(date +%Y-%m-%d" "%H:%M:%S) 原ip：$public_ip,现ip：$new_public_ip" >> /root/netflix_ip_change.log

				sleep 10

			#给tg bot发信息	
			curl -X POST "https://api.telegram.org/"$BOT_TOKEN"/sendMessage" -d "CHAT_ID="$CHAT_ID"&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S)好像出现了点问题，HTTP状态码是"$result""
				
	
			sleep 10
			#ddns

			ddns

			main

			return

}



function ddns {

		#获取当前新ip
	   	local new_public_ip=$(oci compute instance list-vnics --instance-id $instance_id --config-file $CONFIG_FILE | jq -r '.[][]."public-ip"')


	   	local RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" \
		-H "X-Auth-Key: $API_KEY" \
		-H "X-Auth-Email: $CF_EMAIL" \
		-H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

	   	sleep10
	   	
	   	#ddns
	   	curl -k -X PUT "https://api.cloudflare.com/client/v4/zones/91cff2018be855393fb5a7acd8b80dbe/dns_records/"$RECORD_ID"" \
         -H "X-Auth-Email:$CF_EMAIL" \
         -H "X-Auth-Key:$API_KEY" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"nfdns","content":"'$new_public_ip'","ttl":120,"proxied":false}'

         sleep 10
        #获取域名dns记录
    	 local  response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" \
    	 -H "X-Auth-Key: $API_KEY" \
    	 -H "X-Auth-Email: $CF_EMAIL "\
    	 -H "Content-Type: application/json")

         local ip_address=$(echo $response | jq -r '.result[0].content')
         #ddns是否成功
         if [ "$ip_address"=="$new_public_ip" ]; then
         	curl -X POST "https://api.telegram.org/$BOT_TOKEN/sendMessage" -d "CHAT_ID=$CHAT_ID&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns成功，ip地址为"$ip_address""

         	return
         
         else
         	curl -X POST "https://api.telegram.org/$BOT_TOKEN/sendMessage" -d "CHAT_ID=$CHAT_ID&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns未成功，ip地址为"$ip_address""

         	ddns
         fi
}
