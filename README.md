# Tyatyushkin_infra
Tyatyushkin Infra repository

Тема: Знакомство с облачной инфраструктурой

Выполненные работы:
1) Произведена Регистрация в GCP
2) Создана VM bastion
3) Создана VM someinsterlnalhost
4) Настроен проброс ключа в ssh_config
5) Конфиграция ssh_config для подключение к someinternalhost
6) установка vpn сервера из скрипта setupvpn.sh
7) Конфигурация пользователя, организации и сервера для подключение к VPN
8) Подписание сертификатов с помошью Lets Encrypt
9) Проверка подключений

Задания:
1) Подключение к someinternalhost одной коммандой: ssh -A -t appuser@bastion  ssh someinternalhost

2) Подключение к someinternalhost с помощью alias:
Вносятся изменения в ssh-config
...
Host someinternalhost
  ForwardAgent yes
  Hostname InternalIP
  User appuser
  ProxyCommand ssh bastionIP -W %h:%p
....
и теперь можно подключаться ssh someinternalhost

3) Подключение с помощью VPN:

 bastion_IP = 35.240.123.149
 someinternalhost_IP = 10.132.15.207
