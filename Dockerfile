FROM xfan1024/openeuler:23.03-light
RUN mkdir /tools
WORKDIR /tools
# 安装依赖
RUN yum -y install util-linux  dos2unix gcc make unzip wget\
    && wget https://github.com/ncopa/su-exec/archive/master.zip\
    && unzip master.zip\
    && cd su-exec-master\
    && make\
    && cp su-exec /usr/local/bin/
  
RUN yum -y install postgresql postgresql-server \
    &&mkdir /data\
    &&chown -R postgres /data\
    &&chown -R postgres /tools  

ENV TZ=Asia/Shanghai

COPY ./update-pg-password.sh /usr/local/bin
COPY eulixspace_pgsql_init.sh /docker-entrypoint-initdb.d/10_eulixspace.sh
COPY docker-entrypoint.sh /usr/local/bin

RUN dos2unix -k /usr/local/bin/update-pg-password.sh /usr/local/bin/docker-entrypoint.sh /docker-entrypoint-initdb.d/10_eulixspace.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod 777 /usr/local/bin/update-pg-password.sh
RUN chmod +x /docker-entrypoint-initdb.d/10_eulixspace.sh
RUN chmod +x /usr/local/bin/su-exec

RUN chown -R postgres /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["postgres"]