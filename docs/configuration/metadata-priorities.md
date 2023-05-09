# Metadata Priorities

Javinizer assigns metadata to fields in order by the sources listed in`sort.metadata.priority.(field)`  as long as the scraper is enabled by the setting `scraper.movie.(source)`. Metadata will never be combined using data from multiple sources, but rather assigned only to the first priority source that has non-null data.

| Setting                               |
| ------------------------------------- |
| sort.metadata.priority.actress        |
| sort.metadata.priority.alternatetitle |
| sort.metadata.priority.coverurl       |
| sort.metadata.priority.description    |
| sort.metadata.priority.director       |
| sort.metadata.priority.genre          |
| sort.metadata.priority.id             |
| sort.metadata.priority.label          |
| sort.metadata.priority.maker          |
| sort.metadata.priority.rating         |
| sort.metadata.priority.releasedate    |
| sort.metadata.priority.runtime        |
| sort.metadata.priority.series         |
| sort.metadata.priority.screenshoturl  |
| sort.metadata.priority.title          |
| sort.metadata.priority.trailerurl     |

## Example

For example, if your actress priority looks like this: `"sort.metadata.priority.actress": ["r18dev", "javlibrary", "javbus"]`

* If actresses are found from the R18.dev scraper --> R18.dev actresses will be assigned to the metadata field
* If actresses are not found on the R18.dev scraper but are found on the Javlibrary scraper --> Javlibrary actresses will be assigned to the metadata field
* If actresses are not found on the R18.dev and Javlibrary scrapers but are found on the JavBus scraper --> JavBus actresses will be assigned to the metadata field
* If actresses are not found on any of the scrapers, it will be returned as null

## Scraper sources:

These are the exact scraper names that you need to enter into the priority setting array:

* dmm
* dmmja
* jav321ja
* javbus
* javbusja
* javbuszh
* javdb
* javdbzh
* javlibrary
* javlibraryja
* javlibraryzh
* mgstageja
* r18dev
* tokyohot
* tokyohotja
* tokoyhotzh
