[![Build Status](https://travis-ci.com/Otus-DevOps-2020-02/Tyatyushkin_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-02/Tyatyushkin_infra)
# Tyatyushkin_infra
Tyatyushkin Infra repository

---
## Ansible-4

#### Выполненные работы

1. Установка **vagrant**
2. Описываем локальную инфраструктуру в **Vagrantfile**
3. Дорабатываем роли и учимся использовать *provisioner*
3. Переделываем *deploy.yml*
4. Проверяем сборку в vagrant
5. Устанавливаем **pip**, а затем с помощью его **virtualenv**
6. Устанавливаем все необходимые пакеты *pip install -r requirements.txt*
7. Создаем заготовку molecule с помощью команды *molecule init scenario --scenario-name default -r db -d vagrant*
8. Добавляем собственнные тесты
9. Собираем и тестируем нашу конфигурацию

#### Самостоятельные задания:
1. Пишем тест для проверки доступности порта 27017:
```
# check 27017 port
def test_mongo_port(host):
    socket = host.socket('tcp://0.0.0.0:27017')
    assert socket.is_listening
```
2. Используем роли db и app в packer_db.yml
```
 "type": "ansible",
 "playbook_file": "ansible/playbooks/packer_db.yml",
 "extra_arguments": ["--tags","install"],
 "ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]
```
 и packer_app.yml
 ```
 "type": "ansible",
 "playbook_file": "ansible/playbooks/packer_app.yml",
 "extra_arguments": ["--tags","ruby"],
 "ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]
 ```

 #### Задания со ⭐

 1. Для работы nginx нам необходимо внести изменения в **Vagrantfile**
 ```
  ansible.extra_vars = {
    deploy_user" => "vagrant",
    nginx_sites: {
      default: ["listen 80", "server_name 'reddit'", "location / {proxy_pass http://127.0.0.1:9292;}"]
    }
  }
 ```

 2. Создаем отдельный репозиторий [repo](https://github.com/Tyatyushkin/otus_db)
 3. Создаем шаблон с помощью *ansible-galaxy*
 4. Правим **requirements.yml** в обоих окружениях
 ```
 - src: jdauphant.nginx
  version: v2.21.1
# DB from github
- name: db
  src: https://github.com/tyatyushkin/otus_db
```
5. Копируем роль в отдельный репозиторий
6. Удаляем роль db из исходного репозитория и добавляем с помощью *ansible-galaxy install -r environments/stage/requirements.yml*
7. Добавляем в travis наш репозиторий и создаем .travis.yml
8. Создаем в нашем новом репозитории шаблон для молекулы используя driver gce *molecule init scenario --scenario-name default -r db -d gce*
9. Разбираемся с креденшиалами
10. Переделываем **molecule.yml**  под наши нужды:
```
platforms:
  - name: instance-travis
    zone: europe-west1-b
    machine_type: f1-micro
    image: ubuntu-1604-xenial-v20170919
```
11. Модифицируем .travis.yml
```
language: python
python:
- '2.7'
install:
- pip install ansible==2.3.0 molecule==2.14 apache-libcloud Jinja2==2.10 PyYAML==3.12
env:
  matrix:
  - GCE_CREDENTIALS_FILE="$(pwd)/credentials.json"
  global:
 .....
script:
- molecule create
- molecule converge
- molecule verify
after_script:
- molecule destroy
before_install:
- openssl aes-256-cbc -K $encrypted_3b9f0b9d36d1_key -iv $encrypted_3b9f0b9d36d1_iv
  -in secrets.tar.enc -out secrets.tar -d
- tar xvf secrets.tar
- mv google_compute_engine /home/travis/.ssh/
- chmod 0600 /home/travis/.ssh/google_compute_engine
```

12. Добавляем оповещения в slack
```
notifications:
  slack: devops-team-otus:OQW5TMOgNIemU6RvI9YkzKYc
```
13. Добавляем статус билда в REAME.md
---
## Ansible-3

#### Выполненные работы:

1. Создаем ветку *ansible-3*
2. Создаем шаблоны ролей *app* и *db* с помощью *ansible-galaxy init*
3. Переносим плейбуки в созаднные роли
4. Создаем окружения *stage* и *prod*
5. Конфигирируем переменные в group_vars
6. Организуем файлы в папке ansible
7. Добавляем community роль *jdauphant.nginx* с помощью ansible-galaxy
8. Настраиваем Ansible для работы с vault


#### Задание со ⭐
1. Для того чтобы разделять окружения правим конфиги terraform добавляем labels
```
  labels = {
    env = var.labels
  }
```
и добавляем в эту метку в наших переменных
```
labels = "stage"
```
теперь у нас при создании через терраформ к каждому окружению привязана метка

2. Настраиваем динамическое инвентори для наших сред и правим ansible.cfg
```
[defaults]
inventory = ./environments/stage/stage.gcp.yml
```
и вносим изменения для наших inventory добавляя фильтр для **label**
```
filters:
  - labels.env = stage
```

3. Так же добавим в environments *host_vars* куда перенесем переменные, чтобы они использовались в плейбуках
```
reddit-app
reddit-dp
```
4. Проверяем работу
```
ansible -m ping all
reddit-db | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
reddit-app | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```
теперь проверяем prod окружение
```
ansible -i environments/prod/prod.gcp.yml all -m ping
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
```

#### Задание со ⭐⭐
1. Правим .travis.yml добавляя строки после проверок ОТУС
```
#Устанавливаем ansible и ansible-lint
- curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
- sudo python get-pip.py
- sudo pip install ansible
- sudo pip install ansible-lint
#Устанавливаем Terraform и tflint
- sudo apt-get install unzip
- wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
- sudo unzip terraform_0.12.18_linux_amd64.zip -d /usr/local/bin
- curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && rm tflint.zip
- sudo mv tflint /usr/local/bin
#Проверяем версии
- tflint -v
- terraform --version
- packer --version
- ansible-lint --version
#Проверяем шаблоны packer
- packer validate -var-file=packer/variables.json.example packer/app.json
- packer validate -var-file=packer/variables.json.example packer/db.json
- cd packer
- packer validate -var-file=variables.json.example ubuntu16.json
- packer validate -var-file=variables.json.example immutable.json
#Проверяем конфиги terraform
- cd ../terraform/stage && mv backend.tf backend.tf.example && terraform init && terraform validate
- tflint
- cd ../prod && mv backend.tf backend.tf.example && terraform init && terraform validate
- tflint
#Проверяем плейбуки ansible
- cd ../../ansible && ansible-lint playbooks/deploy.yml
- ansible-lint playbooks/clone.yml
- ansible-lint playbooks/db.yml
- ansible-lint playbooks/packer_app.yml
- ansible-lint playbooks/packer_db.yml
- ansible-lint playbooks/reddit_app_one_play.yml
- ansible-lint playbooks/reddit_app_multiple_plays.yml
- ansible-lint playbooks/users.yml
- ansible-galaxy install -r environments/stage/requirements.yml
- ansible-lint playbooks/app.yml --exclude=roles/jdauphant.nginx
- ansible-lint playbooks/site.yml --exclude=roles/jdauphant.nginx
```
2. Добавлен build status от трависа в начало README.md

---

## Ansible-2

#### Выполненные работы:

1. Пишем плейбук reddit_app.yml
2. Создаем плейбук с несколькими сценариями reddit_app2.yml
3. Разбиваем плейбук по ролям на **db.yml**, **app.yml** и **deploy.yml**
4. Создаем **site.yml** для запуска сценариев
5. Создаем сценарии для packer - **packer_app** и **packer_db**

##### Задание со звездочкой:
1. Правим **ansible.cfg** для использования динамического инвентори
```
[defaults]
inventory = ./inv.gcp.yml
...
[inventory]
enable_plugins = gcp_compute
```
2. Изменяем hosts во всех плейбуках, теперь не нужно в ручную менять адреса в инвентори так как мы используем динамический
```
hosts: reddit_db
...
hosts: reddit_app
```
3. Чтобы избавиться от ручного изменения в перенной указывающей адресс сервера дб, добавляем код в **db.yml**
```
    - name: add ip
      shell: "echo 'db: {{ansible_host}}' > /home/masterplan/var"

    - name: Specifying a path directly
      fetch:
        src: /home/masterplan/var
        dest: var
        flat: yes
```
4. Меняем **app.yml** для работы с новой переменной
```
  vars_files:
    - var
```
5. Запускаем *ansible-playbook site.yml*
---

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
