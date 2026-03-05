
#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# PDOK GeoPackage Testset (Amersfoort / RD New) - bash only
# Bronnen: JSON-FG + GML | Converter: uitsluitend GDAL/ogr2ogr
# ------------------------------------------------------------

OUT_DIR="out"
SRC_DIR="src"
GPKG="${OUT_DIR}/pdok_amersfoort_test.gpkg"

# RD New referentiepunt (Onze Lieve Vrouwetoren)
RD_X=155000.0
RD_Y=463000.0

# Kleine offsets (meters) rond het referentiepunt (5 punten)
OFFS=(
  "5 5"
  "10 -5"
  "-15 12"
  "20 -20"
  "-25 -10"
)

# Hulpfunctie: float optellen met awk
addf() { awk -v a="$1" -v b="$2" 'BEGIN{printf("%.3f", a+b)}'; }

rm -rf "${OUT_DIR}" "${SRC_DIR}"
mkdir -p "${OUT_DIR}" "${SRC_DIR}"

# ------------------------------------------------------------
# 1) VALID: JSON-FG met Z en compound CRS (RD+NAP) -> OK
#    Laagnaam: valid_point_z_rdnap_ok
# ------------------------------------------------------------
cat > "${SRC_DIR}/valid_point_z_rdnap_ok.json" <<'JSON'
{
  "type": "FeatureCollection",
  "conformsTo": ["http://www.opengis.net/spec/json-fg-1/0.3/core"],
  "features": [
JSON

i=0
for pair in "${OFFS[@]}"; do
  dx=$(awk '{print $1}' <<<"$pair")
  dy=$(awk '{print $2}' <<<"$pair")
  x=$(addf "${RD_X}" "${dx}")
  y=$(addf "${RD_Y}" "${dy}")
  z="1.230"
  comma=","
  [ "$i" -eq 4 ] && comma=""
  cat >> "${SRC_DIR}/valid_point_z_rdnap_ok.json" <<JSON
    {
      "type": "Feature",
      "id": "v1-$i",
      "place": { "type": "Point", "coordinates": [${x}, ${y}, ${z}] },
      "coordRefSys": {
        "type": "CompoundCRS",
        "components": [
          { "type": "OGC", "id": "http://www.opengis.net/def/crs/EPSG/0/28992" },
          { "type": "OGC", "id": "http://www.opengis.net/def/crs/EPSG/0/5709" }
        ]
      },
      "properties": { "note": "Z=hoogte t.o.v. NAP, compound CRS RD+NAP" }
    ${comma}
JSON
  i=$((i+1))
done
echo '  ] }' >> "${SRC_DIR}/valid_point_z_rdnap_ok.json"

# ------------------------------------------------------------
# 2) INVALID: JSON-FG met Z maar GEEN verticaal CRS -> ERROR
#    Laagnaam: invalid_point_z_no_crs
# ------------------------------------------------------------
cat > "${SRC_DIR}/invalid_point_z_no_crs.json" <<'JSON'
{
  "type": "FeatureCollection",
  "conformsTo": ["http://www.opengis.net/spec/json-fg-1/0.3/core"],
  "features": [
JSON

i=0
for pair in "${OFFS[@]}"; do
  dx=$(awk '{print $1}' <<<"$pair")
  dy=$(awk '{print $2}' <<<"$pair")
  # halve offset
  hx=$(awk -v v="$dx" 'BEGIN{printf("%.3f", v/2)}')
  hy=$(awk -v v="$dy" 'BEGIN{printf("%.3f", v/2)}')
  x=$(addf "${RD_X}" "${hx}")
  y=$(addf "${RD_Y}" "${hy}")
  z="0.750"
  comma=","
  [ "$i" -eq 4 ] && comma=""
  cat >> "${SRC_DIR}/invalid_point_z_no_crs.json" <<JSON
    {
      "type": "Feature",
      "id": "i1-$i",
      "place": { "type": "Point", "coordinates": [${x}, ${y}, ${z}] },
      "coordRefSys": { "type": "OGC", "id": "http://www.opengis.net/def/crs/EPSG/0/28992" },
      "properties": { "note": "Z zonder verticaal CRS (alleen RD)" }
    ${comma}
JSON
  i=$((i+1))
done
echo '  ] }' >> "${SRC_DIR}/invalid_point_z_no_crs.json"

# ------------------------------------------------------------
# 3) WARNING/ERROR: GML met POINT ZM (XYZM) ZONDER measure-attributen
#    Laagnaam: warning_point_zm_no_attrs
# ------------------------------------------------------------
cat > "${SRC_DIR}/warning_point_zm_no_attrs.gml" <<'GML'
<?xml version="1.0" encoding="UTF-8"?>
<gml:FeatureCollection
  xmlns:gml="http://www.opengis.net/gml">
  <gml:featureMembers>
GML

for pair in "${OFFS[@]}"; do
  dx=$(awk '{print $1}' <<<"$pair")
  dy=$(awk '{print $2}' <<<"$pair")
  x=$(addf "${RD_X}" "${dx}")
  y=$(addf "${RD_Y}" "${dy}")
  z="1.500"
  m="0.450"
  cat >> "${SRC_DIR}/warning_point_zm_no_attrs.gml" <<GML
    <gml:featureMember>
      <gml:Point srsName="urn:ogc:def:crs:EPSG::28992" srsDimension="4">
        <gml:pos>${x} ${y} ${z} ${m}</gml:pos>
      </gml:Point>
    </gml:featureMember>
GML
done

cat >> "${SRC_DIR}/warning_point_zm_no_attrs.gml" <<'GML'
  </gml:featureMembers>
</gml:FeatureCollection>
GML

# ------------------------------------------------------------
# 4) OK: JSON-FG 2D met measure ALS ATTRIBUUT (unit + meaning)
#    Laagnaam: ok_point_2d_with_measure_attrs
# ------------------------------------------------------------
cat > "${SRC_DIR}/ok_point_2d_with_measure_attrs.json" <<'JSON'
{
  "type": "FeatureCollection",
  "conformsTo": ["http://www.opengis.net/spec/json-fg-1/0.3/core"],
  "features": [
JSON

i=0
for pair in "${OFFS[@]}"; do
  dx=$(awk '{print $1}' <<<"$pair")
  dy=$(awk '{print $2}' <<<"$pair")
  # derde offset
  tx=$(awk -v v="$dx" 'BEGIN{printf("%.3f", v/3)}')
  ty=$(awk -v v="$dy" 'BEGIN{printf("%.3f", v/3)}')
  x=$(addf "${RD_X}" "${tx}")
  y=$(addf "${RD_Y}" "${ty}")
  # measure_value: 0.42 + i*0.01
  mv=$(awk -v i="$i" 'BEGIN{printf("%.2f", 0.42 + i*0.01)}')
  comma=","
  [ "$i" -eq 4 ] && comma=""
  cat >> "${SRC_DIR}/ok_point_2d_with_measure_attrs.json" <<JSON
    {
      "type": "Feature",
      "id": "ok2d-$i",
      "place": { "type": "Point", "coordinates": [${x}, ${y}] },
      "coordRefSys": { "type": "OGC", "id": "http://www.opengis.net/def/crs/EPSG/0/28992" },
      "properties": {
        "measure_value": ${mv},
        "measure_unit": "m",
        "observed_property": "waterLevel",
        "note": "M als attribuut met eenheid/semantiek"
      }
    ${comma}
JSON
  i=$((i+1))
done
echo '  ] }' >> "${SRC_DIR}/ok_point_2d_with_measure_attrs.json"

# ------------------------------------------------------------
# 5) INVALID: JSON-FG met mixed 2D/3D in één laag -> ERROR
#    Laagnaam: invalid_mixed_dimensions
# ------------------------------------------------------------
cat > "${SRC_DIR}/invalid_mixed_dimensions.json" <<'JSON'
{
  "type": "FeatureCollection",
  "conformsTo": ["http://www.opengis.net/spec/json-fg-1/0.3/core"],
  "features": [
JSON

i=0
for pair in "${OFFS[@]}"; do
  dx=$(awk '{print $1}' <<<"$pair")
  dy=$(awk '{print $2}' <<<"$pair")
  x=$(addf "${RD_X}" "${dx}")
  y=$(addf "${RD_Y}" "${dy}")
  if (( i % 2 == 0 )); then
    coords="[${x}, ${y}]"
    note="2D point"
  else
    coords="[${x}, ${y}, 0.900]"
    note="3D point (Z)"
  fi
  comma=","
  [ "$i" -eq 4 ] && comma=""
  cat >> "${SRC_DIR}/invalid_mixed_dimensions.json" <<JSON
    {
      "type": "Feature",
      "id": "mix-$i",
      "place": { "type": "Point", "coordinates": ${coords} },
      "coordRefSys": { "type": "OGC", "id": "http://www.opengis.net/def/crs/EPSG/0/28992" },
      "properties": { "note": "${note}" }
    ${comma}
JSON
  i=$((i+1))
done
echo '  ] }' >> "${SRC_DIR}/invalid_mixed_dimensions.json"

# ------------------------------------------------------------
# Bouw het GeoPackage met uitsluitend GDAL/ogr2ogr
# ------------------------------------------------------------
rm -f "${GPKG}"

# 1) valid Z met compound CRS
ogr2ogr -f GPKG "${GPKG}" "JSONFG:${SRC_DIR}/valid_point_z_rdnap_ok.json" \
  -nln valid_point_z_rdnap_ok

# 2) invalid Z zonder verticaal CRS
ogr2ogr -f GPKG -update -append "${GPKG}" "JSONFG:${SRC_DIR}/invalid_point_z_no_crs.json" \
  -nln invalid_point_z_no_crs

# 3) ZM zonder measure-attributen (GML)
ogr2ogr -f GPKG -update -append "${GPKG}" "${SRC_DIR}/warning_point_zm_no_attrs.gml" \
  -nln warning_point_zm_no_attrs

# 4) 2D met measure als attribuut (OK)
ogr2ogr -f GPKG -update -append "${GPKG}" "JSONFG:${SRC_DIR}/ok_point_2d_with_measure_attrs.json" \
  -nln ok_point_2d_with_measure_attrs

# 5) mixed 2D/3D in één laag (ERROR)
ogr2ogr -f GPKG -update -append "${GPKG}" "JSONFG:${SRC_DIR}/invalid_mixed_dimensions.json" \
  -nln invalid_mixed_dimensions

echo "✅ Klaar: ${GPKG}"
echo "   Lagen en samenvatting:"
ogrinfo -ro -so "${GPKG}"
