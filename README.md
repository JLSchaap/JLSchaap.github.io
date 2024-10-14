# Demo Urls

## [OGC API Mapbox Vector Tiles](https://docs.ogc.org/is/20-057/20-057.html#ats_mvt) and [OGC API - Styles](https://ogcapi.ogc.org/styles/)

* [PDOK vector tile demo](https://pdok.github.io/vectortile-demo-viewer), [sources are available](https://github.com/PDOK/vectortile-demo-viewer)
* [PDOK Viewer (TOP10NL)](https://app.pdok.nl/viewer/#x=160000.00&y=455000.00&z=9.0145&background=Luchtfoto&layers=a4dde400-00ab-4fc2-9b5d-bba058cac630;BRT%20TOP10NL%20-%20Tiles)
* [Edit styles in maputnik](https://jlschaap.github.io/maputnik/?layer=298854420%7E0#14.05/52.15531/5.39044)
* [Legend from style](https://api.pdok.nl/brt/top10nl/ogc/v1/styles/brt_top10nl__webmercatorquad?f=html)

# [OGC Api features](https://ogcapi.ogc.org/features/)

## Find Landingspage [Open Graph protocol](https://ogp.me/) and [sidemap](https://api.pdok.nl/sitemap.xml)

* [Via Index](https://api.pdok.nl/) -[OGC API - Records](https://ogcapi.ogc.org/records/)  
  * [PDOK](https://www.pdok.nl/ogc-apis/-/article/basisregistratie-topografie-brt-topnl)  *
  * [NGR](https://www.nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/search?any=BRT%20TOP10NL%20OGC%20API)  
* Via Search-engine
  * [duck duck go](https://duckduckgo.com/?q=ogc+api+top10nl+pdok&t=h_&ia=web)
  * [Google](https://www.google.nl/search?q=pdok+top10nl+ogc+api)
* [Via announcement](https://www.google.nl/search?q=PDOK+lanceert+de+BRT+TOP10NL+in+OGC+API%E2%80%99s)

## [Landingpage](https://docs.ogc.org/is/17-069r4/17-069r4.html#_api_landing_page)

## [Collections](https://docs.ogc.org/is/17-069r4/17-069r4.html#_feature_collections_rootcollections)

* [building collection: 'BRT TOP10NL - Gebouw vlak'](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak)

## [Items Feature by Parameter bbox](https://docs.ogc.org/is/17-069r4/17-069r4.html#_features_rootcollectionscollectioniditems)

* [building items BBOX: 'BRT TOP10NL - Gebouw vlak'](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000&f=html)
* [BGT - building items BBOX:Basisregistratie Grootschalige Topografie - Pand (PND)](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000)
* [BAG - building items BBOX:Basisregistratie Adressen en Gebouwen - Pand (demo))](https://api.pdok.nl/lv/bag/ogc/v1-preprod/collections/pand/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000)

[Item Feature by id](https://docs.ogc.org/is/17-069r4/17-069r4.html#_features_rootcollectionscollectioniditems)

[TOP10NL Item](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?lokaal_id=103018712)
[BGT item](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?lokaal_id=G0307.b94c2bd2f8f44429a23bb46202b1627b)
[BAG Item](https://api.pdok.nl/lv/bag/ogc/v1-preprod/collections/pand/items?identificatie=0307100000333887)

[TOP10NL by key from PDOK-API](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items/bffedb27-48f8-50d9-a725-66f6024ec569)
[BGT by key from PDOK-API](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items/6f694250-fbb5-52f3-8761-3cf564846700)
[BAG by key from PDOK-API](https://api.pdok.nl/lv/bag/ogc/v1-preprod/collections/pand/items/67b6065c-b9d5-5fce-9b8f-bd12336acf0f)

## [OGC Api features](https://ogcapi.ogc.org/features/) Download Grid for [Cityjson](https://www.cityjson.org/) Zip

* [building collection (GRID):  '3D Basisvoorziening - 3D Objecten Gebouwen'](https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1/collections/basisbestand_gebouwen)

# [OGC API - 3D GeoVolumes](https://ogcapi.ogc.org/geovolumes/)

* [building 3d tiles :'3D Basisvoorziening - 3D Tiles Gebouwen'](https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1/collections/gebouwen/3dtiles)

* [PDOK 3D - Viewer](https://app.pdok.nl/3d-viewer/#x=186070.65&y=319298.78&alt=131&range=288&heading=200&pitch=-11&roll=360&background=Luchtfoto&layers=)

# Developer

* [Cloud Native OGC APIs server, written in Go](https://github.com/PDOK/gokoala) with [Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) [for OGC API](https://github.com/PDOK/ogcapi-operator)
* [PDOK GeoPackage Valdidator](https://github.com/PDOK/geopackage-validator)

___

[![check markdown links](https://github.com/JLSchaap/JLSchaap.github.io/actions/workflows/checkMarkdown.yml/badge.svg)](https://github.com/JLSchaap/JLSchaap.github.io/actions/workflows/checkMarkdown.yml)
