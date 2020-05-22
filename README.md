## Nginx Compile Install 
![](https://img.shields.io/badge/build-passing-brightgreen)
![](https://img.shields.io/badge/coverage-100%25-green)

### install libmaxminddb
```bash
$ wget https://github.com/maxmind/libmaxminddb/releases/download/1.3.2/libmaxminddb-1.3.2.tar.gz
$ tar -zxvf libmaxminddb-1.3.2.tar.gz
$ cd libmaxminddb-1.3.2
$ ./configure && make && make install
$ echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf 
$ ldconfig
```

### download geoip2 data 
```
$ git clone https://github.com/ar414-com/nginx-geoip2
$ cd nginx-geoip2
$ tar -zxvf GeoLite2-City_20200519.tar.gz
$ mv ./GeoLite2-City_20200519/GeoLite2-City.mmdb /usr/share/GeoIP/
$ tar -zxvf GeoLite2-Country_20200519.tar.gz
$ mv ./GeoLite2-Country_20200519/GeoLite2-Country.mmdb /usr/share/GeoIP/ 
```

### compile and install
```
$ cd ~ && git clone https://github.com/ar414-com/nginx-geoip2
$ ./configure --user=www --group=www --prefix=/www/server/nginx \
--add-module=/root/nginx-geoip2/ngx_http_geoip2_module
$ make && make install
```

## Docker

### get docker image
```
$ docker pull ar414/nginx-geoip2
```

### run
```
$ docker run -it -d -p 80:80 -p 443:443 --rm ar414/nginx-geoip2
```

### test
```
$ curl -v http://127.0.0.1:80
< rootpath: html/b
< country: CN
```

```
$ curl -v -x https://61.194.237.25:8080 http://127.0.0.1:80
< rootpath: html/a
< country: JP
```

 