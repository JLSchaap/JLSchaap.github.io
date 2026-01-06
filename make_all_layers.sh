
#!/usr/bin/env bash
# Maak een GeoPackage (EPSG:28992, RD New) met alle SF-geometry types (2D/Z/M/ZM),
# voegt per laag 3 voorbeeld-features toe (M=null, 0, 1), en verschuift ALLES
# zodat er geen overlappende features zijn over alle lagen heen.
#
# Grid-logica:
#  - kolommen = geometriefamilies (POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON, GEOMETRYCOLLECTION)
#  - rijen    = varianten ("", "Z", "M", "ZM")
#  - CEL = 3000 m; laag-offset (dx_layer, dy_layer) = (col_idx*CEL, row_idx*CEL)
# Binnen laag:
#  - mflag offset in X: null → 0, 0 → CEL/5, 1 → 2*CEL/5 (dus 0, 600, 1200 m)

set -euo pipefail

OUT_GPKG="${1:-geopackage_all_types_rd.gpkg}"
EPSG_CODE=28992

# Basis (Amersfoort, OLV-toren) + polygon/lijn grootte
BASE_X=155000
BASE_Y=463000
D=5            # half-omvang voor voorbeelden (lijnen/vlakken)

# Z en M voorbeeld
ZVAL=10         # hoogte (Z)
M0=0            # maat 0
M1=1            # maat 1

# Grid celgrootte (meters)
CELL=30
M_OFF_X_NULL=0
M_OFF_X_0=$((CELL/5))     # 600 m bij CELL=3000
M_OFF_X_1=$((2*CELL/5))   # 1200 m

# Vereisten
command -v ogr2ogr >/dev/null 2>&1 || { echo "❌ 'ogr2ogr' niet gevonden"; exit 1; }
command -v ogrinfo >/dev/null 2>&1 || { echo "❌ 'ogrinfo' niet gevonden"; exit 1; }

# Schoon starten
[[ -f "$OUT_GPKG" ]] && rm -f "$OUT_GPKG"

# Lege FeatureCollection om lagen aan te maken
EMPTY_GJ="$(mktemp)"
cat > "$EMPTY_GJ" <<'JSON'
{ "type": "FeatureCollection", "features": [] }
JSON

#families=(POINT LINESTRING POLYGON MULTIPOINT MULTILINESTRING MULTIPOLYGON GEOMETRYCOLLECTION)
families=(POINT LINESTRING POLYGON MULTIPOINT MULTILINESTRING MULTIPOLYGON)
variants=("" "Z" "M" "ZM")
mflags=("null" "0" "1")

# Dimensie per variant
dim_for() {
  case "$1" in
    "")   echo "XY"   ;;
    "Z")  echo "XYZ"  ;;
    "M")  echo "XYM"  ;;
    "ZM") echo "XYZM" ;;
  esac
}

# Index per familie / variant
family_index() {
  case "$1" in
    POINT)             echo 0 ;;
    LINESTRING)        echo 1 ;;
    POLYGON)           echo 2 ;;
    MULTIPOINT)        echo 3 ;;
    MULTILINESTRING)   echo 4 ;;
    MULTIPOLYGON)      echo 5 ;;
    GEOMETRYCOLLECTION)echo 6 ;;
  esac
}
variant_index() {
  case "$1" in
    "")   echo 0 ;;
    "Z")  echo 1 ;;
    "M")  echo 2 ;;
    "ZM") echo 3 ;;
  esac
}

# Laag-offset (dx_layer, dy_layer) vanuit gridpositie
layer_offset() {
  local fam="$1" ; local var="$2"
  local c=$(family_index "$fam")
  local r=$(variant_index "$var")
  local dx=$((c * CELL))
  local dy=$((r * CELL))
  echo "$dx $dy"
}

# M-offset in X (binnen laag)
m_offset_x() {
  case "$1" in
    "null") echo "$M_OFF_X_NULL" ;;
    "0")    echo "$M_OFF_X_0"    ;;
    "1")    echo "$M_OFF_X_1"    ;;
  esac
}

# Geometrie JSON genereren met offsets toegepast
geom_json() {
  local fam="$1" ; local var="$2" ; local mflag="$3"
  local dim="$(dim_for "$var")"
  # laag-grid offset
  read DX_LAYER DY_LAYER <<< "$(layer_offset "$fam" "$var")"
  # binnen-laag M-offset in X
  local DX_M="$(m_offset_x "$mflag")"
  local X=$((BASE_X + DX_LAYER + DX_M))
  local Y=$((BASE_Y + DY_LAYER))
  local Xm=$((X - D)) ; local Ym=$((Y - D))
  local Xp=$((X + D)) ; local Yp=$((Y + D))

  # M-waarde in coördinaat: GeoJSON kent geen M; we gebruiken de n-de coördinaat en forceren -dim XYM/XYZM bij append.
  # Voor mflag='null' gebruiken we M=0 in coördinaat en zetten attribuut 'm_value=null'.
  local MVAL=0
  [[ "$mflag" == "1" ]] && MVAL="$M1"  # 1
  [[ "$mflag" == "0" ]] && MVAL="$M0"  # 0

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

# Tijdelijke GeoJSON met 1 feature + attributen (incl. json_src en omschrijving)
make_tmp_geojson() {
  local fam="$1" ; local var="$2" ; local mflag="$3"
  local lname="${fam,,}" ; [[ -n "$var" ]] && lname="${lname}_$(echo "${var,,}")"
  local geom="$(geom_json "$fam" "$var" "$mflag")"
  local geom_str="${geom//\"/\\\"}"   # escape quotes voor json_src string
  local descr="Voorbeeld ${fam}${var} M=${mflag} RD New met offsets"
  local m_val_json; [[ "$mflag" == "null" ]] && m_val_json="null" || m_val_json="$mflag"

  local tmp="$(mktemp --suffix=.geojson)"
  cat > "$tmp" <<JSON
{
  "type": "FeatureCollection",
  "name": "tmp_${lname}_${mflag}",
  "features": [{
    "type": "Feature",
    "geometry": $geom,
    "properties": {
      "name": "${lname}_${mflag}",
      "descr": "$descr",
      "m_value": $m_val_json,
      "json_src": "$geom_str"
    }
  }]
}
JSON
  echo "$tmp"
}

# Kolommen schema-matig toevoegen via SQL (als al aanwezig -> negeer fout)
ensure_fields() {
  local lname="$1"
  for stmt in \
    "ALTER TABLE \"$lname\" ADD COLUMN name TEXT" \
    "ALTER TABLE \"$lname\" ADD COLUMN descr TEXT" \
    "ALTER TABLE \"$lname\" ADD COLUMN m_value INTEGER" \
    "ALTER TABLE \"$lname\" ADD COLUMN json_src TEXT"
  do
    ogrinfo -quiet -update "$OUT_GPKG" -sql "$stmt" || true
  done
}

# === Aanmaak en append (met grid-offsets) =====================================
for fam in "${families[@]}"; do
  for var in "${variants[@]}"; do
    lname="$(echo "${fam,,}")" ; [[ -n "$var" ]] && lname="${lname}_$(echo "${var,,}")"
    wkb="${fam}${var}"
    dim="$(dim_for "$var")"

    # 1) Laag aanmaken
    create_flag=""
    [[ -f "$OUT_GPKG" ]] && create_flag="-update"
    ogr2ogr -f GPKG "$OUT_GPKG" $create_flag \
      -nln "$lname" -nlt "$wkb" -a_srs "EPSG:${EPSG_CODE}" \
      "$EMPTY_GJ"

    # 2) Schema-velden garanderen
    ensure_fields "$lname"

    # 3) Append 3 features (M=null,0,1) met per-laag + per-feature offsets toegepast
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

    echo "→ Laag '$lname' aangemaakt + 3 features toegevoegd (dim=$dim, grid offsets toegepast)."
  done
done

rm -f "$EMPTY_GJ"

echo
echo "✅ Klaar. Geen overlap over alle lagen heen."
echo "▶ Controleer snel:"
echo "   ogrinfo \"$OUT_GPKG\" -al -geom=SUMMARY | sed -n '1,300p'"
