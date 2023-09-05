#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# psql -c "CREATE DATABASE eulixspace_geo;" || echo "eulixspace_geo ALREADY EXISTS"

isTableExist=`psql -A -t -q -Upostgres --dbname=file -c "select count(1) from information_schema.tables where table_schema='public' and table_name='district'"`

if [ ${isTableExist} -eq 1 ];then
    count=`psql -A -t -q -Upostgres --dbname=file -c "select count(1) from district"`

    if [ ${count} -eq 2875 ];then
        echo "China geo have been import"
        exit 0
    fi
fi




# Load PostGIS into both template_database and $POSTGRES_DB

echo "Updating PostGIS extensions eulixspace_geo to $POSTGIS_VERSION"
psql --dbname=file -c "
    -- Upgrade PostGIS (includes raster)
    CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
    ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';

    -- Upgrade Topology
    CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';
    ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';

    -- Install Tiger dependencies in case not already installed
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    -- Upgrade US Tiger Geocoder
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder VERSION '$POSTGIS_VERSION';
    ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
"
echo "Init China GEO Data"
shp2pgsql  /opt/ChinaAdminDivisonSHP-22.08.07/District/district.shp  | psql -U postgres -d file -p 5432

# fix Data
psql --dbname=file -c "
    -- delete Taiwan Data
    DELETE FROM district WHERE ct_adcode = '710000';

    -- update beijing,shanghai,chongqing,tianjin Data
    UPDATE district SET ct_name = '北京市' WHERE ct_adcode = '110100';
    UPDATE district SET ct_name = '天津市' WHERE ct_adcode = '120100';
    UPDATE district SET ct_name = '上海市' WHERE ct_adcode = '310100';
    UPDATE district SET ct_name = '重庆市' WHERE ct_adcode = '500100';
"
