# Unlike most docker images, where we want to optimize layers to be small and few
# we'd rather leverage layer caching for faster builds when things change, since
# we never ship this image, rather we extract the compiled binaries as part of
# our build process.

FROM amazonlinux:2018.03

WORKDIR /tmp

RUN yum --releasever=2018.03 install \
    autoconf \
    bison \
    cmake3 \
    cmake \
    gcc \
    gcc-c++ \
    libtool  \
    bison  \
    libxml2-devel \
    openssl-devel  \
    libpng-devel  \
    curl-devel  \
    libjpeg-devel -y

###############################################################################
# Zip Build
# https://github.com/openssl/openssl/releases

RUN \
    curl -sL https://libzip.org/download/libzip-1.4.0.tar.gz  | tar -xvz \
    && cd libzip-1.4.0 \
    && mkdir build \
    && cd build \
    && cmake3 .. \
    && make \
    && make install

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

RUN mkdir -p /tmp/php-7-bin \
    && cd php-${PHP_VERSION} \
    && ./configure --prefix /tmp/php-7-bin \
    --with-openssl=/usr/local/ssl \
    --with-curl \
    --with-zlib \
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
    --with-curl \
    --with-gd \
    --with-zlib \
    --with-openssl \
    --without-pear \
    --enable-ctype \
    --enable-cgi \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-zip \
    --enable-opcache-file \
    --with-config-file-path=/var/task/ \
    && make install
