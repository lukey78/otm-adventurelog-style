# Overviews

Für die grossen TIF-Files (Hillshade, Slopes, etc.) ist es sinnvoll, Overviews zu erzeugen, die beim Tile Rendering von Mapnik verwendet werden können.

Als am sinnvollsten und schnellsten hat sich der iterative Ansatz gezeigt:

```
gdaladdo -r cubic --config GDAL_TIFF_OVR_BLOCKSIZE 256 --config BIGTIFF_OVERVIEW YES --config COMPRESS_OVERVIEW JPEG -ro --config GDAL_CACHEMAX 10000 MYTIF.tif 2
```

Und dann mit der erzeugten Overlay-Datei (.ovr) nochmal dasselbe:

```
gdaladdo -r cubic --config GDAL_TIFF_OVR_BLOCKSIZE 256 --config BIGTIFF_OVERVIEW YES --config COMPRESS_OVERVIEW JPEG -ro --config GDAL_CACHEMAX 10000 MYTIF.tif.ovr 2
```

Und das dann mehrfach wiederholt.

Am Ende können die Overlays wieder zusammengeführt werden:


```
gdal_translate MYTIF.tif MYTIF-with-overviews.tif -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=JPEG -co BIGTIFF=YES
```

