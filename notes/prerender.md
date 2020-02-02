## Prerender tiles

# europe
tirex-batch -p 5 -d map=opentopomap bbox=-13,35,29,59 z=1-12 -f not-exists


## Lauterbrunnen/Mürren - Performance-TEst

### Ohne Optimierung

tirex-batch -p 5 -d map=opentopomap bbox=7.86,46.55,7.94,46.60 z=12
=> 34s
=> 19s


=> bringt nix


### Diverses

contours:
VACUUM ANALYZE
cluster contours_wkb_geometry_geom_idx on contours;



