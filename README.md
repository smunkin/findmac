# findmac
Скрипт для автоматизации поиска указанного MAC адреса в сети коммутаторов D-Link.

Проверялось на моделях: 
DES-3200-10
DES-3200-18
DES-3200-26
DES-3200-28
DES-3200-28F
DES-3010G
DES-3016
DES-3026
DES-3526
 
Для корректной работы необходимо создать файл ip.txt в папке скрипта с перечисленными ip адресами коммутаторов.
Пример ip.txt:
192.168.0.1
192.168.0.2
192.168.0.31
...

Тк же, вам нужно указать в скрипте название вашего SNMP-community. 
community="public"

Принип работы:
В меню выбираете Network, к которому привязан определенный файл с IP адресами (то есть в какой сети искать MAC). 
Далее у пользователя запрашивается интересующий MAC адрес. Скрипт понимает форматы заглавных, строчных букв. В качестве разделителя можно использовать "-" или ":"
Скрипт по SNMP делает запрос на коммутатор и считывает таблицу MAC адресов. Если будут найдены совпадения, то скрипт выведет IP и SNMP-name коммутатора (если таковое указано в настройках). 

Зависимости:
У вас должен быть установлен пакет:
- snmpwalk
- pv
