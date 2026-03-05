# location API 

```text
Client                                        Location API (preprod)                              OGC API (bron-collectie)
  |                                                    |                                                |
  |-- GET /search?q=Stations&adres[version]=1 -------->|                                                |
  |                                                    |  Zoekt in geconfigureerde collecties           |
  |                                                    |  (adres, perceel, woonplaats, etc.)            |
  |                                                    |                                                |
  |<-- 200 FeatureCollection (lightweight) ------------|                                                |
  |        features[n]:                                                                      ^
  |          - id, bbox, (mini)geometry                                                     |
  |          - properties: display_name, highlight, score                                   |
  |          - properties.href[]: URL(s) naar volledige feature  ---------------------------+
  |                                                                                         |
  |-- GET {href[0]} ----------------------------------------------------------------------->|  (bv.) GET /kadaster/.../ogc/v1/collections/adres/items/{id}
  |                                                                                        |  Retourneert volledige feature:
  |                                                                                        |  - alle properties
  |                                                                                        |  - volledige geometrie
  |<---------------------------------------------------------------------------------------|  200 Feature (GeoJSON/JSON-FG)
  |
  |  [Client gebruikt nu de volledige feature in eigen UI/kaart]
  v