# Unlike most docker images, where we want to optimize layers to be small and few
# we'd rather leverage layer caching for faster builds when things change, since
# we never ship this image, rather we extract the compiled binaries as part of
# our build process.

FROM amazonlinux:2018.03

WORKDIR /tmp

RUN yum --releasever=2018.03 install \
    autoconf \
    automake \
    libtool  \
    bison \
    bison  \
    libxml2-devel \
    openssl-devel  \
    libpng-devel  \
    curl-devel  \
    libjpeg-devel -y

###############################################################################
# PHP Build
# https://github.com/php/php-src/releases

ENV PHP_VERSION 7.3.5

RUN \
    curl -sL http://php.net/distributions/php-${PHP_VERSION}.tar.gz | tar -xvz

RUN mkdir -p /tmp/php-7-bin \
    && cd php-${PHP_VERSION} \
    && ./configure --prefix /tmp/php-7-bin \
    --with-curl \
    --with-zlib \
    --without-libzip \
    --with-config-file-path=/var/task/ \
    --with-curl \
    --with-gd \
    --with-openssl \
    --without-pear \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
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
