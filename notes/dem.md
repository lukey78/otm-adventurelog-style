## SRTM1v3 - fehlende Tiles

ERROR 4: `src/N02E108.tif' not recognized as a supported file format.
ERROR 4: `src/N13E074.tif' not recognized as a supported file format.
ERROR 4: `src/N28W082.tif' not recognized as a supported file format.
ERROR 4: `src/N38E068.tif' not recognized as a supported file format.


=> ersetzt durch VIEW3-Files

## SRTM1v3 -- Aufbereitung

Alle Tiles durch gdal_fillnodata.py gejagt, weil doch etliche Lücken vorhanden waren.

=> ZU viele Lücken... z.B. im Himalaya-Gebiet (N28E083 z.B.) sind extrem schlecht.

=> NASADEM ist hier besser:

### Download NASADEM

Dateiliste aus index.html erstellen der jeweiligen Unterordner:

`
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Africa/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Africa/hgt_merge/{}" >>nasadem-files.txt
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Australia/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Australia/hgt_merge/{}" >>nasadem-files.txt
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Eurasia/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Eurasia/hgt_merge/{}" >>nasadem-files.txt
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Islands/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/Islands/hgt_merge/{}" >>nasadem-files.txt
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/NorthAmerica/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/NorthAmerica/hgt_merge/{}" >>nasadem-files.txt
curl -s "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/SouthAmerica/hgt_merge/"  | cut -d'>' -f3 | grep hgt.zip | cut -d'<' -f1 | xargs -I {} echo "https://e4ftl01.cr.usgs.gov/provisional/MEaSUREs/NASADEM/SouthAmerica/hgt_merge/{}" >>nasadem-files.txt
`

Alle parallelisiert runterladen:

`
parallel -j 10 wget -nv  --user=lukey78 --password=49\%\#b3O78tktf1B\!XAH  < nasadem-files.txt
`

### Stacking worldwide DEM

NASADEM 
SRTMv3 1" (Lücken?)
Viewfinder 1" (Lücken)
Viewfinder 3" (Lücken) 
Sonny (überschreiben) 1"


## Contours

### Shape-Files aus Tiles erzeugen

```
cd src
find . -name "*.tif" | parallel --jobs 8 -I% --max-args 1 gdal_contour -i 10 -snodata -32767 -a height % ../contour/%.shp
```

### Shape-Files mergen und warpen

```
ogrmerge.py -single -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -o contours.shp contour/*.shp
```
klappt nicht... Absturz nach wenigen Sekunden.


### Shape-File in DB einlesen

Direkt einlesen...

import_in_db.sh
```
#!/bin/bash

echo $1
file=$1
f=${file%.shp}
ogr2ogr -append -t_srs EPSG:3857 -f "PostgreSQL" 'PG:dbname='contours'' $1 -nln contours
mv $f* done/
```

ogr2ogr -append -t_srs EPSG:3857 -f "PostgreSQL" 'PG:dbname='contours'' -lco DIM=2 -nln contours N00E006.tif.shp
find . -name "*.shp" | parallel --jobs 8 -I% --max-args 1 ./import_in_db.sh %

