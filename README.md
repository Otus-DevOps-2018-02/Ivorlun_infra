# Ivorlun_infra
Ivorlun infrastructure repository

[![Build Status](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra.svg?branch=master)](https://travis-ci.org/Otus-DevOps-2018-02/Ivorlun_infra)


___
## Ansible 4

* На это задание было потрачено уйма времени из-за проблем описанных ниже.
* Из-за того что у меня основная ОС Ubuntu 18.04 bionic beaver имеет новое (на 05.2018) ядро 4.15 и некоторые изменения в либах, на ней в данный момент не работает VBox (VMware тоже).
* Поэтому данная работа выполняется на VBox on Windows 10 + vagrant on WSL ubuntu 16.04, ansible on WSL etc. 
* Идея взята отсюда - https://www.vagrantup.com/docs/other/wsl.html.
* Решение второй проблемы, с которой я столкнулся при выполнении `vagrant up` - [VERR_PATH_NOT_FOUND](https://github.com/joelhandwell/ubuntu_vagrant_boxes/issues/1#issuecomment-292370353)
* Далее столкнулся с тем, что права на файлы снаружи ubuntu-subsystem невозможно изменить на `-х` [никак](https://github.com/Microsoft/WSL/issues/81#issuecomment-207553514), в связи с чем пришлось переместить vault.key в `~/vault.key` и там уже сменить права - иначе ansible принимал vault.key за скрипт.
* И последняя проблема была вновь связана с COM-портом VirtualBox - при выполнении `molecule --debug create`, не воздавался инстанс.
Решить мне её удалось только с помощью [обновлённой документации](https://molecule.readthedocs.io/en/latest/configuration.html#vagrant) - нужно добавить `provider_raw_config_args` в секцию `platforms` в `molecule.yml`:
```platforms:
  - name: instance
    box: ubuntu/xenial64
    provider_raw_config_args:
      - customize [ 'modifyvm', :id, '--uartmode1', 'disconnected' ]
```
До этого я пытался с помощью [raw_config_args](https://github.com/metacloud/molecule/issues/424#issuecomment-244283947), но этот ключ похоже устарел.
* Страница 46 pdf: при смене пользователя с ubuntu на vagrant происходит замена unit-файла systemd, но при этом, в нашей конфигурации, в handler не прописан рестарт systemctl daemon.
Мне кажется было бы логичным при любом деплое шаблона с любым unit-файлом обязательно в хэндлере писать `daemon_reload=yes`.

### Основная часть

* Переработаны тесты packer, terraform, ansible и перенесены в travis.yml
* Изучены основы работы с Vagrant
* Изучена работа Vagrant+VBox на WSL
* Добавлен базовый плэйбук для установки python по ssh
* base.yml включён в site.yml
* Task-и ролей app и db логически разбиты и разнесены по разным файлам
* Параметризован пользователь для деплоя приложения
* Протестирована работа ролей app и db в vagrant
* Написаны тесты molecule для ролей app и db 


### Задание со * nginx vagrant

* Проксирован порт 9292 на 80 через extra_vars в Vagrantfile, чтобы приложение было доступно чисто по ip: 10.10.10.20

### Задание со * db-role в отдельный репозиторий

*  

___
## Ansible 3

* Вопрос про терраформ - есть ли возможность без костылей сделать source_ranges var в terraform prod автоматическим?
Что-то вида `source_ranges=${"$(/usr/bin/curl ifconfig.me)/32"}`.
Тогда не придётся постоянно лезть в настройку переменной.
Насколько я понимаю сейчас есть варианты [external data source](https://www.terraform.io/docs/providers/external/data_source.html) и проброски output as input или же явно передавать `terraform aaply -var 'source_ranges=...`.


### Основная часть

* Исправлены шаблоны пакера - `{{template_dir}}`
* Инфраструктурный код переписан в соответствии с best practices и разделён по ролям
* Добавлена роль nginx, перенаправляющая приложение с 9292 на 80 порт
* Использован ansible vault для шифровки параметров в роли создания пользователей окружения
* Мелкие исправления


### Задание со * Dynamic inventory for stage and prod

* Динамический инветори и без задания использовался как основной - так как удобно =)
* Файл переименован в более понятное название

### Задание с ** TravisCI infrastructure tests

* Изучены некторые азы Travis CI
* Дописан ci-скрипт для проверки инфраструктурного кода


___
## Ansible 2

### ОШИБКИ!
Хэндлер для app-hosts из gist в hw10.pdf на 49 и на 53 странице содержит ошибку __state=reloaded__:
```
  handlers:
  - name: reload puma
    systemd: name=puma state=reloaded
```
выдаёт следующующее:
```
fatal: [appserver]: FAILED! => {"changed": false, "msg": "Unable to reload service puma: Failed to reload puma.service: Job type reload is not applicable for unit puma.service.\nSee system logs and 'systemctl status puma.service' for details.\n"}
```
Потому что в unit-файле нет `ExecReload`; должно быть `state=restarted`.
Также лучше сделать `systemctl daemon-reload`, например если сервис уже зарегестрирован (не сработал триггер террформ), но на диске unit-файл обновился т.е. `daemon_reload: yes`, иначе изменений не произойдёт.

Так же надо отметить, что если в данный момент созданные терраформом хосты уничтожены, то с ними уничтожено и правило, которе позволяет ssh-connect.

Страница 35 в pdf:
`repo: 'https://github.com/express42/reddit.git'`
А Travis CI проверяет diff и должно быть почему-то
`repo: 'https://github.com/Otus-DevOps-2017-11/reddit.git'`
Стоит отметить что первый репо актуальнее на данный момент.

### Основная часть ДЗ

* Конфигурация приложения разбита по соответствующим playbook-ам
* Изучены и использованы механизмы handler-ов и tag-ов
* Provisioner-ы packer-а сменены с bash-скриптов на ansible
* Template-images пересобраны и проверены

### Задание со * Dynamic inventory для GCP

* Написан неуклюжий скрипт, который импортирует хосты из GCP в ansible inventory.
* Динамический инвентори выгружает все внешние адреса хостов, ставит их в соответствие с именем и группирует по тэгу.
* Для работы требуется gcloud auth plugin и проект по умолчанию.
* Этот скрипт используется в качестве inventory по умолчанию


___
## Ansible 1

* Добавлена конфигурация ansible для хостов app и db reddit-app
* Конфигурация разбита на inventory-файлы, файлы требований и конфигурации доступа к хостам

### Применение плэйбуков из основной части ДЗ

* После первого исполнения плэйбука состояние хостов группы app не изменяется из-за того, что новейший репозиторий уже есть в данном каталоге. 
* Команда `ansible app -m command -a 'rm -rf ~/reddit'` выполняет удаление на всех хостах группы app директории $HOME/reddit. 
Из-за этого повторный запуск плэйбука возвращает: `appserver : ok=2    changed=1    unreachable=0    failed=0`.
Это значит, что плэйбук был исполнен успешно, при этом состояние хоста изменилось после выполнения этого плэйбука.

### Задание со * Dynamic inventory

* Написан неуклюжий скрипт `dyn_inv.sh`, который является dynamic inventory на основе inventory.json.
* Проверить его работоспособность можно при созданных хостах и соответствующих записях в json - `ansible -m ping all -i dyn_inv.sh`.

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
