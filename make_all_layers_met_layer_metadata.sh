
#!/usr/bin/env bash
# GeoPackage met GDAL-sample naamgeving (…2d/…3d), schema-velden, laag-metadata
# en ruimtelijke spreiding (geen overlap). Metadata JSON gebruikt 'mime_type'.

set -euo pipefail

OUT_GPKG="${1:-gdal_like_sample_rd.gpkg}"
EPSG_CODE=28992
BASE_X=155000
BASE_Y=463000
D=50
ZVAL=10
CELL=3000
M_OFF_X_NULL=0
M_OFF_X_0=$((CELL/5))
M_OFF_X_1=$((2*CELL/5))

command -v ogr2ogr >/dev/null || { echo "❌ 'ogr2ogr' niet gevonden"; exit 1; }
command -v ogrinfo >/dev/null || { echo "❌ 'ogrinfo' niet gevonden"; exit 1; }

[[ -f "$OUT_GPKG" ]] && rm -f "$OUT_GPKG"

# 0) Seed-laag zodat .gpkg bestaat
EMPTY_GJ="$(mktemp --suffix=.geojson)"
cat > "$EMPTY_GJ" <<'JSON'
{ "type": "FeatureCollection", "features": [] }
JSON
ogr2ogr -f GPKG "$OUT_GPKG" "$EMPTY_GJ" -nln seed2d -nlt POINT -a_srs "EPSG:${EPSG_CODE}"

families=(POINT)
suffixes=("2d" "3d")
mflags=("null" "0" "1")

dim_for(){ [[ "$1" == "2d" ]] && echo XY || echo XYZ; }
family_index(){ case "$1" in
  POINT) echo 0;; LINESTRING) echo 1;; POLYGON) echo 2;;
  MULTIPOINT) echo 3;; MULTILINESTRING) echo 4;; MULTIPOLYGON) echo 5;;
  GEOMETRYCOLLECTION) echo 6;; esac; }
suffix_index(){ [[ "$1" == "2d" ]] && echo 0 || echo 1; }
layer_offset(){ local c=$(family_index "$1"); local r=$(suffix_index "$2"); echo $((c*CELL)) $((r*CELL)); }
m_offset_x(){ case "$1" in null) echo "$M_OFF_X_NULL";; 0) echo "$M_OFF_X_0";; 1) echo "$M_OFF_X_1";; esac; }

geom_json(){
  local fam="$1" suf="$2" mflag="$3" dim="$(dim_for "$suf")"
  read DX DY <<< "$(layer_offset "$fam" "$suf")"
  local DXM="$(m_offset_x "$mflag")"
  local X=$((BASE_X + DX + DXM)); local Y=$((BASE_Y + DY))
  local Xm=$((X - D)); local Ym=$((Y - D)); local Xp=$((X + D)); local Yp=$((Y + D))
  case "$fam" in
    POINT) [[ "$dim" == XY ]] && echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y]}" \
                               || echo "{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]}";;
    LINESTRING) [[ "$dim" == XY ]] && echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" \
                                    || echo "{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}";;
    POLYGON) [[ "$dim" == XY ]] && echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym],[$Xp,$Ym],[$Xp,$Yp],[$Xm,$Yp],[$Xm,$Ym]]]}" \
                                 || echo "{\"type\":\"Polygon\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$Xp,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL],[$Xm,$Yp,$ZVAL],[$Xm,$Ym,$ZVAL]]]}";;
    MULTIPOINT) [[ "$dim" == XY ]] && echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}" \
                                    || echo "{\"type\":\"MultiPoint\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}";;
    MULTILINESTRING) [[ "$dim" == XY ]] && echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym],[$X,$Y]],[[$X,$Y],[$Xp,$Yp]]]}" \
                                         || echo "{\"type\":\"MultiLineString\",\"coordinates\":[[[$Xm,$Ym,$ZVAL],[$X,$Y,$ZVAL]],[[$X,$Y,$ZVAL],[$Xp,$Yp,$ZVAL]]]}";;
    MULTIPOLYGON) [[ "$dim" == XY ]] && echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym],[$X,$Ym],[$X,$Y],[$Xm,$Y],[$Xm,$Ym]]],[[[$X,$Y],[$Xp,$Y],[$Xp,$Yp],[$X,$Yp],[$X,$Y]]]]}" \
                                      || echo "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[$Xm,$Ym,$ZVAL],[$X,$Ym,$ZVAL],[$X,$Y,$ZVAL],[$Xm,$Y,$ZVAL],[$Xm,$Ym,$ZVAL]]],[[[$X,$Y,$ZVAL],[$Xp,$Y,$ZVAL],[$Xp,$Yp,$ZVAL],[$X,$Yp,$ZVAL],[$X,$Y,$ZVAL]]]]}";;
    GEOMETRYCOLLECTION) [[ "$dim" == XY ]] && echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym],[$Xp,$Yp]]}]}" \
                                           || echo "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[$X,$Y,$ZVAL]},{\"type\":\"LineString\",\"coordinates\":[[$Xm,$Ym,$ZVAL],[$Xp,$Yp,$ZVAL]]}]}" ;;
  esac
}

make_tmp_geojson(){
  local fam="$1" suf="$2" mflag="$3"
  local lname="$(echo "${fam,,}")${suf}"
  local geom="$(geom_json "$fam" "$suf" "$mflag")"
  local geom_str="${geom//\"/\\\"}"
  local descr="Voorbeeld ${lname} (RD grid-offset); M=${mflag}"
  local m_json; [[ "$mflag" == "null" ]] && m_json="null" || m_json="$mflag"
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
      "m_value": $m_json,
      "json_src": "$geom_str"
    }
  }]
}
JSON
  echo "$tmp"
}

ensure_fields(){
  local ln="$1"
  for stmt in \
    "ALTER TABLE \"$ln\" ADD COLUMN name TEXT" \
    "ALTER TABLE \"$ln\" ADD COLUMN descr TEXT" \
    "ALTER TABLE \"$ln\" ADD COLUMN m_value INTEGER" \
    "ALTER TABLE \"$ln\" ADD COLUMN json_src TEXT"
  do ogrinfo -quiet -update "$OUT_GPKG" -sql "$stmt" || true; done
}

update_contents(){
  local ln="$1" id="$2" desc="$3"
  ogrinfo -quiet -update "$OUT_GPKG" -sql "UPDATE gpkg_contents SET identifier='$id', description='$desc' WHERE table_name='$ln';" || true
}

ensure_metadata_extension(){
  # Maak extensietabellen + registratie. Kolomnaam = 'mime_type' (volgens spec).
  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    CREATE TABLE IF NOT EXISTS gpkg_metadata (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      md_scope TEXT NOT NULL,
      md_standard_uri TEXT,
      mime_type TEXT NOT NULL,
      metadata TEXT NOT NULL
    );" || true

  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    CREATE TABLE IF NOT EXISTS gpkg_metadata_reference (
      reference_scope TEXT NOT NULL,
      table_name TEXT,
      column_name TEXT,
      row_id_value INTEGER,
      timestamp DATETIME NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
      md_file_id INTEGER NOT NULL,
      md_parent_id INTEGER
    );" || true

  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    CREATE TABLE IF NOT EXISTS gpkg_extensions (
      table_name TEXT,
      column_name TEXT,
      extension_name TEXT NOT NULL,
      definition TEXT NOT NULL,
      scope TEXT NOT NULL
    );" || true

  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    INSERT INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
    SELECT NULL, NULL, 'gpkg_metadata',
           'http://www.geopackage.org/spec/#extension_metadata','read-write'
    WHERE NOT EXISTS (SELECT 1 FROM gpkg_extensions WHERE extension_name='gpkg_metadata');" || true

  # Defensieve stap: kolom 'mime_type' toevoegen wanneer schema ouder is (faalt stil als kolom al bestaat)
  #ogrinfo -quiet -update "$OUT_GPKG" -sql "ALTER TABLE gpkg_metadata ADD COLUMN mime_type TEXT" || true
}

add_layer_metadata(){
  local ln="$1" fam="$2" suf="$3" dim="$(dim_for "$suf")"
  local zsem="$( [[ "$dim" == XYZ ]] && echo "hoogte (meter)" || echo "niet aanwezig" )"
  local md_json="{\"layer\":\"$ln\",\"family\":\"$fam\",\"dimension\":\"$dim\",\"crs\":\"EPSG:$EPSG_CODE\",\"z_semantics\":\"$zsem\",\"m_semantics\":\"attribuut m_value (null/0/1)\",\"origin_rd\":{\"x\":$BASE_X,\"y\":$BASE_Y},\"cell_m\":$CELL}"
  # Insert metadata met kolom 'mime_type'
  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    INSERT INTO gpkg_metadata (md_scope, md_standard_uri, mime_type, metadata)
    VALUES ('dataset','https://www.geopackage.org/spec/','application/json','$md_json');" || true
  # Referentie naar laag (via subquery op MAX(id))
  ogrinfo -quiet -update "$OUT_GPKG" -sql "
    INSERT INTO gpkg_metadata_reference (reference_scope, table_name, column_name, row_id_value, md_file_id, md_parent_id)
    SELECT 'table', '$ln', NULL, NULL, (SELECT MAX(id) FROM gpkg_metadata), NULL;" || true
}

# 1) Metadata-extensie aanmaken
ensure_metadata_extension

# 2) Seed-tabel opruimen
ogrinfo -quiet -update "$OUT_GPKG" -sql "DROP TABLE seed2d" || true

# 3) Lagen bouwen en vullen
for fam in "${families[@]}"; do
  for suf in "${suffixes[@]}"; do
    lname="$(echo "${fam,,}")${suf}"
    wkb="${fam}$( [[ "$suf" == "3d" ]] && echo Z || echo )"
    dim="$(dim_for "$suf")"

    ogr2ogr -f GPKG "$OUT_GPKG" -update -nln "$lname" -nlt "$wkb" -a_srs "EPSG:${EPSG_CODE}" "$EMPTY_GJ"
    ensure_fields "$lname"

    for mflag in "${mflags[@]}"; do
      tmpgj="$(make_tmp_geojson "$fam" "$suf" "$mflag")"
      ogr2ogr -f GPKG "$OUT_GPKG" -update -append -nln "$lname" -a_srs "EPSG:${EPSG_CODE}" -dim "$dim" -addfields "$tmpgj"
      rm -f "$tmpgj"
    done

    update_contents "$lname" "$lname" "Demo-laag (${fam}, ${suf})"
    add_layer_metadata "$lname" "$fam" "$suf"

    echo "→ $lname klaar."
  done
done

rm -f "$EMPTY_GJ"
echo "✅ Klaar: $OUT_GPKG"
echo "▶ Test: ogrinfo -al -so \"$OUT_GPKG\""
``
