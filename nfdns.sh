#!/bin/bash





compartmentId=$(oci iam user list  | jq -r '.[][0]."compartment-id"')
CONFIG_FILE='/root/.oci/config'

readonly compartmentId
readonly CONFIG_FILE

function main {
	local result=$(  curl  -x http://nfdns.lc950818.top:50528 -U UOszYQCC1E:iUPdQUqOVm   --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" -fsL --write-out %{http_code} --output /dev/null  "https://www.netflix.com/title/80000603" 2>&1)
	if  [ "$result" == "404" ]
	then
	changeip
    elif [ "$result" == "200" ]; then
    ip=$(report_ip)
	echo "$(date +%Y-%m-%d" "%H:%M:%S) 无需更换" >> /root/netflix_ip_not_change.log
	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=-1001856649516&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S)现在的ip地址是$ip，可以解锁Netflix自制剧"
	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=5403459769&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S)现在的ip地址是$ip，可以解锁Netflix自制剧"
	return
    fi
}

function changeip {
				local instance_id=$(echo "ocid1.instance.oc1.ap-singapore-1.anzwsljr6vnubsacahlmrneg7b3wnkjveu67pg336pqslzczar7wiqszql4a")
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
				curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=-1001856649516&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) 原ip：$public_ip,现ip：$new_public_ip"
	
				curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=5403459769&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) 原ip：$public_ip,现ip：$new_public_ip"
				sleep 10
			#ddns
				ddns
				main
				return

}

function ddns {

			local instance_id=$(echo "ocid1.instance.oc1.ap-singapore-1.anzwsljr6vnubsacahlmrneg7b3wnkjveu67pg336pqslzczar7wiqszql4a")
	   		local new_ip=$(oci compute instance list-vnics --instance-id $instance_id --config-file $CONFIG_FILE | jq -r '.[][]."public-ip"')


	   	curl -k -X PUT "https://api.cloudflare.com/client/v4/zones/91cff2018be855393fb5a7acd8b80dbe/dns_records/b3af5fa88920189f9ef785c6f1b53ad2" \
         -H "X-Auth-Email:avicii950818@gmail.com" \
         -H "X-Auth-Key:3ff6065b6a333f93a48df57173a29a413dd72" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"nfdns","content":"'$new_ip'","ttl":120,"proxied":false}'

         sleep 10

    	 local  response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/91cff2018be855393fb5a7acd8b80dbe/dns_records?type=A&name=nfdns.lc950818.top" \
    	 -H "X-Auth-Key: 3ff6065b6a333f93a48df57173a29a413dd72" \
    	 -H "X-Auth-Email: avicii950818@gmail.com "\
    	 -H "Content-Type: application/json")

         local ip_address=$(echo $response | jq -r '.result[0].content')

         if [ "$ip_address"=="$new_ip" ]; then
         	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=-1001856649516&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns成功，ip地址为$ip_address"
         	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=5403459769&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns成功，ip地址为$ip_address"
         	
         
         else
         	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=-1001856649516&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns未成功，ip地址为$ip_address"
         	curl -X POST "https://api.telegram.org/bot6146314523:AAGQhbsWthN0fI-3-Ro5acRqSIJaxp8aI3w/sendMessage" -d "chat_id=5403459769&text=$(TZ=Asia/Shanghai date +%Y-%m-%d" "%H:%M:%S) ddns未成功，ip地址为$ip_address"
         
         fi
}

function report_ip {
		local  response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/91cff2018be855393fb5a7acd8b80dbe/dns_records?type=A&name=nfdns.lc950818.top" \
    	 -H "X-Auth-Key: 3ff6065b6a333f93a48df57173a29a413dd72" \
    	 -H "X-Auth-Email: avicii950818@gmail.com "\
    	 -H "Content-Type: application/json")

        local ip_address=$(echo $response | jq -r '.result[0].content')
        echo "$ip_address"
}

main
