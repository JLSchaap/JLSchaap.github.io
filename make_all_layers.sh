#!/usr/bin/env bash
# Maak een GeoPackage met alle Simple Feature geometrie-types (2D, Z, M, ZM).
# Auteur: jij 😉
# Gebruik: ./make_all_layers_gpkg.sh [/pad/naar/geopackage_all_types.gpkg] [EPSG]
# Voorbeeld: ./make_all_layers_gpkg.sh geopackage_all_types.gpkg 4326

set -euo pipefail

# === Instelbare parameters (via CLI of defaults) ==============================
OUT_GPKG="${1:-geopackage_all_types.gpkg}"
EPSG_CODE="${2:-28992}"          # Zet bijv. op 28992 voor RD New (Nederland)

ADD_NAME_FIELD=true             # Zet op false als je geen attribuutveld wilt

# === Controle dependencies =====================================================
command -v ogr2ogr >/dev/null 2>&1 || { echo "❌ 'ogr2ogr' niet gevonden in PATH"; exit 1; }
if $ADD_NAME_FIELD; then
  command -v sqlite3 >/dev/null 2>&1 || { echo "❌ 'sqlite3' niet gevonden; zet ADD_NAME_FIELD=false of installeer sqlite3"; exit 1; }
fi

# === Voorbereiding =============================================================
# Leeg GeoJSON (bron) waarmee we lagen kunnen creëren zonder features:
TMP_SRC="$(mktemp)"
cat > "$TMP_SRC" <<'JSON'
{ "type": "FeatureCollection", "features": [] }
JSON

# Bestaand bestand weggooien (schone start)
if [[ -f "$OUT_GPKG" ]]; then
  echo "ℹ️ Verwijder bestaand GeoPackage: $OUT_GPKG"
  rm -f "$OUT_GPKG"
fi

# === Helper: laag toevoegen ====================================================
# add_layer <layer_name> <ogr_wkb_type>
add_layer() {
  local lname="$1"
  local wkbtype="$2"

  # Eerste laag: maakt bestand aan; volgende lagen: -update
  local create_flag
  if [[ -f "$OUT_GPKG" ]]; then
    create_flag=-update
  else
    create_flag=
  fi

  echo "→ Maak laag: ${lname} (type ${wkbtype}, EPSG:${EPSG_CODE})"
  ogr2ogr -f GPKG "$OUT_GPKG" $create_flag \
    -nln "$lname" \
    -nlt "$wkbtype" \
    -a_srs "EPSG:${EPSG_CODE}" \
    "$TMP_SRC"

  # Optioneel: attribuutveld 'name' toevoegen (tekst)
  if $ADD_NAME_FIELD; then
    # Let op: GeoPackage staat één geometry-kolom per tabel toe; ALTER TABLE voor extra attribuut is OK.
    sqlite3 "$OUT_GPKG" "ALTER TABLE \"$lname\" ADD COLUMN name TEXT;"
  fi
}

# === Lijsten geometriefamilies en varianten ===================================
families=(POINT LINESTRING POLYGON MULTIPOINT MULTILINESTRING MULTIPOLYGON GEOMETRYCOLLECTION)
variants=( "" "Z" "M" "ZM" )

# === Alle lagen genereren ======================================================
for fam in "${families[@]}"; do
  for var in "${variants[@]}"; do
    # Laagnaam in lowercase met suffix (bijv. point_zm)
    lname="$(echo "${fam,,}")"
    if [[ -n "$var" ]]; then lname="${lname}_$(echo "${var,,}")"; fi

    # Volledige OGR WKB-type string (bijv. LINESTRINGZM)
    wkb="${fam}${var}"

    add_layer "$lname" "$wkb"
  done
done

# === Opruimen ==================================================================
rm -f "$TMP_SRC"

# === Resultaat tonen ===========================================================
echo
echo "✅ Klaar: alle lagen aangemaakt in ${OUT_GPKG}"
echo "▶ Voorbeeld inspectie:"
echo "  ogrinfo ${OUT_GPKG} -so -al | sed -n '1,120p'"
echo
echo "Tip: open het bestand in QGIS en voeg evt. voorbeeldfeatures toe."
