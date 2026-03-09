
### 4️⃣ Zoekopdracht met relevance‑weging

* <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&adres[version]=1&adres[relevance]=0.8>
* Provincie prio: <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&gemeentegebied%5Brelevance%5D=0.1&gemeentegebied%5Bversion%5D=1&provinciegebied%5Brelevance%5D=0.9&provinciegebied%5Bversion%5D=1&woonplaats%5Brelevance%5D=0.1&woonplaats%5Bversion%5D=1&f=json>
* Gemeente prio: <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&gemeentegebied%5Brelevance%5D=0.9&gemeentegebied%5Bversion%5D=1&provinciegebied%5Brelevance%5D=0.1&provinciegebied%5Bversion%5D=1&woonplaats%5Brelevance%5D=0.1&woonplaats%5Bversion%5D=1&f=json>
* Woonplaats prio: <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&gemeentegebied%5Brelevance%5D=0.1&gemeentegebied%5Bversion%5D=1&provinciegebied%5Brelevance%5D=0.1&provinciegebied%5Bversion%5D=1&woonplaats%5Brelevance%5D=0.9&woonplaats%5Bversion%5D=1&f=json>

### 5️⃣ Zoekopdracht met BBOX‑filter

* <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&adres%5Brelevance%5D=0.5&adres%5Bversion%5D=1&limit=3&bbox=2.8377106886394086,50.10815179279933,8.404484244866381,53.87250129000339&bbox-crs=http%3A%2F%2Fwww.opengis.net%2Fdef%2Fcrs%2FOGC%2F1.3%2FCRS84&crs=http%3A%2F%2Fwww.opengis.net%2Fdef%2Fcrs%2FOGC%2F1.3%2FCRS84&f=json>

rond nederland:         bbox=2.8377106886394086,50.10815179279933,8.404484244866381,53.87250129000339
 <https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&adres[version]=1&adres[relevance]=0.5&f=json&bbox=2.8377106886394086,50.10815179279933,8.404484244866381,53.87250129000339>
rond centrum nederland:
 <<https://api.pdok.nl/kadaster/location-api/v1-demo/search?q=amsterdam&adres[version]=1&adres[relevance]=0.5&f=json&bbox=5.090993080367572,51.84038004496384,5.876125141956711,52.32645304080979>