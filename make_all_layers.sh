
#!/usr/bin/env bash
# Maak een GeoPackage met alle SF-geometry types (2D/Z/M/ZM),
# CRS = EPSG:28992 (RD New), en voeg per laag een voorbeeld-feature toe
# rond Amersfoort (OLV-toren) op (155000, 463000) via tijdelijke GeoJSON-bestanden.
# M-waarden in GeoJSON zijn niet formeel gespecificeerd (RFC 7946),
# daarom forceren we dimensies met 'ogr2ogr -dim XYM/XYZM'. Zie GDAL docs.

set -euo pipefail

OUT_GPKG="${1:-geopackage_all_types_rd.gpkg}"
EPSG_CODE=28992          # RD New
CENTER_X=155000
CENTER_Y=463000
D=50                     # offset voor lijnen/vlakken
ZVAL=10                  # voorbeeld Z (hoogte)
M0=0                     # maat (begin)
M1=100                   # maat (eind)

command -v ogr2ogr >/dev/null 2>&1 || { echo "❌ 'ogr2ogr' niet gevonden"; exit 1; }

# Schoon starten
[[ -f "$OUT_GPKG" ]] && rm -f "$OUT_GPKG"

# Lege bron voor laagcreatie
EMPTY_GJ="$(mktemp)"
cat > "$EMPTY_GJ" <<'JSON'
{ "type": "FeatureCollection", "features": [] }
JSON

families=(POINT LINESTRING POLYGON MULTIPOINT MULTILINESTRING MULTIPOLYGON GEOMETRYCOLLECTION)
variants=("" "Z" "M" "ZM")

# Helper: bepaal -dim op basis van variant
dim_for() {
  case "$1" in
    "")   echo "XY" ;;
    "Z")  echo "XYZ" ;;
    "M")  echo "XYM" ;;
    "ZM") echo "XYZM" ;;
  esac
}

# Helper: schrijf een tijdelijk GeoJSON met één feature voor gegeven family+variant
# Output: pad naar tmp .geojson
make_tmp_geojson() {
  local fam="$1" ; local var="$2"
  local X="$CENTER_X" ; local Y="$CENTER_Y"
  local Xm=$((CENTER_X - D)) ; local Ym=$((CENTER_Y - D))
  local Xp=$((CENTER_X + D)) ; local Yp=$((CENTER_Y + D))
  local tmp="$(mktemp --suffix=.geojson)"

  # Coördinaten helpers (per variant)
  # Let op: RFC 7946: 3e coord = Z, M is niet gespecificeerd; voor M-only gebruiken we 3e coord als maat (XYM) en forceren -dim XYM
  case "$fam" in
    POINT)
      case "$var" in
        "")   geom="{\"type\":\"Point\",\"coordinates\":[$X,$Y]}" ;;
        "Z")  geom="{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]}" ;;
        "M")  geom="{\"type\":\"Point\",\"coordinates\":[$X,$Y,$M0]}" ;;             # 3e coord als M (via -dim XYM)
        "ZM") geom="{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL,$M0]}" ;;       # 4e coord als M (via -dim XYZM)
      esac ;;
    LINESTRING)
      case "$var" in
        "")   geom="{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" ;;
        "Z")  geom="{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}" ;;
        "M")  geom="{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$M0],[$Xp,$Yp,$M1]]}" ;;
        "ZM") geom="{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1]]}" ;;
      esac ;;
    POLYGON)
      case "$var" in
        "")   geom="{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym],[$Xp,$Ym],[$Xp,$Yp],[$Xm,$Yp],[$Xm,$Ym]]]}" ;;
        "Z")  geom="{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$Xp,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL],[$Xm,$Yp,$ZVAL],[$Xm,$Ym,$ZVAL]]]}" ;;
        "M")  geom="{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$M0],[$Xp,$Ym,$M0],[$Xp,$Yp,$M1],[$Xm,$Yp,$M1],[$Xm,$Ym,$M0]]]}" ;;
        "ZM") geom="{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$ZVAL,$M0],[$Xp,$Ym,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1],[$Xm,$Yp,$ZVAL,$M1],[$Xm,$Ym,$ZVAL,$M0]]]}" ;;
      esac ;;
    MULTIPOINT)
      case "$var" in
        "")   geom="{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" ;;
        "Z")  geom="{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}" ;;
        "M")  geom="{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$M0],[$Xp,$Yp,$M1]]}" ;;
        "ZM") geom="{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1]]}" ;;
      esac ;;
    MULTILINESTRING)
      case "$var" in
        "")   geom="{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym],[$X,$Y]],[[$X,$Y],[$Xp,$Yp]]]}" ;;
        "Z")  geom="{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$X,$Y,$ZVAL]],[[$X,$Y,$ZVAL],[$Xp,$Yp,$ZVAL]]]}" ;;
        "M")  geom="{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$M0],[$X,$Y,$M1]],[[$X,$Y,$M0],[$Xp,$Yp,$M1]]]}" ;;
        "ZM") geom="{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$ZVAL,$M0],[$X,$Y,$ZVAL,$M1]],[[$X,$Y,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1]]]}" ;;
      esac ;;
    MULTIPOLYGON)
      case "$var" in
        "")   geom="{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym],[$X,$Ym],[$X,$Y],[$Xm,$Y],[$Xm,$Ym]]],[[[$X,$Y],[$Xp,$Y],[$Xp,$Yp],[$X,$Yp],[$X,$Y]]]]}" ;;
        "Z")  geom="{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$ZVAL],[$X,$Ym,$ZVAL],[$X,$Y,$ZVAL],[$Xm,$Y,$ZVAL],[$Xm,$Ym,$ZVAL]]],[[[$X,$Y,$ZVAL],[$Xp,$Y,$ZVAL],[$Xp,$Yp,$ZVAL],[$X,$Yp,$ZVAL],[$X,$Y,$ZVAL]]]]}" ;;
        "M")  geom="{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$M0],[$X,$Ym,$M0],[$X,$Y,$M1],[$Xm,$Y,$M1],[$Xm,$Ym,$M0]]],[[[$X,$Y,$M0],[$Xp,$Y,$M0],[$Xp,$Yp,$M1],[$X,$Yp,$M1],[$X,$Y,$M0]]]]}" ;;
        "ZM") geom="{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$ZVAL,$M0],[$X,$Ym,$ZVAL,$M0],[$X,$Y,$ZVAL,$M1],[$Xm,$Y,$ZVAL,$M1],[$Xm,$Ym,$ZVAL,$M0]]],[[[$X,$Y,$ZVAL,$M0],[$Xp,$Y,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1],[$X,$Yp,$ZVAL,$M1],[$X,$Y,$ZVAL,$M0]]]]}" ;;
      esac ;;
    GEOMETRYCOLLECTION)
      case "$var" in
        "")
          geom="{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}]}" ;;
        "Z")
          geom="{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}]}" ;;
        "M")
          geom="{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$M0]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$M0],[$Xp,$Yp,$M1]]}]}" ;;
        "ZM")
          geom="{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL,$M0]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL,$M0],[$Xp,$Yp,$ZVAL,$M1]]}]}" ;;
      esac ;;
  esac

  cat > "$tmp" <<JSON
{
  "type": "FeatureCollection",
  "name": "tmp_${fam}_${var}",
  "features": [{
    "type": "Feature",
    "geometry": $geom,
    "properties": { "name": "voorbeeld" }
  }]
}
JSON

  echo "$tmp"
}

# Aanmaak en append
for fam in "${families[@]}"; do
  for var in "${variants[@]}"; do
    lname="$(echo "${fam,,}")" ; [[ -n "$var" ]] && lname="${lname}_$(echo "${var,,}")"
    wkb="${fam}${var}"
    dim="$(dim_for "$var")"

    # 1) Maak lege laag met juiste type en CRS
    create_flag=""
    [[ -f "$OUT_GPKG" ]] && create_flag="-update"
    ogr2ogr -f GPKG "$OUT_GPKG" $create_flag \
      -nln "$lname" -nlt "$wkb" -a_srs "EPSG:${EPSG_CODE}" \
      "$EMPTY_GJ"

    # 2) Tijdelijke GeoJSON met voorbeeld-feature
    TMPGJ="$(make_tmp_geojson "$fam" "$var")"

    # 3) Append de feature, met geforceerde dimensie
    ogr2ogr -f GPKG "$OUT_GPKG" -update -append \
      -nln "$lname" \
      -a_srs "EPSG:${EPSG_CODE}" \
      -dim "$dim" \
      "$TMPGJ"

    rm -f "$TMPGJ"
    echo "→ Laag '$lname' aangemaakt + GeoJSON-voorbeeld toegevoegd (dim=$dim)."
  done
done

rm -f "$EMPTY_GJ"

echo
echo "✅ Klaar. GeoPackage staat in: $OUT_GPKG"
echo "▶ Inspecteer:"
echo "   ogrinfo \"$OUT_GPKG\" -al -geom=SUMMARY | sed -n '1,200p'"
