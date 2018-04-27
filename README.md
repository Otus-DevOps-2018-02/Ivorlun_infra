# Ivorlun_infra
Ivorlun infrastructure repository

[![Build Status](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra.svg?branch=master)](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra)

___
## Terraform 2

* Шаблоны, созданные в прошлом задании разбиты на логические сущности в виде модулей и оптимизированы. 
* Использован модуль gcs bucket из Terraform registry.
* Шаблоны разбиты на две вариации окружения - stage и prod.

### Задание со * Remote backends

* В gcloud вручную(не терраформом) создан storage для синхронизации tfstate.
* При подключении rb terraform предложил перенести файлы состояния в облако. Благодаря этому при запуске из любых мест состояние всегда синхронизировано.
* В процессе выполнения ДЗ в качестве эксперимента провёл миграцию с одного облачного backend-а на другой.
* При одновременной попытке прменить изменения во втором случае возникает ошибка `Error locking state: Error acquiring the state lock` которая указывает на то, кто и как изменяет состояние системы.

### Задание со * app deploy

* Мне кажется это задание должно быть с двумя звёздочками т.к. оно гораздо сложнее load-balancer-а(**) из прошлого ДЗ. Во многом нужно детально разобраться.
* Добавлена переменная ip-адреса БД для соединения с инстансами приложения, проброшена в модуль app через корень терраформа.
* Добавлен специальный ресурс и скрипты для развёртки самого приложения из исходников.
* Добавлен триггер для включения или выключения развёртки в зависимости от значения переменной.
* Исправлена ошибка (или подвох?) что в mongodb service был `bind_ip=127.0.0.1`!
* Из-за предыдущего пункта изменил скрипт и пересобрал образ из пакера.
* В связи с тем что puma не подхватывает `$DATABASE_URL` ни из ~/.profile ни из ~/.bashrc пришлось сделать немного топорно через шаблон сервиса.
___
## Terraform 1

* Создан шаблон terraform для развёртки и управления конфигурацией инстанса reddit-app, а также для создания и управления правилом firewall-а. 
Шаблон параметризован и отформатирован.

### Задание со * про ssh-keys

После развёртки инстанса он доступен по `ssh appuser@<address> -i ~/.ssh/appuser`.

Нужно аккуратнее работать со структурами, а то из-за запятых в key-value, ключи могут стираться!


#### UPD!

Видимо суть задания была в другом - похоже что под "метаданные проекта" в дз имелась ввиду как раз сущность [google_compute_project_metadata](https://www.terraform.io/docs/providers/google/r/compute_project_metadata.html).Так как метаданные есть и в g.comp.instance, то это приводит к путанице!

Идея в том, что существуют две области метаданных - на уровне инстансов и на уровне проектов. 

Проблема заключается в том, что происходит конфликт между terraform и GCP console и, в следствии, перезапись ключей если из GCP или же ошибка добавления в связи с наличием ssh-keys в terraform.


### Задание с ** про load-balancer

Создан load-balancer перенаправляющий запросы со своего адреса на один из инстансов reddit-app.

Проблемой конфигурации в которой жётско заданы два инстанса будет масштабирование.
К тому же код, описывающий инфраструктуру - дублируется.

В итоге сделан динамический балансировщик, принимающий в качестве параметра количество желаемых инстансов.

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
