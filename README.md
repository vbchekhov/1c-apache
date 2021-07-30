# 1C & Apache in docker

Запускаем apache для 1С в docker-контейнере 🥳

--- 

## Как пользоваться

1. Установите Docker (https://docs.docker.com/install/) и docker-compose (https://docs.docker.com/compose/install/)

2. Скачайте дистрибутив 1С сервера для Linux: https://releases.1c.ru -> Технологическая платформа 8.3 -> ***Cервер 1С:Предприятия (64-bit) для DEB-based Linux-систем.***

3. Заполните переменные в файле `Dockerfile`

```dockerfile
# путь до файла дистрибутива сервера
ENV INSTALL=deb64_8_3_14_1565.tar.gz 
# имя сервера 1С
ENV SERVER=1c-server
# имя базы на сервере 1С
ENV BASE=db-buh3
```

4. В файле `docker-compose.yaml` в параметре `extra_hosts` укажите имя сервера и IP:

```yaml
    extra_hosts:
      - "1c-server:192.168.1.5"
```

5. Запускаем команду `docker-compose up -d --build`

---

## Подключение нескольких баз 1С

1. Для подключение 2-х и более баз данных в самый конец файла `httpd.conf` добавляем следующий код, в котором меняем `BASE1C` на необходимое имя базы:

```apache
# 1c publication #2
Alias "/BASE1C" "/usr/local/apache2/htdocs/BASE1C/"
<Directory "/usr/local/apache2/htdocs/BASE1C/">
    AllowOverride All
    Options None
    Require all granted
    SetHandler 1c-application
    ManagedApplicationDescriptor "/usr/local/apache2/htdocs/BASE1C/default.vrd"
</Directory>
```

2. Дополняем `Dockerfile` переменными `SERVER` и `BASE` по типу 
```dockerfile
ENV SERVER2=s1_c02
ENV BASE2=db_ara
```

3. Дополняем `Dockerfile` в самом конце файла кодом, с переменными, которые укзали выше:
```dockerfile
COPY default.vrd /usr/local/apache2/htdocs/${BASE2}/default.vrd
RUN   sed -i'' -e "s|SERVER1C|${SERVER2}|g" /usr/local/apache2/htdocs/${BASE2}/default.vrd
RUN   sed -i'' -e "s|BASE1C|${BASE2}|g" /usr/local/apache2/htdocs/${BASE2}/default.vrd
```

4. Запускаем команду `docker-compose up -d --build`

### Пример Dockerfile для публикации двух баз


> 
> ❗️ В примере не нет пункта 1. Так как мы делаем запись в `httpd.conf` через `echo`
> 

```dockerfile
FROM httpd:2.4

ENV INSTALL=deb64_8_3_16_1814.tar.gz
ENV SERVER=1c-server
ENV BASE=db_buh
# вторая БД
ENV BASE2=db_zup

COPY ${INSTALL} deb64.tar.gz
RUN tar -xzf deb64.tar.gz -C / \
  && apt-get -qq update \
  && dpkg -i /*.deb \
  && rm /*.deb 

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
RUN sed -i'' -e "s|BASE1C|${BASE}|g" /usr/local/apache2/conf/httpd.conf

# запись в `httpd.conf` через `echo` данных о второй БД
RUN echo "Alias \"/${BASE2}\" \"/usr/local/apache2/htdocs/${BASE2}/\" \n\
  <Directory \"/usr/local/apache2/htdocs/${BASE2}/\"> \n\
      AllowOverride All \n\
      Options None \n\
      Require all granted \n\
      SetHandler 1c-application \n\
      ManagedApplicationDescriptor \"/usr/local/apache2/htdocs/${BASE2}/default.vrd\" \n\
  </Directory>" >> /usr/local/apache2/conf/httpd.conf 

COPY default.vrd /usr/local/apache2/htdocs/${BASE}/default.vrd
RUN   sed -i'' -e "s|SERVER1C|${SERVER}|g" /usr/local/apache2/htdocs/${BASE}/default.vrd
RUN   sed -i'' -e "s|BASE1C|${BASE}|g" /usr/local/apache2/htdocs/${BASE}/default.vrd

# вторая БД
COPY default.vrd /usr/local/apache2/htdocs/${BASE2}/default.vrd
RUN   sed -i'' -e "s|SERVER1C|${SERVER}|g" /usr/local/apache2/htdocs/${BASE2}/default.vrd
RUN   sed -i'' -e "s|BASE1C|${BASE2}|g" /usr/local/apache2/htdocs/${BASE2}/default.vrd

```


## TODO
 
🔲 Создание единого скрипта для запуска

🔲 Настройка публикации нескольких баз данных через скрипт
