# Searching for Metadata

The `-Find` parameter can be used to search for and output metadata. The `-Find` parameter accepts either an exact movie ID, or an array of URLs.

```
Javinizer [-Find] <PSObject> [-Aggregated] [-Nfo] 
[-AVEntertainment] [-AVEntertainmentJa] [-R18Dev] [-Dmm] [-DmmJa] 
[-Javlibrary] [-JavlibraryZh] [-JavlibraryJa] [-Javbus] [-JavbusJa] [-JavbusZh]
[-Javdb] [-JavdbZh] [-Jav321Ja] [-MgstageJa] [-TokyoHot] [-TokyoHotZh]
[-TokyoHotJa] [-Set <Hashtable>] [-SettingsPath <FileInfo>] [<CommonParameters>]
```

## Finding metadata per scraper

### Using an exact movie ID

```
Javinizer -Find "ABP-420" -R18Dev

# To output all matching search results, use the -AllResults parameter
Javinizer -Find "ABP-420" -R18Dev -AllResults
```

```
Source        : r18
Url           : https://www.r18.com/videos/vod/movies/detail/-/id=118abp00420/
ContentId     : 118abp00420
Id            : ABP-420
Title         : Endless Sex Starring Rino Kirishima
Description   :
ReleaseDate   : 2016-01-08
ReleaseYear   : 2016
Runtime       : 136
Director      : Manhattan Kimura
Maker         : Prestige
Label         : ABSOLUTELY PERFECT
Series        : Endless Sex
Actress       : @{LastName=Kirishima; FirstName=Rino; JapaneseName=桐嶋りの;
                ThumbUrl=https://pics.r18.com/mono/actjpgs/kirisima_rino.jpg}
Genre         : {Slut, Orgy, Featured Actress, Hi-Def…}
CoverUrl      : https://pics.r18.com/digital/video/118abp00420/118abp00420pl.jpg
ScreenshotUrl : {https://pics.r18.com/digital/video/118abp00420/118abp00420jp-1.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-2.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-3.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-4.jpg…}
TrailerUrl    : https://awscc3001.r18.com/litevideo/freepv/1/118/118abp420/118abp420_dmb_w.mp4

```

### Using URLs

```
Javinizer -Find 'https://www.r18.com/videos/vod/movies/detail/-/id=118abp00420/', 'http://www.javlibrary.com/en/?v=javlilb54i'
```

```
Source        : r18
Url           : https://www.r18.com/videos/vod/movies/detail/-/id=118abp00420/
ContentId     : 118abp00420
Id            : ABP-420
Title         : Endless Sex Starring Rino Kirishima
Description   :
ReleaseDate   : 2016-01-08
ReleaseYear   : 2016
Runtime       : 136
Director      : Manhattan Kimura
Maker         : Prestige
Label         : ABSOLUTELY PERFECT
Series        : Endless Sex
Actress       : @{LastName=Kirishima; FirstName=Rino; JapaneseName=桐嶋りの;
                ThumbUrl=https://pics.r18.com/mono/actjpgs/kirisima_rino.jpg}
Genre         : {Slut, Orgy, Featured Actress, Hi-Def…}
CoverUrl      : https://pics.r18.com/digital/video/118abp00420/118abp00420pl.jpg
ScreenshotUrl : {https://pics.r18.com/digital/video/118abp00420/118abp00420jp-1.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-2.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-3.jpg,
                https://pics.r18.com/digital/video/118abp00420/118abp00420jp-4.jpg…}
TrailerUrl    : https://awscc3001.r18.com/litevideo/freepv/1/118/118abp420/118abp420_dmb_w.mp4

Source        : javlibrary
Url           : http://www.javlibrary.com/en/?v=javlilb54i
Id            : ABP-420
AjaxId        : 288542
Title         : Endless Sex Kirishima Rino
ReleaseDate   : 2016-01-09
ReleaseYear   : 2016
Runtime       : 135
Director      : Manhattan Kimura
Maker         : Prestige
Label         : ABSOLUTELY PERFECT
Rating        : @{Rating=7.40; Votes=}
Actress       : @{LastName=Kirishima; FirstName=Rino; JapaneseName=桐嶋りの; ThumbUrl=}
Genre         : {Cosplay, Solowork, Facials, Squirting…}
CoverUrl      : https://pics.dmm.co.jp/mono/movie/adult/118abp420/118abp420pl.jpg
```

## Finding aggregated metadata

Aggregated data within Javinizer is defined by the data object created by combining scraper metadata via the priorities in your settings. This is called by using the `-Aggregated` parameter in conjunction with `-Find`.

```
Javinizer -Find "ABP-420" -R18 -Javlibrary -DmmJa -Aggregated
```

```
Id             : ABP-420
ContentId      : 118abp00420
DisplayName    : [ABP-420] Endless Sex Starring Rino Kirishima
Title          : Endless Sex Starring Rino Kirishima
AlternateTitle : エンドレスセックス 桐嶋りの
Description    : プレステージ専属女優『桐嶋 りの』が、45人の男優とノンストップセックスを
                 展開！抜群の包容力とテクニックで多数の肉棒を相手に奮闘する！次々にぶち込
                 まれ、トロケルように色っぽい表情で感じ続ける！激しいピストンに眉間に皺を
                 寄せながら悶絶イキ！「快楽の誘い人」として集められた屈強な男優10名にマワ
                 され、執拗なまでに続く挿入の快感にアクメ絶頂！！顔射され顔面をドロドロに
                 汚されながら大口を開けて精子をネダる姿は堪りません！！
Rating         : @{Rating=9; Votes=18}
ReleaseDate    : 2016-01-08
Runtime        : 136
Director       : Manhattan Kimura
Maker          : Prestige
Label          : ABSOLUTELY PERFECT
Series         : Endless Sex
Tag            : {Endless Sex}
Tagline        :
Actress        : {@{LastName=Kirishima; FirstName=Rino; JapaneseName=桐嶋りの;
                 ThumbUrl=https://pics.r18.com/mono/actjpgs/kirisima_rino.jpg}}
Genre          : {Slut, Orgy}
CoverUrl       : https://pics.r18.com/digital/video/118abp00420/118abp00420pl.jpg
ScreenshotUrl  : {https://pics.r18.com/digital/video/118abp00420/118abp00420jp-1.jpg,
                 https://pics.r18.com/digital/video/118abp00420/118abp00420jp-2.jpg,
                 https://pics.r18.com/digital/video/118abp00420/118abp00420jp-3.jpg,
                 https://pics.r18.com/digital/video/118abp00420/118abp00420jp-4.jpg…}
TrailerUrl     : https://awscc3001.r18.com/litevideo/freepv/1/118/118abp420/118abp420_dmb
                 _w.mp4
MediaInfo      :
```

### Outputting the nfo

You can also output the aggregated metadata in the nfo format that you would normally see when sorting files via Javinizer. This can be called by using the `-Nfo` parameter in conjunction with `-Find` and `-Aggregated`.

```
Javinizer -Find "ABP-420" -R18 -Javlibrary -DmmJa -Aggregated -Nfo
```

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>[ABP-420] Endless Sex Starring Rino Kirishima</title>
    <originaltitle>エンドレスセックス 桐嶋りの</originaltitle>
    <id>ABP-420</id>
    <releasedate>2016-01-08</releasedate>
    <year>2016</year>
    <director>Manhattan Kimura</director>
    <studio>Prestige</studio>
    <rating>9</rating>
    <votes>18</votes>
    <plot>プレステージ専属女優『桐嶋 りの』が、45人の男優とノンストップセックスを展開！抜 群の包容力とテクニックで多数の肉棒を相手に奮闘する！次々にぶち込まれ、トロケルように色っぽい表情で感じ続ける！激しいピストンに眉間に皺を寄せながら悶絶イキ！「快楽の誘い人」として集められた屈強な男優10名にマワされ、執拗なまでに続く挿入の快感にアクメ絶頂！！顔射され顔面をドロドロに汚されながら大口を開けて精子をネダる姿は堪りません！！</plot>
    <runtime>136</runtime>
    <trailer>https://awscc3001.r18.com/litevideo/freepv/1/118/118abp420/118abp420_dmb_w.mp4</trailer>
    <mpaa>XXX</mpaa>
    <tagline></tagline>
    <set>Endless Sex</set>
    <tag>Endless Sex</tag>
    <genre>Slut</genre>
    <genre>Orgy</genre>
    <actor>
        <name>Kirishima Rino</name>
        <altname>桐嶋りの</altname>
        <thumb>https://pics.r18.com/mono/actjpgs/kirisima_rino.jpg</thumb>
        <role>Actress</role>
    </actor>
</movie>
```
