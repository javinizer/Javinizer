# Format Strings

Javinizer allows you options to use tags for file naming using scraped metadata. The available tags are as follows, conforming with the naming schema available from the JAVMovieScraper application:

* \<ID>
* \<CONTENTID>
* \<DIRECTOR>
* \<TITLE>
* \<RELEASEDATE>
* \<YEAR>
* \<STUDIO>
* \<RUNTIME>
* \<SET>
* \<LABEL>
* \<ACTORS>
* \<ORIGINALTITLE>
* \<FILENAME>
* \<RESOLUTION>&#x20;
  * &#x20;Resolution requires `sort.metadata.nfo.mediainfo` as true

## Example

### Metadata Output

```
C:/> Javinizer -Find abp-420 -Javlibrary -R18 -DmmJa -Aggregated

Id               : ABP-420
ContentId        : 118abp00420
DisplayName      : [ABP-420] Endless Sex Starring Rino Kirishima
Title            : Endless Sex Starring Rino Kirishima
AlternateTitle   : エンドレスセックス 桐嶋りの
Description      : プレステージ専属女優『桐嶋 りの』が、45人の男優とノンストップセックスを展開！抜群の包容力とテクニッ
                   クで多数の肉棒を相手に奮闘する！次々にぶち込まれ、トロケルように色っぽい表情で感じ続ける！激しいピス
                   トンに眉間に皺を寄せながら悶絶イキ！「快楽の誘い人」として集められた屈強な男優10名にマワされ、執拗な
                   までに続く挿入の快感にアクメ絶頂！！顔射され顔面をドロドロに汚されながら大口を開けて精子をネダる姿は
                   堪りません！！
Rating           :
ReleaseDate      : 2016-01-08
Runtime          : 136
Director         : Manhattan Kimura
Maker            : Prestige
Label            : ABSOLUTELY PERFECT
Series           : Endless Sex
Tag              : {Endless Sex}
Tagline          :
Credits          :
Actress          : {@{LastName=Kirishima; FirstName=Rino; JapaneseName=桐嶋りの;
                   ThumbUrl=https://pics.r18.com/mono/actjpgs/kirisima_rino.jpg}}
Genre            : {Cosplay, Solowork, Facial, Squirting…}
CoverUrl         : https://pics.r18.com/digital/video/118abp00420/118abp00420pl.jpg
ScreenshotUrl    : {https://pics.r18.com/digital/video/118abp00420/118abp00420jp-1.jpg,
                   https://pics.r18.com/digital/video/118abp00420/118abp00420jp-2.jpg,
                   https://pics.r18.com/digital/video/118abp00420/118abp00420jp-3.jpg,
                   https://pics.r18.com/digital/video/118abp00420/118abp00420jp-4.jpg…}
TrailerUrl       : https://awscc3001.r18.com/litevideo/freepv/1/118/118abp420/118abp420_dmb_w.mp4
OriginalFileName : ABP-420.1080p.mp4
MediaInfo        :
```

### Metadata Assignment

In this example for movie ABP-420, the tags would be defined as:

| Tag              | Value                               |
| ---------------- | ----------------------------------- |
| \<ID>            | ABP-420                             |
| \<CONTENTID>     | 118abp00420                         |
| \<DIRECTOR>      | Manhattan Kimura                    |
| \<TITLE>         | Endless Sex Starring Rino Kirishima |
| \<RELEASEDATE>   | 2016-01-08                          |
| \<YEAR>          | 2016                                |
| \<STUDIO>        | Prestige                            |
| \<RUNTIME>       | 136                                 |
| \<SET>           | Endless Sex                         |
| \<LABEL>         | ABSOLUTELY PERFECT                  |
| \<ACTORS>        | Kirishima Rino                      |
| \<ORIGINALTITLE> | エンドレスセックス 桐嶋りの                      |
| \<FILENAME>      | ABP-420.1080p                       |
| \<RESOLUTION>    |                                     |

### Format Strings

Here are some examples of how you can build your desired format string.

| Format String                       | Value                                                |
| ----------------------------------- | ---------------------------------------------------- |
| \<ID> - \<TITLE> (\<YEAR>)          | ABP 420 - Endless Sex Starring Rino Kirishima (2016) |
| \[\<STUDIO>] \[\<YEAR>] \<ID>       | \[Prestige] \[2016] ABP-420                          |
| \<ID> (\<RUNTIME>min)               | ABP-420 (136min)                                     |
| \<ID> (\<ACTORS>) \[\<RELEASEDATE>] | ABP-420 (Kirishima Rino) \[2016-01-08]               |
| \[\<STUDIO>] \[\<LABEL>] - \<ID>    | \[Prestige] \[ABSOLUTELY PERFECT] - ABP-420          |
