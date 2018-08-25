FROM centos:centos7

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum -y update

RUN yum -y install \
    less \
    curl \
    mariadb \
    php71w \
    php71w-mysql \
    php71w-cli \
    php71w-dom

RUN curl -o /usr/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/bin/wp

ADD start.sh /usr/bin/start
RUN chmod +x /usr/bin/start

WORKDIR /var/www/html

CMD start
