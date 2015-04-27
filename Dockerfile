FROM ubuntu:14.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Nginx-PHP Installation
RUN apt-get update
RUN apt-get install -y vim curl wget build-essential python-software-properties software-properties-common
RUN add-apt-repository -y ppa:ondrej/php5
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl php5-gd php5-mcrypt php5-intl php5-imap php5-tidy

#phalcon 2.0
RUN apt-get install -y git php5-dev libpcre3-dev gcc make
RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git -b 2.0.0 cphalcon
RUN cd cphalcon/build && ./install;
RUN echo 'extension=phalcon.so' >> /etc/php5/fpm/conf.d/30-phalcon.ini

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
 
RUN mkdir -p        /var/www

# adicionando minhas configuracoes do nginx

ADD build/default   /etc/nginx/sites-available/default

# adicionando meu bash para startar os serviços
ADD build/start_services.sh /start_services.sh
RUN chmod +x /start_services.sh

EXPOSE 80

# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
