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
....
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

Тема: Способы управления ресурсами GCP
Выполненные работы:
1) Вручную создана VM reddit-app
2) Установка ruby на reddit-app
3) Установка MongoDB на reddit-app
4) Сборка приложения из Git
5) Создание правила для фаервола для puma-server
6) Создаем скрипты для автоматизации процесса: install_ruby.sh, install_mongodb.sh, deploy.sh
7) Создание единого скрипта запуска startup.sh
8) Создание storage в GCP cloud-testapp и заливка туда startup.sh (gs://cloud-testapp/startup.sh)
9) Создание VM с помошью gcloud shell
10) Создание Firewall Rule c помощью gcloud shell

Задания:

1) Создание VM: gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --zone=europe-west1-d --machine-type=g1-small --tags puma-server --metadata startup-script-url=gs://cloud-testapp/startup.sh --restart-on-failure

2) Создание firewall-rule: gcloud compute --project=infra-244205 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server

testapp_IP = 34.77.161.51
testapp_port = 9292
