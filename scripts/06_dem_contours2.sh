#!/bin/bash

cd /mnt/data/srtm

# import contours data into db

mkdir /mnt/data/contours-db
chown postgres /mnt/data/contours-db
sudo -u postgres psql -c "CREATE TABLESPACE contours LOCATION '/mnt/data/contours-db';"
createdb contours -O tirex --tablespace=contours
psql -d contours -c 'CREATE EXTENSION postgis;'
psql -d contours -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
osm2pgsql --slim -d contours --cache 5000 --style /home/otm/db/contours.style contour*.pbf
psql -d contours -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO tirex;'
