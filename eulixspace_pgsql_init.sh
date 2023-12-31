#!/bin/sh
set -e

psql -b --username "$POSTGRES_USER" <<-EOSQL
CREATE DATABASE $POSTGRES_FILEDB;
CREATE DATABASE $POSTGRES_MAILDB;
CREATE DATABASE $POSTGRES_GATEWAYDB;
CREATE DATABASE $POSTGRES_ACCOUNTDB;
EOSQL
