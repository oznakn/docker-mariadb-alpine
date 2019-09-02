FROM alpine:3

ENV LC_ALL=en_TR.UTF-8

RUN apk -U upgrade && apk add --no-cache mariadb mariadb-client tzdata && \
    rm -rf /var/cache/apk/*

# comment out a few problematic configuration values
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/my.cnf && \
    sed -i  's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf && \
    # don't reverse lookup hostnames, they are usually another container
    sed -i '/^\[mysqld]$/a skip-host-cache\nskip-name-resolve' /etc/my.cnf && \
    # always run as user mysql
    sed -i '/^\[mysqld]$/a user=mysql' /etc/my.cnf && \
    # allow custom configurations
    echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/my.cnf && \
    mkdir -p /etc/mysql/conf.d/

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
# Default arguments passed to ENTRYPOINT if no arguments are passed when starting container
CMD ["mysqld_safe"]
