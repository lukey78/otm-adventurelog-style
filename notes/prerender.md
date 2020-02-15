## Prerender tiles

# europe
tirex-batch -p 20 -d map=opentopomap bbox=-13,35,29,59 z=1-14 -f not-exists

# alpenraum
tirex-batch -p 20 -d map=opentopomap bbox=5.96,45.63,15.88,48.24 z=1-16 -f not-exists

# welt
tirex-batch -p 30 -d map=opentopomap bbox=-180.0,-55.2,180,72.8 z=1-12 -f not-exists


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



# tirex-batch -p 5 -d map=opentopomap bbox=-180,-60,180,60 z=1-10 -f not-exists

