# Genre/Tag CSV

{% hint style="info" %}
The documentation on this page also applies to the tag csv using -OpenTags.
{% endhint %}

Javinizer can utilize a csv file of genres/tags to replace them with a genre/tag of your choice.

```
Javinizer -OpenGenres
```

The default file Javinizer uses is the `jvGenres.csv` file located in the root module folder. Javinizer can use a custom path defined by the `location.genrecsv` setting.

It is enabled by the following settings:

* `location.genrecsv` - If blank, this will point to the file located within your module root directory.
* `sort.metadata.genrecsv`

A default genre csv file is included with Javinizer which will replace Javlibrary genres with their R18 counterparts.

For example, if your jvGenres.csv file looks like this:

| Original | Replacement |
| -------- | ----------- |
| Blow     | Blowjob     |

* Any scraped genre that equals `Blow` will be replaced with `Blowjob`
