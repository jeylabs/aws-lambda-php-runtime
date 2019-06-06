# Unlike most docker images, where we want to optimize layers to be small and few
# we'd rather leverage layer caching for faster builds when things change, since
# we never ship this image, rather we extract the compiled binaries as part of
# our build process.

FROM amazonlinux:2018.03

WORKDIR /tmp

RUN yum --releasever=2018.03 install \
    git \
    autoconf \
    libtool  \
    gcc \
    gcc-c++ \
    bison \
    libxml2-devel \
    openssl-devel  \
    libpng-devel  \
    curl-devel  \
    libjpeg-devel -y

###############################################################################
# OPENSSL Build
# https://github.com/openssl/openssl/releases

RUN \
    curl -sL http://www.openssl.org/source/openssl-1.0.1k.tar.gz | tar -xvz \
    && cd openssl-1.0.1k \
    && ./config \
    && make \
    && make install

###############################################################################
# PHP Build
# https://github.com/php/php-src/releases

ENV PHP_VERSION 7.3.5

RUN \
    curl -sL http://php.net/distributions/php-${PHP_VERSION}.tar.gz | tar -xvz

RUN \
    mkdir -p /tmp/php-7-bin \
    && cd php-${PHP_VERSION} \
    && ./configure --prefix /tmp/php-7-bin \
    --with-gd \
    --with-zlib \
    --with-curl \
    --with-curl \
    --without-libzip \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-openssl=/usr/local/ssl \
    --with-config-file-path=/var/task/ \
    --enable-mbstring \
    --enable-static=yes \
    --enable-shared=no \
    --enable-hash \
    --enable-json \
    --enable-libxml \
    --enable-mbstring \
    --enable-phar \
    --enable-soap \
    --enable-xml \
    --enable-ctype \
    --enable-cgi \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-zip \
    --enable-opcache-file \
    && make install

RUN \
    git clone https://github.com/php/pecl-mail-mailparse.git \
    && cd pecl-mail-mailparse \
    && sed -i 's/#if\s!HAVE_MBSTRING/#ifndef MBFL_MBFILTER_H/' ./mailparse.c \
    && /tmp/php-7-bin/bin/phpize \
    && ./configure --with-php-config=/tmp/php-7-bin/bin/php-config \
    && make \
    && make test \
    && mv modules/mailparse.so /tmp/php-7-bin/lib/php/extensions/no-debug-non-zts-20180731/mailparse.so \
