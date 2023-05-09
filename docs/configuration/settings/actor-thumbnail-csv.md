# Actor Thumbnail CSV

Javinizer uses a csv file of actors scraped from R18.com to populate missing actor thumbnail images.

The thumb csv can be opened using the command:

```
C:\> Javinizer -OpenThumbs
```

The default file Javinizer uses is the `jvThumbs.csv` file located in the root module folder. Javinizer can use a custom path defined by the`location.thumbcsv`

## Updating the csv

The `jvThumbs.csv` file can be manually updated using the following command. Only new actors will be appended to the csv file.

```
# The -Pages parameter accepts an array of numbers for the start/end page
C:\> Javinizer -UpdateThumbs -Pages 1,10 -Verbose
```

### &#x20;Updating the csv during sort

If setting `sort.metadata.thumbcsv.autoadd` is enabled, any new actress with a valid thumbUrl will be automatically appended to the csv file.

### Converting actress names using the csv

If setting `sort.metadata.thumbcsv.convertalias` is enabled, Javinizer will automatically convert any of the listed aliases (separated by `|` and entered in `LastName FirstName` format) to the actress that the alias corresponds to. Using the JapaneseName as the alias will yield the most accurate results.

| FullName     | LastName | FirstName | JapaneseName | ThumbUrl                         | Alias                   |
| ------------ | -------- | --------- | ------------ | -------------------------------- | ----------------------- |
| Aoi Rena     | Aoi      | Rena      | あおいれな        | https://\[..]/aoi\_rena.jpg      | Kobayakawa Reiko\|小早川怜子 |
| Hamasaki Mao | Hamasaki | Mao       | 浜崎真緒         | https://\[..]/hamasaki\_mao.jpg  |  Fukada Eimi            |
| Nagase Yui   | Nagase   | Yui       | 永瀬ゆい         | https://\[..]/nagase\_yui2.jpg   | Aika                    |

* Any scraped actress that matches `LastName: Kobayakawa; FirstName: Reiko` or `JapaneseName: 小早川怜子` will be converted to `Aoi Rena`
* Any scraped actress that matches `LastName: Fukada; FirstName: Eimi` will be converted to `Hamasaki Mao`
* Any scraped actress that matches `FirstName: Aika` will be converted to `Nagase Yui`
