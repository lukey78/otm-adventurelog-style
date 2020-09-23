
# Slope Map erzeugen

color_slope.txt

```
0 0 0 0 0
24 0 0 0 0
25 190 250 114
30 245 245 80
35 255 182 15
40 255 100 5
45 255 55 5
50 209 0 0
60 160 0 0
90 70 0 0
```


```
gdaldem slope warp-30.tif warp-30-slope.tif -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -co BIGTIFF=YES
gdaldem color-relief warp-30-slopes.tif color_slope.txt warp-30-slope-map.tif -co COMPRESS=LZW -co PREDICTOR=2 -co BIGTIFF=YES -alpha
gdaladdo -r cubic --config GDAL_TIFF_OVR_BLOCKSIZE 256 --config BIGTIFF_OVERVIEW YES --config COMPRESS_OVERVIEW JPEG -ro --config GDAL_CACHEMAX 10000 warp-30-slope-map.tif 2
... iterativ mit .ovr-Files fortsetzen
```

europe:
tirex-batch -p 30 -d map=slopemap bbox=-13,35,29,59 z=9 -f not-exists

tirex-batch -p 30 -d map=slopemap bbox=-180,-60,180,60 z=9 -f not-exists


