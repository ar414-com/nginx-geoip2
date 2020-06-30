FROM centos:centos7.2.1511

RUN yum -y update
RUN yum -y install yum-plugin-ovl
RUN yum -y install  gcc gcc-c++ autoconf automake make libxslt-devel build-essential
RUN yum -y install  zlib zlib-devel openssl* pcre* wget lua-devel gd-devel
RUN yum -y install git htop

MAINTAINER ar414 root@ar414.com

ADD http://nginx.org/download/nginx-1.14.2.tar.gz /tmp/nginx-1.14.2.tar.gz

WORKDIR  /tmp

# download ngx-geoip2-module Related Data
WORKDIR /tmp
RUN git clone https://github.com/ar414-com/nginx-geoip2.git
# install libmaxminddb
WORKDIR /tmp/nginx-geoip2
RUN mkdir /tmp/nginx-geoip2/libmaxminddb && tar xf libmaxminddb-1.3.2.tar.gz -C /tmp/nginx-geoip2/libmaxminddb --strip-components 1
WORKDIR /tmp/nginx-geoip2/libmaxminddb
RUN ./configure && make && make install
RUN echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf
RUN ldconfig
# Initialize geoip data path
WORKDIR /tmp/nginx-geoip2
RUN mv ./ngx_http_geoip2_module /usr/local/src/
RUN tar -zxvf GeoLite2-City_20200519.tar.gz
RUN mkdir -p /usr/local/share/GeoIP/
RUN cp /tmp/nginx-geoip2/GeoLite2-City_20200519/GeoLite2-City.mmdb /usr/local/share/GeoIP/
RUN tar -zxvf GeoLite2-Country_20200519.tar.gz
RUN cp /tmp/nginx-geoip2/GeoLite2-Country_20200519/GeoLite2-Country.mmdb /usr/local/share/GeoIP/
# install nginx
WORKDIR /tmp
RUN useradd -M -s /sbin/nologin www
RUN mkdir /tmp/nginx && tar xf nginx-1.14.2.tar.gz -C /tmp/nginx --strip-components 1
RUN mkdir -p /usr/local/nginx
WORKDIR /tmp/nginx
RUN ./configure --user=www --group=www --prefix=/usr/local/nginx \
--add-module=/usr/local/src/ngx_http_geoip2_module \
&& make && make install

RUN /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
RUN ln -s /usr/local/nginx/sbin/* /usr/local/sbin/

RUN rm -rf /usr/local/nginx/conf/nginx.conf
RUN cp /tmp/nginx-geoip2/tests/nginx.conf /usr/local/nginx/conf/
RUN mv /tmp/nginx-geoip2/tests/html/a /usr/local/nginx/html/
RUN mv /tmp/nginx-geoip2/tests/html/b /usr/local/nginx/html/

EXPOSE 80 443

CMD ["/usr/local/nginx/sbin/nginx","-g","daemon off;"]
