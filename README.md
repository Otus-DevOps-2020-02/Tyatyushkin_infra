# Tyatyushkin_infra
Tyatyushkin Infra repository

Teма: Знакомство с ansible

Выполненные работы:
1) Устанавливаем Ansible с помощью команды 'brew install ansible'
2) Формируем inventory файл
3) Учимся использовать модули, например ping
4) создаем конфиг ansible.cfg
5) Учимся работать с группами и инвентори в формате yml
6) Написание и выполнение простого playbook

Задание со *
1) Использование динамиеческого инвентори с помощью gcp_compute модуля
  a) созадние файла inv.gcp.yml
  б) правим ansible.cfg
  inventory = ./inv.gcp.yml
  [inventory]
   enable_plugins = gcp_compute
  в) формируем inventory.json 'ansible-inventory --list -i inv.gcp.yml > inventory.json'
  г) проверяем работу ansible all -m ping


Тема: Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform

Выполненные работы:
1) Импортируем текущую инфрастуктуру в Terraform(правила фаервола)
2) Проверяем работу зависимостей
3) Структурируем ресурсы разбивая конфигурацию на файлы
4) Создаем модули и строим на них инфрастуктуру
5) Создаем stage и prod  и настраиваем их с использованием модулей
6) Работаем с реестром модулей, устанавлимаем модуль для Баккета

Задания:
1) Переносим стейт на удаленный бэкэнд с файлом backend.ts
2) Проверяем работы блокировок и уделенного стейта
3) Настраиваем провиженеры для разворачивания приложения используя terraform template


Тема: Практика IAC с использованием Terraform

Выволненные работы:
1) Создаем новую ветку и скачиваем terraform из репозитория
2) Создаем каталог Terraform, а так же пустой файл main.tf и вносим исключения в .gitignore
3) Иницилизируем каталог с терраформом командой terraform init
4) Заполняем конфигурационный файл main.tf
5) Планируем измнением terraform plan и вносим terraform apply
6) Добавляем ssh ключ
7) Настраиваем файл вывода outputs.tf
8) Создаем правило фаервола для доступа к приложению
9) Добавляем provisioners для сборки образа и вносим применяем измненеия
10) Создаем файл с переменными variables.tf и пересоздаем проект для проверки.

Задания:
1) Создаем переменную для приватного ключа в variables.tf:
	variable private_key_path {
  description = "Private key path"
  }
  Указываем данные для приватного ключа в terraform.tfvars
  private_key_path = "/path/to/private_key"
  И указываем переменную в main.tf
  private_key = "${file(var.private_key_path)}"
2) Создаем переменную для зоны со значением по умолчанию в variables.tf
  variable zone {
  description = "Zone"
  default     = "europe-west1-b"
  }
  и тоже указываем ее в main.tf
3) Запуск terraform fmt
4) Создание файла terraform.tfvars.example

5) C помощью ресурса метадата создаем 2 ключа для проекта
	resource "google_compute_project_metadata_item" "default" {
  		key   = "ssh-keys"
  		value = "appuser:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}"
	}
Так же был добавлен ключ в appuser_web, но он был удален после команды terraform apply

6) Для создания lb был создан файл lb.tf где были описаны инструкции по созданию с использованием различных ресурсов.
 Созадн второй экземпляр vm reddit-app и отключен puma.service на первом, балансировщик отработал успешно.
 Настроены выводы 3 ip адресов в output.tf
 Удаляем записи о второй машине и настраивам счетчик с дефолтным значением  1 с помощью count
 После этого приходится изменять файл конфигурации lb.tf outputs.tf и main.tf для корректной работы и вывода.



Тема: Работа с packer

Выполнение работы:
1) Установка Packer из репозитория
2) Создаем шаблон ubuntu16.json
3) Собираем и проверяем собранный образ
4) Деплоим приложение
5) Создание образа immutable.json
6) Сощдание скрипта для запуска create-reddit-vm.sh

Задания:
1) При создании immutable.json был использован systemd скрипты взятый с репозитория puma, который помещен в каталог files.
2) Для создания скрипта была использована уталита из скоплсекта gcp, в параметрах которой используется наш образ reddit-full для создания vm.



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
