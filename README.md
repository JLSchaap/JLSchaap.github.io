# Rijkswaterstaat OGC APIs

* [RWS Digitaal Topografisch Bestand (DTB)](https://api.pdok.nl/rws/digitaaltopografischbestand/ogc/v1)
    * [RWS DTB Vlakken Item PDOK API Key](https://api.pdok.nl/rws/digitaaltopografischbestand/ogc/v1/collections/vlakken/items/cb39585b-386f-5209-8c2d-a67b65174016)
    * [RWS DTB Vlakken Items (EPSG:28992, limit 10, dtb_id=44722025)](https://api.pdok.nl/rws/digitaaltopografischbestand/ogc/v1/collections/vlakken/items?crs=http%3A%2F%2Fwww.opengis.net%2Fdef%2Fcrs%2FEPSG%2F0%2F28992&limit=10&dtb_id=44722025)
    * [RWS DTB Vlakken Items (dtb_id=44722025)](https://api.pdok.nl/rws/digitaaltopografischbestand/ogc/v1/collections/vlakken/items?dtb_id=44722025)
     
* [RWS NWB Wegen](https://api.pdok.nl/rws/nwbwegen/ogc/v1)
    * [RWS NWB Wegvakken Item (API Key)](https://api.pdok.nl/rws/nwbwegen/ogc/v1/collections/wegvakken/items/dd0a90db-f962-5a90-b1df-b9e0ffebbb09)
    * [RWS NWB Wegvakken Items (wvk_id=601259605)](https://api.pdok.nl/rws/nwbwegen/ogc/v1/collections/wegvakken/items?wvk_id=601259605)
    * [RWS NWB Wegvakken Items (EPSG:28992, limit 10, wvk_id=601259605)](https://api.pdok.nl/rws/nwbwegen/ogc/v1/collections/wegvakken/items?crs=http%3A%2F%2Fwww.opengis.net%2Fdef%2Fcrs%2FEPSG%2F0%2F28992&limit=10&wvk_id=601259605)
 
* [RWS Richtlijn Overstromingsrisico](https://api.pdok.nl/rws/richtlijnoverstromingsrisico/ogc/v1)
* [RWS Richtlijn Stedelijk Afvalwater](https://api.pdok.nl/rws/richtlijnstedelijkafvalwater/ogc/v1)
* [RWS Verkeersscheidingsstelsel](https://api.pdok.nl/rws/verkeersscheidingsstelsel/ogc/v1)

# Developer

* [Cloud Native OGC APIs server, written in Go](https://github.com/PDOK/gokoala) with [Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) [for OGC API](https://github.com/PDOK/ogcapi-operator)
* [PDOK GeoPackage Valdidator](https://github.com/PDOK/geopackage-validator)
* 
# [OGC API Common](https://ogcapi.ogc.org/common/)
## Find Landingspage [Open Graph protocol](https://ogp.me/) and [sidemap](https://api.pdok.nl/sitemap.xml)

* [Via Index](https://api.pdok.nl/) -[OGC API - Records](https://ogcapi.ogc.org/records/)  
  * [PDOK](https://www.pdok.nl/ogc-apis/-/article/basisregistratie-topografie-brt-topnl)  *
  * [NGR](https://www.nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/search?any=BRT%20TOP10NL%20OGC%20API)  
* Via Search-engine
  * [duck duck go](https://duckduckgo.com/?q=ogc+api+top10nl+pdok&t=h_&ia=web)
  * [Google](https://www.google.nl/search?q=pdok+top10nl+ogc+api)
* [Via announcement](https://www.google.nl/search?q=PDOK+lanceert+de+BRT+TOP10NL+in+OGC+API%E2%80%99s)
* 

# [OGC Api Tiles](https://ogcapi.ogc.org/tiles/)

## [OGC API Mapbox Vector Tiles](https://docs.ogc.org/is/20-057/20-057.html#ats_mvt) and [OGC API - Styles](https://ogcapi.ogc.org/styles/)

* [PDOK vector tile demo](https://pdok.github.io/vectortile-demo-viewer), [sources are available](https://github.com/PDOK/vectortile-demo-viewer)
* [PDOK Viewer (TOP10NL)](https://app.pdok.nl/viewer/#x=160000.00&y=455000.00&z=9.0145&background=Luchtfoto&layers=a4dde400-00ab-4fc2-9b5d-bba058cac630;BRT%20TOP10NL%20-%20Tiles)
* [Edit styles in maputnik](https://jlschaap.github.io/maputnik/?layer=298854420%7E0#14.05/52.15531/5.39044)
* [Legend from style](https://api.pdok.nl/brt/top10nl/ogc/v1/styles/brt_top10nl__webmercatorquad?f=html)


# GeoBuzz [match je open PDOK data tot een verrassende combinatie](https://geobuzz.nl/programma/108)

## Kiezen van de ingrediënten (zoeken en vinden)

### Find Landingspage [Open Graph protocol](https://ogp.me/) and [sidemap](https://api.pdok.nl/sitemap.xml)


* Via Search-engine
  * [Google dataset kasteel](https://www.google.nl/search?q=dataset+kasteel)
  * [Google pdok kasteel](https://www.google.nl/search?q=pdok+kasteel)
  * [Google pdok camping ](https://www.google.nl/search?q=pdok+camping)
  * [Google pdok camping bgt ](https://www.google.nl/search?q=pdok+camping+bgt)

* [Via Index](https://api.pdok.nl/) -[OGC API - Records](https://ogcapi.ogc.org/records/)  
  * [PDOK](https://www.pdok.nl/ogc-apis/-/article/basisregistratie-topografie-brt-topnl)
  * [NGR](https://www.nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/search?any=BRT%20TOP10NL%20OGC%20API) 
  * [CSW](https://nationaalgeoregister.nl/geonetwork/srv/dut/csw?service=CSW&version=2.0.2&request=GetRecords&resultType=results&outputSchema=http://www.opengis.net/cat/csw/2.0.2&outputFormat=application/xml&maxRecords=10&typeNames=csw:Record&elementSetName=full&constraintLanguage=CQL_TEXT&constraint_language_version=1.1.0&constraint=AnyText+LIKE+%27BRT%20TOP10NL%20OGC%20AP%27)


   
* [Via announcement](https://www.google.nl/search?q=PDOK+lanceert+de+BRT+TOP10NL+in+OGC+API%E2%80%99s)

### [OGC API Landingpage](https://docs.ogc.org/is/17-069r4/17-069r4.html#_api_landing_page)

## Kastelen
[NGR](https://www.nationaalgeoregister.nl/geonetwork/srv/dut/catalog.search#/search?any=kasteel) 
[Kastelen RCE](https://services.rce.geovoorziening.nl/landschapsatlas/wfs?SERVICE=WFS&REQUEST=GetCapabilities) 


## Punt
* [Top10NL gebouw punt](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_punt) 

## Vlak

<img src="https://images.memorix.nl/rce/thumb/1600x1600/a1337e59-6cbe-aa5c-6ee4-c3f883c4fb0d.jpg" alt="Hoekelum via RCE" width="500" height="400">

* [Hoekelum Top10NL](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?lokaal_id=102557439) 
* [Hoekelum BGT](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?lokaal_id=G0228.fe246f4964ded6d6e0400a0a35020533)

<img src=" https://images.memorix.nl/rce/thumb/1600x1600/46c097fe-1d9e-d2a8-d96c-061507f3c24e.jpg" alt="Kernhem via RCE" width="500" height="400">

* [Kernhem TOP10nl (overige)](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?lokaal_id=101307078)
* [Kernhem BGT](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?lokaal_id=G0228.fe246f4955ded6d6e0400a0a35020533)


## Camping
### Mini Camping
* [mini camping BGT](https://api.pdok.nl/lv/bgt/ogc/v1/collections/functioneelgebied/items?lokaal_id=G0228.74db96b42a17437a9e0db32655fe85b3)
* [mini camping TOP10NL](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/functioneel_gebied_vlak/items?lokaal_id=131049741) 

### Camping Groot 
* [Vakantiepark Top10nl](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/functioneel_gebied_vlak/items?lokaal_id=130899350) 
* [Camping BGT deel 1](https://api.pdok.nl/lv/bgt/ogc/v1/collections/functioneelgebied/items?lokaal_id=G0228.f2f158bc65484a1890e5161cf13850cc)
* [Camping BGT deel 2](https://api.pdok.nl/lv/bgt/ogc/v1/collections/functioneelgebied/items?lokaal_id=G0228.25ebc050f44945a8ad232ded52ce8c92)


## Bepalen van de volgorde en hoeveelheid (informatie analyse)
* PDOK smaakje (Geen RCE)

* Cool drankje  (WMS of WFS niet cool)
* Kastelen o.b.v. TOP10NL
* Download, https://app.pdok.nl/brt/top10nl/download-viewer/
* OGC API https://api.pdok.nl/brt/top10nl/ogc/v1
* OGC API Feature 
* OGC API Vectortile
* 


## Shaken (maken van de combikaart)

[Fietsroutes erbij](https://app.pdok.nl/viewer/#x=170665.83&y=453362.01&z=8.6860&background=BRT-A%20standaard&layers=0d9ad4de-0255-4ad5-930d-f3e3cd2143f9;landelijke-fietsroutes,37f44a7c-5274-11ea-954f-080027325297;fietsnetwerken,37f44a7c-5274-11ea-954f-080027325297;fietsknooppunten) 

[Protected sites](https://app.pdok.nl/viewer/#x=170665.83&y=453362.01&z=8.6860&background=BRT-A%20standaard&layers=0d9ad4de-0255-4ad5-930d-f3e3cd2143f9;landelijke-fietsroutes,37f44a7c-5274-11ea-954f-080027325297;fietsnetwerken,37f44a7c-5274-11ea-954f-080027325297;fietsknooppunten,7b8f44b5-6eae-4113-a835-84b8678c3dd5;PS.ProtectedSite)

## Zeven (testen van het resultaat)

* Kastelen Landhuizen kasteel|ruïne

* Punten toevoegen aan route 

 <img src="https://images.memorix.nl/rce/thumb/1600x1600/1d8c0849-7852-21cc-d050-4dd4e9ae4f77.jpg" alt="kasteel ruine wageningen via RCE" width="500" height="400">

* [kasteel ruine wageningen Top10NL Punt](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_punt/items?lokaal_id=131688852)
* wel geen vakantie parken
* Mini campings voorkeur? 

## Serveer de cocktail (style je kaart)

* PDOK achtergrond kaart (simple)
* Vectortile styling:  
* * [Edit styles in maputnik](https://jlschaap.github.io/maputnik/?layer=2385953104%7E0#15.55/52.075336/5.628303)
 
## Geniet 

* Voeg terrassen toe voor een drankje tijdens fietstocht? 
* Tip: Op vakantie doe het analoog: camping gids, kastelen gids en een drankje




#
#
#
# Bijlage:  



## [OGC API Landingpage](https://docs.ogc.org/is/17-069r4/17-069r4.html#_api_landing_page)



* [Top10NL](https://api.pdok.nl/brt/top10nl/ogc/v1)
* [BGT](https://api.pdok.nl/lv/bgt/ogc/v1)
* [BAG](https://api.pdok.nl/lv/bag/ogc/v1)
* [Bestuurlijke gebieden](https://api.pdok.nl/kadaster/bestuurlijkegebieden/ogc/v1)
* [BRO](https://api.pdok.nl/bzk/bro-gminsamenhang-karakteristieken/ogc/v1)
* [3D basisvoorziening](https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1)

# [OGC Api features](https://ogcapi.ogc.org/features/)


## [Collections](https://docs.ogc.org/is/17-069r4/17-069r4.html#_feature_collections_rootcollections)

* [building collection: 'BRT TOP10NL - Gebouw vlak'](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak)

## [Items Feature by Parameter bbox](https://docs.ogc.org/is/17-069r4/17-069r4.html#_features_rootcollectionscollectioniditems)

* [building items BBOX: 'BRT TOP10NL - Gebouw vlak'](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000&f=html)
* [BGT - building items BBOX:Basisregistratie Grootschalige Topografie - Pand (PND)](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000)
* [BAG - building items BBOX:Basisregistratie Adressen en Gebouwen - Pand (demo))](https://api.pdok.nl/lv/bag/ogc/v1-demo/collections/pand/items?bbox=5.3865794432391585%2C52.15474153635583%2C5.388280713000618%2C52.1555578885615&limit=1000)

## [Item Feature by id](https://docs.ogc.org/is/17-069r4/17-069r4.html#_features_rootcollectionscollectioniditems)

* [TOP10NL Item](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items?lokaal_id=103018712)
* [BGT item](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items?lokaal_id=G0307.b94c2bd2f8f44429a23bb46202b1627b)
* [BAG Item](https://api.pdok.nl/lv/bag/ogc/v1-demo/collections/pand/items?identificatie=0307100000333887)

## Item Feature by key from PDOK-API

* [TOP10NL](https://api.pdok.nl/brt/top10nl/ogc/v1/collections/gebouw_vlak/items/bffedb27-48f8-50d9-a725-66f6024ec569)
* [BGT](https://api.pdok.nl/lv/bgt/ogc/v1/collections/pand/items/6f694250-fbb5-52f3-8761-3cf564846700)
* [BAG](https://api.pdok.nl/lv/bag/ogc/v1-demo/collections/pand/items/67b6065c-b9d5-5fce-9b8f-bd12336acf0f)

## [OGC Api features](https://ogcapi.ogc.org/features/) Download Grid for [Cityjson](https://www.cityjson.org/) Zip

* [building collection (GRID):  '3D Basisvoorziening - 3D Objecten Gebouwen'](https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1/collections/basisbestand_gebouwen)






# [OGC API - 3D GeoVolumes](https://ogcapi.ogc.org/geovolumes/)

* [building 3d tiles :'3D Basisvoorziening - 3D Tiles Gebouwen'](https://api.pdok.nl/kadaster/3d-basisvoorziening/ogc/v1/collections/gebouwen/3dtiles)

* [PDOK 3D - Viewer](https://app.pdok.nl/3d-viewer/#x=186070.65&y=319298.78&alt=131&range=288&heading=200&pitch=-11&roll=360&background=Luchtfoto&layers=)



___

[![check markdown links](https://github.com/JLSchaap/JLSchaap.github.io/actions/workflows/checkMarkdown.yml/badge.svg)](https://github.com/JLSchaap/JLSchaap.github.io/actions/workflows/checkMarkdown.yml)
