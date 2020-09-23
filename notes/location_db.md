Location-DB erzeugen
====================

Challenges:

* Queries via OverpassQL sind lahm
* Daten sollten in Datenbank vorliegen (Postgres)
* Daten liegen bereits in Mapserver-DB, aber...
* ... es sind 18 Millionen "points" - ohne Index auf Name - Queries sind auch lahm
* ... es sind keine Länderinfos dabei ...


psql -d gis
 
gis=# select osm_id,name,ele,ST_X(ST_Transform(way, 4326)) as long,ST_Y(ST_Transform(way, 4326)) as lat, place, "natural", "tourism" from planet_osm_point where name='Bietschhorn' and (place is not null or "natural" is not null or "tourism" is not null);
  osm_id  |    name     | ele  |   long    |       lat        | place | natural | tourism 
----------+-------------+------+-----------+------------------+-------+---------+---------
 26862559 | Bietschhorn | 3934 | 7.8508198 | 46.3915722002776 |       | peak    | 
(1 row)

  

# Eigene "location"-Tabelle bauen:


CREATE TABLE location ("osm_id" BIGINT PRIMARY KEY, "name" TEXT, "ele" TEXT, "lat" FLOAT, "lon" FLOAT, "way" geometry(Point,3857), country_code VARCHAR(3), "place" TEXT, "natural" TEXT, "tourism" TEXT);

INSERT INTO location SELECT osm_id,name,ele,ST_Y(ST_Transform(way, 4326)) AS lat,ST_X(ST_Transform(way, 4326)) AS lon, way, null, "place", "natural", "tourism" FROM planet_osm_point WHERE name IS NOT NULL and ("place" IS NOT NULL or "natural" IS NOT NULL or "tourism" IS NOT NULL);
INSERT INTO location SELECT DISTINCT ON(osm_id) osm_id,name,null,ST_Y(ST_Transform(st_centroid(way), 4326)) AS lat,ST_X(ST_Transform(st_centroid(way), 4326)) AS lon, st_centroid(way) as way, null, "place", "natural", "tourism" FROM planet_osm_polygon WHERE name IS NOT NULL and ("place" IS NOT NULL or "natural" IS NOT NULL or "tourism" IS NOT NULL) ON CONFLICT DO NOTHING;

CREATE INDEX location_name_idx ON location (lower(name));



# Queries (bspw.):


Name query:

select * from location where lower(name) like '%jens%';

 
# Bounding Box Query:

select * from location where ST_Contains(ST_Transform(ST_MakeEnvelope(7.651, 47.56, 7.702, 47.5361, 4326), 3857), way);



# HTTP-API für Postgres:

https://postgrest.org/en/stable/api.html



# ZUGRIFFE:

gis=# create user location with password 'locationpass';
CREATE ROLE
gis=# grant connect on database gis to location;
GRANT
gis=# grant all privileges on table location to location;
GRANT


Änderung in pg_hba.conf:

host    all             all              0.0.0.0/0                       md5
host    all             all              ::/0                            md5


Änderung in postgresql.conf:

listen_addresses = '*'




# Test Login von aussen:

docker run -it --rm --network internal-services-network jbergknoff/postgresql-client postgresql://location:locationpass@mapserver:5432/gis



# POSTGREST

curl http://localhost:3000/location?name=ilike.*Aletsch*

GEIL!
