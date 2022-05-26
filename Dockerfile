FROM php:7-fpm-buster

EXPOSE 9000
# 进入工作目录
WORKDIR /usr/local/src

RUN apt-get update \ 
&& apt-get install -y git curl wget cron locales libc-client-dev libkrb5-dev libzip-dev

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
  install-php-extensions mysqli redis gd xmlrpc opcache zip bz2 bcmath pdo_mysql && \


# 把语言设置成简体中文
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8
RUN echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen
ENV LC_ALL C.UTF-8
ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8

COPY ./config/php.ini /usr/local/etc/php/conf.d/
COPY ./config/opcache-recommended.ini /usr/local/etc/php/conf.d/

# confiugure
RUN cd /usr/local/etc/php \
&& cp php.ini-production php.ini \
&& sed -i 's/display_errors\s*=.*/display_errors = Off/' php.ini \
&& sed -i 's/error_reporting\s*=.*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/' php.ini \
&& sed -i 's/;error_log\s*=\s*php_errors\.log/error_log = \/var\/log\/php_errors.log/' php.ini \
&& sed -i 's/;date\.timezone\s*=.*/date.timezone = Asia\/Shanghai/' php.ini
