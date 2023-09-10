FROM postgres:12.16-alpine3.18

RUN apk --no-cache add tzdata

ENV TZ=Asia/Shanghai

COPY ./update-pg-password.sh /usr/local/bin
COPY eulixspace_pgsql_init.sh /docker-entrypoint-initdb.d/10_eulixspace.sh
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh 
RUN chmod +x /usr/local/bin/update-pg-password.sh
RUN chmod +x /docker-entrypoint-initdb.d/10_eulixspace.sh