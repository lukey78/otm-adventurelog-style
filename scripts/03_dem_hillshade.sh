#!/bin/bash

cd /mnt/data

if [ ! -d "/mnt/data/srtm" ]; then
  echo "Please put some HGT ZIP files into the directory /mnt/data/srtm."
  exit
fi

cd srtm
for zipfile in *.zip; do unzip -j -o "$zipfile" -d unpacked; done
mkdir original
mv *.zip original/

cd unpacked
for hgtfile in *.hgt; do gdal_fillnodata.py $hgtfile $hgtfile.tif; done
rm -f *.hgt

gdalbuildvrt -resolution highest raw.vrt src/*.tif # schnellere Grundlage statt raw.tif
#gdal_merge.py -n -32767 -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -ps 0.00028 0.00028 -v -o ../raw.tif *.tif # trotzdem benötigt
gdal_merge.py -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -co NUM_THREADS=ALL_CPUS -ps 0.000277777777778 0.000277777777778 -v -o ../raw.tif *.tif

cd ..
rm -rf unpacked


# 30m - for the detail hillshade - first one gives an Integer overflow error
# gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tap -tr 30 30 raw.tif warp-30.tif
gdalwarp -tap -tr 30 30 -t_srs EPSG:3857 -of vrt -r bilinear raw.tif raw30.vrt
#gdalwarp -tap -tr 60 60 -t_srs EPSG:3857 -of vrt -r bilinear raw.tif raw60.vrt
gdalwarp -tap -tr 200 200 -t_srs EPSG:3857 -of vrt -r bilinear raw.tif raw200.vrt
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 5000 5000 raw.tif warp-5000.tif
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 1000 1000 raw.tif warp-1000.tif
gdal_translate -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -r bilinear raw30.vrt warp-30.tif
#gdal_translate -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -r bilinear raw60.vrt warp-60.tif
gdal_translate -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -r bilinear raw200.vrt warp-500.tif # inkonsistent (500/200), todo


#gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 1000 1000 raw.tif warp-1000.tif
#gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 200 200 raw.tif warp-500.tif
#gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 60 60 raw.tif warp-60.tif
#gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs EPSG:3857 -r bilinear -tr 30 30 raw.tif warp-30.tif


# relief for zoom factors 1-4
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-5000.tif /home/otm/relief_color_text_file.txt relief-5000.tif
# relief for zoom factors 5-8
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -co BIGTIFF=YES -alpha warp-500.tif /home/otm/relief_color_text_file.txt relief-500.tif

# create hillshade
gdaldem hillshade -z 7 -compute_edges -multidirectional -co COMPRESS=JPEG warp-5000.tif hillshade-5000.tif
gdaldem hillshade -z 7 -compute_edges -multidirectional -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-1000.tif hillshade-1000.tif
gdaldem hillshade -z 5 -compute_edges -multidirectional -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-500.tif hillshade-500.tif
gdaldem hillshade -z 2 -compute_edges -multidirectional -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-30.tif hillshade-30.tif
