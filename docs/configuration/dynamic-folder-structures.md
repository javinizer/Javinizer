# Dynamic Folder Structures

Javinizer supports dynamic folder structures for your sorted files using the setting `sort.format.outputfolder`. The setting will "concatenate" each entered [format string](format-strings.md) as a nested folder. If the `<METADATA>` metadata in the format string is null, it will be replaced as `Unknown`.

If you leave the setting blank, the movie folder will be created in the root destination output path: `"sort.format.outputfolder": []`.

## Example

### Settings values

```
"sort.format.outputfolder": ["<YEAR>", "<STUDIO>"]
"sort.format.folder": "<ID> - <TITLE> (<YEAR>)"
"sort.format.file": "<ID>"
```

### Metadata Search

Normally, you would need to run a Javinizer sort using `-Path`, but we are using `-Find` in this example to show the metadata output.

```
Javinizer -Find abw-003 -Javlibrary -R18 -DmmJa -Aggregated
```

```
Id             : ABW-003
ContentId      : 118abw00003
DisplayName    : [ABW-003] Kana Kawaguchi Will Serve You As An Ultra Newest Beauty Salon Addict 49 She Will Provide
                 Exquisite Refreshment For Her Customers Pent-Up Desires And Relieve Their Hardened Cocks!!
Title          : Kana Kawaguchi Will Serve You As An Ultra Newest Beauty Salon Addict 49 She Will Provide Exquisite
                 Refreshment For Her Customer's Pent-Up Desires And Relieve Their Hardened Cocks!!
AlternateTitle : 川口夏奈がご奉仕しちゃう超最新やみつきエステ 49 お客様の欲望で凝り固まったアソコを極上リフレッシュ！！
Description    : プレステージ専属女優『川口 夏奈』の超最新やみつきエステが味わえる‘エステdeなつな’がオープン！エステテ
                 ィシャン・夏奈が刺激的なコスチュームでお出迎えし、全力ご奉仕♪ふわふわFカップで優しく包み込むような洗体
                 プレイが味わえる「全身密着リフレッシュコース」！乳首をグリグリ弄りながらフェラ＆パイズリで最高の射精へ
                 と導く「ディープコース」！いやらしい腰使いでマ〇コを擦り付け、理性崩壊でまさかの本番行為に発展！？「素
                 股体感コース」！ぬるぬるローションでチ〇コをしごきながらのアナル舐めで昇天「集中癒しコース」！オイルま
                 みれの身体をお客様から逆マッサージを施され、つい欲情してしまう「オイルマッサージコース」！誰もがやみつ
                 きになる5つのコースで至福のひと時をご提供します！！
Rating         : @{Rating=9; Votes=3}
ReleaseDate    : 2020-08-28
Runtime        : 149
Director       : Charlie Tanaka
Maker          : Prestige
Label          : ABSOLUTELY WONDERFUL
Series         : Newest Beauty Salon Addict
Tag            : {Newest Beauty Salon Addict}
Tagline        :
Credits        :
Actress        : {@{LastName=Kawaguchi; FirstName=Natsuna; JapaneseName=川口夏奈;
                 ThumbUrl=https://pics.r18.com/mono/actjpgs/kawaguti_natuna.jpg}}
Genre          : {Big Tits, Cosplay, Massage Parlor, Titty Fuck}
CoverUrl       : https://pics.r18.com/digital/video/118abw00003/118abw00003pl.jpg
ScreenshotUrl  : {https://pics.r18.com/digital/video/118abw00003/118abw00003jp-1.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-2.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-3.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-4.jpg…}
TrailerUrl     : https://awscc3001.r18.com/litevideo/freepv/1/118/118abw003/118abw003_dmb_w.mp4
MediaInfo      :
```

### Example Output

With the above settings, you should receive this folder structure for your sorted file.

```
C:.
\---2020
    \---Prestige
        \---ABW-003 - Kana Kawaguchi Will Serve You As An Ultra Newest Beauty Salon Addict 49 She Will Provide... (2020)
            |   ABW-003.mp4
            |   ABW-003.nfo
            |   fanart.jpg
            |   folder.jpg
```
