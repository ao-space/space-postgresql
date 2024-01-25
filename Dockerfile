FROM xfan1024/openeuler:23.03-light

RUN mkdir /tools
WORKDIR /tools

RUN yum -y install wget make gcc readline-devel zlib-devel util-linux tzdata dos2unix

RUN wget https://ftp.postgresql.org/pub/source/v12.16/postgresql-12.16.tar.gz
RUN tar -xvf postgresql-12.16.tar.gz

WORKDIR /tools/postgresql-12.16
RUN ./configure --prefix=/usr/local/postgresql\
    && make -j16\
    && make install

# 创建postgres用户和数据目录
RUN useradd postgres\
    && mkdir /usr/local/postgresql/data\
    && chown -R postgres /usr/local/postgresql
# 初始化数据库并启动PostgreSQL服务
USER postgres
RUN /usr/local/postgresql/bin/initdb -D /usr/local/postgresql/data\
    && /usr/local/postgresql/bin/pg_ctl -D /usr/local/postgresql/data start\
    && /usr/local/postgresql/bin/createdb test\
    && /usr/local/postgresql/bin/psql test

ENV TZ=Asia/Shanghai

COPY ./update-pg-password.sh /usr/local/bin
COPY eulixspace_pgsql_init.sh /docker-entrypoint-initdb.d/10_eulixspace.sh
COPY docker-entrypoint.sh /usr/local/bin

RUN dos2unix -k /usr/local/bin/update-pg-password.sh /usr/local/bin/docker-entrypoint.sh /docker-entrypoint-initdb.d/10_eulixspace.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/update-pg-password.sh
RUN chmod +x /docker-entrypoint-initdb.d/10_eulixspace.sh
