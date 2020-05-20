FROM centos:centos7.2.1511

RUN yum -y update
RUN yum -y install yum-plugin-ovl
RUN yum -y install  gcc gcc-c++ autoconf automake make libxslt-devel build-essential
RUN yum -y install  zlib zlib-devel openssl* pcre* wget lua-devel
RUN yum -y install git htop

MAINTAINER ar414 root@ar414.com

ADD http://nginx.org/download/nginx-1.14.2.tar.gz /tmp/nginx-1.14.2.tar.gz
#nginx module
ADD https://github.com/vision5/ngx_devel_kit/archive/v0.3.1.tar.gz /tmp/ngx_devel_kit.tar.gz

# lua-nginx-module rely LuaJIT
ADD https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz /tmp/lua-nginx-module.tar.gz
ADD https://github.com/LuaJIT/LuaJIT/archive/v2.0.5.tar.gz /tmp/LuaJIT.tar.gz
ADD https://www.openssl.org/source/openssl-3.0.0-alpha2.tar.gz /tmp/openssl-3.0.0-alpha2.tar.gz
ADD https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz  /tmp/ngx_cache_purge.tar.gz
ADD https://github.com/alibaba/nginx-http-concat/archive/1.2.2.tar.gz  /tmp/nginx-http-concat.tar.gz

WORKDIR  /tmp

# install LuaJIT
RUN mkdir /tmp/LuaJIT && tar xf LuaJIT.tar.gz -C /tmp/LuaJIT --strip-components 1
WORKDIR  /tmp/LuaJIT
RUN ls
RUN make PREFIX=/usr/local/luajit
RUN make install PREFIX=/usr/local/luajit

# Unzip lua-nginx-module
WORKDIR  /tmp
RUN mkdir /tmp/lua-nginx-module && tar xf lua-nginx-module.tar.gz -C /tmp/lua-nginx-module --strip-components 1
RUN cp -r lua-nginx-module/ /usr/local/src/

# Unzip OpenSSL
WORKDIR  /tmp
RUN mkdir /tmp/openssl-3.0.0-alpha2 && tar xf openssl-3.0.0-alpha2.tar.gz -C /tmp/openssl-3.0.0-alpha2 --strip-components 1
RUN cp -r openssl-3.0.0-alpha2/ /usr/local/src/

# Unzip ngx_devel_kit
WORKDIR  /tmp
RUN mkdir /tmp/ngx_devel_kit && tar xf ngx_devel_kit.tar.gz -C /tmp/ngx_devel_kit --strip-components 1
RUN cp -r ngx_devel_kit/ /usr/local/src/

# Unzip ngx_cache_purge
WORKDIR  /tmp
RUN mkdir /tmp/ngx_cache_purge && tar xf ngx_cache_purge.tar.gz -C /tmp/ngx_cache_purge --strip-components 1
RUN cp -r ngx_cache_purge/ /usr/local/src/

# download ngx-geoip2-module Related Data
WORKDIR /tmp
RUN git clone https://github.com/ar414-com/nginx-geoip2.git
# install libmaxminddb
WORKDIR /tmp/nginx-geoip2
RUN tar -zxvf libmaxminddb-1.3.2.tar.gz
WORKDIR /tmp/nginx-geoip2/libmaxminddb-1.3.2
RUN ./configure && make && make install && ldconfig
# Initialize geoip data path
WORKDIR /tmp/nginx-geoip2
RUN cp -r ngx_http_geoip2_module/ /usr/local/src/
RUN tar -zxvf GeoLite2-City_20200519.tar.gz
RUN mkdir -p /usr/local/share/GeoIP/
RUN mv /tmp/nginx-geoip2/GeoLite2-City_20200519/GeoLite2-City.mmdb /usr/local/share/GeoIP/
RUN tar -zxvf GeoLite2-Country_20200519.tar.gz
RUN mv /tmp/nginx-geoip2/GeoLite2-Country_20200519/GeoLite2-Country.mmdb /usr/local/share/GeoIP/
# install nginx
WORKDIR /tmp
RUN useradd -M -s /sbin/nologin www
RUN tar -zxvf nginx-1.14.2.tar.gz
RUN mkdir -p /usr/local/nginx
WORKDIR /tmp/nginx-1.14.2
RUN ./configure --user=www --group=www --prefix=/www/server/nginx \
--with-openssl=/usr/local/src/openssl-3.0.0-alpha2 \
--add-module=/usr/local/src/ngx_devel_kit \
--add-module=/usr/local/src/lua-nginx-module \
--add-module=/usr/local/src/ngx_cache_purge \
--add-module=/usr/local/src/ngx_http_geoip2_module \
--with-http_stub_status_module --with-http_ssl_module \
--with-http_v2_module --with-http_image_filter_module \
--with-http_gzip_static_module --with-http_gunzip_module \
--with-stream --with-stream_ssl_module --with-ipv6  \
--with-http_sub_module --with-http_flv_module \
--with-http_addition_module --with-http_realip_module \
--with-http_mp4_module \
--with-pcre=pcre-8.40 && make && make install

RUN /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
RUN ln -s /usr/local/nginx/sbin/* /usr/local/sbin/

EXPOSE 42080 42443

CMD ["/usr/local/nginx/sbin/nginx","-g","daemon off;"]
