#!/usr/bin/env bash

# FindMAC noGUI

# vars
RED='\033[32m'
BLACK='\033[0m'
GREEN='\033[0;32m'

pgrep snmpwalk && (echo -e "$REDДругой экземпляр snmpwalk в данный момент запущен. Завершение работы.$BLACK";exit)

export DISPLAY=:0.0
clear

# Logo
cat <<EOF | pv -qL 200

  __                  
 |_  o __  _|__  _  _ 
 |   | | |(_||||(_|(_ 
			
 
 +------------+
 | 1 Network1 |
 | 2 Network2 |
 | 3 Network3 |
 | * Exit     |
 +------------+

EOF

# Выбираем подсеть
read -p "Choose network: " choice
case $choice in
1) ipfile="ip.txt" ;;
2) ipfile="ip_net1.txt" ;;
3) ipfile="ip_net2.txt" ;;
*) exit 0 ;;
esac

# проверка наличия файла
if [ -s $ipfile ]; then
	echo "file found">/dev/null
else
	echo "File $ipfile not found! Exiting."
	exit
fi

# удаляем старые файлы
[ -f temp.txt ] && rm -r temp.txt
[ -f macfound.txt ] && rm -r macfound.txt

# SNMP community
community="public"

# запрашиваем у пользователя MAC адрес для поиска
read -p "Enter MAC address: " input

# преобразуем MAC адрес в формат 00:00:00:00:00:00
mac=$(echo $input | tr '[:lower:]' '[:upper:]' | tr '-' ':')

# считываем ip адреса коммутаторов из файла ip.txt
cat $ipfile | while read ip; do

if [ "$ip" = "#" ]; then
	break
fi

# счетчик IP адресов в файле $ipfile
let INDEX=$INDEX+1
allindex=$(cat $ipfile | wc -l)

# проверяем доступность хоста
ping -q -c1 $ip> /dev/null	# Если у вас Windows (MobaXterm) закомментируйте эту строку
        if [ $? -eq 0 ]; then	# Если у вас Windows (MobaXterm) закомментируйте эту строку
			# если хост доступен то
			# читаем таблицу MAC адресов с коммутатора, переводим в удобный формат и записываем в файл temp.txt
			echo -e "$INDEX/$allindex\t [ Search ]\t $ip"
			snmpwalk -v 2c -c $community  $ip 1.3.6.1.2.1.17.7.1.2.2.1.2 | awk -Wposix -F. '{printf "%.2X:%.2X:%.2X:%.2X:%.2X:%.2X\n",$15,$16,$17,$18,$19,$20}' 1>temp.txt 2>/dev/null
		
			cat temp.txt | while read out; do
			# сравниваем содержимое файла temp.txt с переменной $input
			if [ "$mac" = "$out" ];then 
				# если MAC адрес в переменной $input равен содержимому какой либо строки в файле temp.txt
				# запрашиваем snmp system name коммутатора
				name=$(snmpwalk -v 2c -c $community $ip .1.3.6.1.2.1.1.5.0 | awk {'print $4'})
				# выдаем результат поиска 
				echo -e "$INDEX/$allindex\t $GREEN[ Found ]$BLACK\t $ip\t $name" 
				echo "MAC address $mac found on $ip $name">>macfound.txt
			fi
			done
		else	# Если у вас Windows (MobaXterm) закомментируйте эту строку
			# если хост недоступен выводим сообщение
			echo -e "$INDEX/$allindex\t $RED[ Unreach ]$BLACK\t $ip\t skipping";	# Если у вас Windows (MobaXterm) закомментируйте эту строку
		fi	# Если у вас Windows (MobaXterm) закомментируйте эту строку
done
echo -e "[ Complete ] script\n\n";
[ -f macfound.txt ] && cat macfound.txt || echo -e "$RED[ Search ]$BLACK\t $mac\t not found!"

[ -f temp.txt ] && rm -r temp.txt
[ -f macfound.txt ] && rm -r macfound.txt

