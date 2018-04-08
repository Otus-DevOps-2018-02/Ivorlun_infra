# Ivorlun_infra
Ivorlun otus infrastructure repository

[![Build Status](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra.svg?branch=master)](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra)
___
## Terraform 1

* Создан шаблон terraform для развёртки и управления конфигурацией инстанса reddit-app, а также для создания и управления правилом firewall-а. 
Шаблон параметризован и отформатирован.

#### Задание со * про ssh-keys

После развёртки инстанса он доступен по `ssh appuser@<adress> -i ~/.ssh/appuser`.

Добавление ключа только в metadata для нового пользователя appuser1 приводит к тому что terraform сообщает: обновляю текущий публичный ключ у appuser in-place, что совсем не то, к чему стремиться пользователь terraform.

На самом же деле у appuser-a удаляется файл authorized_keys(!), создаётся пользователь appuser1 и ему добавляется доступ по ключу. Инстанс перестаёт быть доступен для appuser.

Далее при добавлении новых пользователей appuser2-4 таким же образом, terraform говорит что обновит ключ пользователя appuser1 на ключ пользователя appuser4 (???). На самом деле инстанс становиться запечатан т.к. ни один пользователь не может подключиться. Пользователи 2-3 не создаются, у appuser1 так же удаляется authorized_keys, но добавляется для 4.
Тем не менее подключиться невозможно.

Пересоздание инстанса приводит к тому что создание невозможно т.к. connection user для provisioner-ов appuser, а добавляется ключ только appuser4

Судя по всему это связано с https://www.terraform.io/docs/providers/google/r/compute_project_metadata.html

где написано:
>Note: If you want to manage only single key/value pairs within the project metadata rather than the entire set, then use google_compute_project_metadata_item.

___
## Packer Homework

* Добавлены скрипты для packer-а, позволяющие разворачивать
инфраструктуру для приложений использующих связку ruby+mongodb, в частности 
puma-server.

* Добавлен immutable-шаблон packer-а для развёртки "baked" - образа со встроенным Reddit-app приложением
на основе образа reddit-base и bash-скрипта `packer/files/deploy_reddit_full.sh` с использованием systemd для puma.

* Добавлен скрипт для gcloud, запускающий создание и деплой полного "backed" образа - `config-scripts/create-reddit-vm.sh`.

* Переменные в шаблонах параметризованы - их нужно задавать либо через командную строку 
либо использовать внешний файл (пример `variables.json.example` присутствует в репозитории).

p.s. variables.json добавлен в .gitignore

___
testapp_IP = 35.204.251.33

testapp_port = 9292

##  GCP instance creation startup script
При [создании  инстанса](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create "Google Cloud SDK API") возможны опции --metadata startup-script для "heredoc" и startup-script-url для скрипта по ссылке.

Далее приведён пример загрузочного скрипта из файла (присутствует в репозитории):
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=/PATH/TO/SCRIPT/startup_script.sh
```


## GCP firewall rule
Копировать команду из интерфейса слишком просто - [doc](https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create "Google Cloud SDK API") =) 
```
gcloud compute --project=infra-198317 firewall-rules create default-puma-server --allow=tcp:9292 --target-tags=puma-server
```
___

bastion_IP = 35.204.57.233

someinternalhost_IP = 10.164.0.3

### Доступ на серверы
Для доступа на серверы используется следующий ~/.ssh/config конфиг, 
который позволяет с помощью простой комбинации ssh + host заходить на сервера 
(ex.: ssh someinternalhost), а также работает и для scp:
```
Host bastion
  ForwardAgent yes
  HostName 35.204.57.233
  User USERNAME
  IdentityFile ~/.ssh/KEY


Host someinternalhost
  HostName 10.164.0.3
  User USERNAME
  ProxyJump bastion
```

### P.S.
В связи с выполнением домашнего задания по GCP с Windows 10 + git bash
(может пригодится будущим поколениям), необходимо прописать в ~/.bashrc:
```
#!/bin/bash
eval `ssh-agent`
ssh-add ~/.ssh/KEY
close_agent() {
  ssh-agent -k
}

trap close_agent EXIT
```
При старте новой сессии будет запускаться ssh-agent со специальным ключом индентификации.
Далее написана функция, которая закрывает агент и её вызов при выходе из сессии.
