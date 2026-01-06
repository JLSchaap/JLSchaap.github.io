#!/usr/bin/env bash
# Maak een GeoPackage (EPSG:28992) met alle SF-geometry types (2D/Z/M/ZM),
# voeg per laag 3 voorbeeld-features toe (M = null, 0, 1) en zorg dat de
# extra attributen schema-matig aan elke laag zijn toegevoegd:
#   name (TEXT), descr (TEXT), m_value (INTEGER, NULL toegestaan), json_src (TEXT)

set -euo pipefail

OUT_GPKG="${1:-geopackage_all_types_rd.gpkg}"
EPSG_CODE=28992
CENTER_X=155000      # Amersfoort (OLV-toren, RD)
CENTER_Y=463000
D=50                 # offset voor lijnen/vlakken
ZVAL=10              # voorbeeld Z (hoogte)
M0=0                 # maat 0
M1=1                 # maat 1

# Vereisten
command -v ogr2ogr >/dev/null 2>&1 || { echo "❌ 'ogr2ogr' niet gevonden"; exit 1; }
command -v ogrinfo >/dev/null 2>&1 || { echo "❌ 'ogrinfo' niet gevonden"; exit 1; }

# Schoon starten
[[ -f "$OUT_GPKG" ]] && rm -f "$OUT_GPKG"

# Lege FeatureCollection om lagen te creëren
EMPTY_GJ="$(mktemp)"
cat > "$EMPTY_GJ" <<'JSON'
{ "type": "FeatureCollection", "features": [] }
JSON

families=(POINT )
variants=("" "Z" "M" "ZM")
mflags=("null" "0" "1")

dim_for() {
  case "$1" in
    "")   echo "XY"   ;;
    "Z")  echo "XYZ"  ;;
    "M")  echo "XYM"  ;;
    "ZM") echo "XYZM" ;;
  esac
}

# --- Geometrie als JSON (string) genereren per family/variant/mflag ---
geom_json() {
  local fam="$1" ; local var="$2" ; local mflag="$3"
  local X="$CENTER_X" ; local Y="$CENTER_Y"
  local Xm=$((CENTER_X - D)) ; local Ym=$((CENTER_Y - D))
  local Xp=$((CENTER_X + D)) ; local Yp=$((CENTER_Y + D))
  local MVAL="$M0"; [[ "$mflag" == "1" ]] && MVAL="$M1"

  case "$fam" in
    POINT)
      case "$var" in
        "")   echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y]}" ;;
        "Z")  echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]}" ;;
        "M")  echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y,$MVAL]}" ;;
        "ZM") echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL,$MVAL]}" ;;
      esac ;;

    LINESTRING)
      case "$var" in
        "")   echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" ;;
        "Z")  echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}" ;;
        "M")  echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$MVAL],[$Xp,$Yp,$MVAL]]}" ;;
        "ZM") echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL,$MVAL],[$Xp,$Yp,$ZVAL,$MVAL]]}" ;;
      esac ;;

    POLYGON)
      case "$var" in
        "")   echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym],[$Xp,$Ym],[$Xp,$Yp],[$Xm,$Yp],[$Xm,$Ym]]]}" ;;
        "Z")  echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$Xp,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL],[$Xm,$Yp,$ZVAL],[$Xm,$Ym,$ZVAL]]]}" ;;
        "M")  echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$MVAL],[$Xp,$Ym,$MVAL],[$Xp,$Yp,$MVAL],[$Xm,$Yp,$MVAL],[$Xm,$Ym,$MVAL]]]}" ;;
        "ZM") echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$ZVAL,$MVAL],[$Xp,$Ym,$ZVAL,$MVAL],[$Xp,$Yp,$ZVAL,$MVAL],[$Xm,$Yp,$ZVAL,$MVAL],[$Xm,$Ym,$ZVAL,$MVAL]]]}" ;;
      esac ;;

    MULTIPOINT)
      case "$var" in
        "")   echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" ;;
        "Z")  echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}" ;;
        "M")  echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$MVAL],[$Xp,$Yp,$MVAL]]}" ;;
        "ZM") echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$ZVAL,$MVAL],[$Xp,$Yp,$ZVAL,$MVAL]]}" ;;
      esac ;;

    MULTILINESTRING)
      case "$var" in
        "")   echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym],[$X,$Y]],[[$X,$Y],[$Xp,$Yp]]]}" ;;
        "Z")  echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$X,$Y,$ZVAL]],[[$X,$Y,$ZVAL],[$Xp,$Yp,$ZVAL]]]}" ;;
        "M")  echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$MVAL],[$X,$Y,$MVAL]],[[$X,$Y,$MVAL],[$Xp,$Yp,$MVAL]]]}" ;;
        "ZM") echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$ZVAL,$MVAL],[$X,$Y,$ZVAL,$MVAL]],[[$X,$Y,$ZVAL,$MVAL],[$Xp,$Yp,$ZVAL,$MVAL]]]}" ;;
      esac ;;

    MULTIPOLYGON)
      case "$var" in
        "")   echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym],[$X,$Ym],[$X,$Y],[$Xm,$Y],[$Xm,$Ym]]],[[[$X,$Y],[$Xp,$Y],[$Xp,$Yp],[$X,$Yp],[$X,$Y]]]]}" ;;
        "Z")  echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$ZVAL],[$X,$Ym,$ZVAL],[$X,$Y,$ZVAL],[$Xm,$Y,$ZVAL],[$Xm,$Ym,$ZVAL]]],[[[$X,$Y,$ZVAL],[$Xp,$Y,$ZVAL],[$Xp,$Yp,$ZVAL],[$X,$Yp,$ZVAL],[$X,$Y,$ZVAL]]]]}" ;;
        "M")  echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$MVAL],[$X,$Ym,$MVAL],[$X,$Y,$MVAL],[$Xm,$Y,$MVAL],[$Xm,$Ym,$MVAL]]],[[[$X,$Y,$MVAL],[$Xp,$Y,$MVAL],[$Xp,$Yp,$MVAL],[$X,$Yp,$MVAL],[$X,$Y,$MVAL]]]]}" ;;
        "ZM") echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$ZVAL,$MVAL],[$X,$Ym,$ZVAL,$MVAL],[$X,$Y,$ZVAL,$MVAL],[$Xm,$Y,$ZVAL,$MVAL],[$Xm,$Ym,$ZVAL,$MVAL]]],[[[$X,$Y,$ZVAL,$MVAL],[$Xp,$Y,$ZVAL,$MVAL],[$Xp,$Yp,$ZVAL,$MVAL],[$X,$Yp,$ZVAL,$MVAL],[$X,$Y,$ZVAL,$MVAL]]]]}" ;;
      esac ;;

    GEOMETRYCOLLECTION)
      case "$var" in
        "")
          echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}]}" ;;
        "Z")
          echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}]}" ;;
        "M")
          echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$M0]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$M0],[$Xp,$Yp,$M1]]}]}" ;;
        "ZM")
          echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[${X},${Y},${ZVAL},${M0}]},{\"type\":\"LineString\",\"coordinates\":[[${Xm},${Ym},${ZVAL},${M0}],[${Xp},${Yp},${ZVAL},${M1}]]}]}" ;;
      esac ;;
  esac
}

# Tijdelijk GeoJSON maken met 1 feature + gevraagde attributen
make_tmp_geojson() {
  local fam="$1" ; local var="$2" ; local mflag="$3"
  local lname="${fam,,}" ; [[ -n "$var" ]] && lname="${lname}_$(echo "${var,,}")"
  local geom="$(geom_json "$fam" "$var" "$mflag")"
  local geom_str="${geom//\"/\\\"}"                      # escape quotes voor json_src string
  local descr="Voorbeeld ${fam}${var} nabij OLV-toren (RD: ${CENTER_X}, ${CENTER_Y}); M=${mflag}"
  local m_val_json
  if [[ "$mflag" == "null" ]]; then m_val_json="null"; else m_val_json="$mflag"; fi

  local tmp="$(mktemp --suffix=.geojson)"
  cat > "$tmp" <<JSON
{
  "type": "FeatureCollection",
  "name": "tmp_${lname}_${mflag}",
  "features": [{
    "type": "Feature",
    "geometry": $geom,
    "properties": {
      "name": "voorbeeld",
      "descr": "$descr",
      "m_value": $m_val_json,
      "json_src": "$geom_str"
    }
  }]
}
JSON
  echo "$tmp"
}

# Kolommen schema-matig toevoegen via SQL (als ze al bestaan -> negeer de fout)
ensure_fields() {
  local lname="$1"
  # Gebruik de SQLite-ALTERs via GPKG-driver (SQL direct tegen database)
  # NB: geen geometry-functies gebruikt, enkel kolom-aanmaak.
  for stmt in \
    "ALTER TABLE \"$lname\" ADD COLUMN name TEXT" \
    "ALTER TABLE \"$lname\" ADD COLUMN descr TEXT" \
    "ALTER TABLE \"$lname\" ADD COLUMN m_value INTEGER" \
    "ALTER TABLE \"$lname\" ADD COLUMN json_src TEXT"
  do
    ogrinfo -quiet -update "$OUT_GPKG" -sql "$stmt" || true
  done
}

# Aanmaak en append
for fam in "${families[@]}"; do
  for var in "${variants[@]}"; do
    lname="$(echo "${fam,,}")" ; [[ -n "$var" ]] && lname="${lname}_$(echo "${var,,}")"
    wkb="${fam}${var}"
    dim="$(dim_for "$var")"

    # 1) Maak lege laag met juiste type/CRS
    create_flag=""
    [[ -f "$OUT_GPKG" ]] && create_flag="-update"
    ogr2ogr -f GPKG "$OUT_GPKG" $create_flag \
      -nln "$lname" -nlt "$wkb" -a_srs "EPSG:${EPSG_CODE}" \
      "$EMPTY_GJ"

    # 2) Zorg dat de attribuutvelden schema-matig bestaan
    ensure_fields "$lname"

    # 3) Append drie voorbeeld-features (M = null, 0, 1), velden worden zo nodig ook via -addfields aangemaakt
    for mflag in "${mflags[@]}"; do
      TMPGJ="$(make_tmp_geojson "$fam" "$var" "$mflag")"
      ogr2ogr -f GPKG "$OUT_GPKG" -update -append \
        -nln "$lname" \
        -a_srs "EPSG:${EPSG_CODE}" \
        -dim "$dim" \
        -addfields \
        "$TMPGJ"
      rm -f "$TMPGJ"
    done

    echo "→ Laag '$lname' aangemaakt + 3 features toegevoegd (dim=$dim)."
  done
done

rm -f "$EMPTY_GJ"

echo
echo "✅ Klaar. GeoPackage staat in: $OUT_GPKG"
echo "▶ Inspecteer schema en records bijv.:"
echo "   ogrinfo \"$OUT_GPKG\" point_zm -al -geom=SUMMARY | sed -n '1,160p'"
