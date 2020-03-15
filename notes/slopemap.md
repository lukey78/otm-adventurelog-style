
# Slope Map erzeugen

color_slope.txt

```
30 245 245 80
35 255 182 15
40 255 100 5
45 255 55 5
50 209 0 0
60 160 0 0
90 70 0 0
```


```
gdaldem slope warp-30.tif warp-30-slope.tif -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2
gdaldem color-relief warp-30-slopes.tif color_slope.txt warp-30-slope-map.tif -co COMPRESS=LZW -co PREDICTOR=2 -alpha
```

