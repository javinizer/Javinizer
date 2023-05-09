# Metadata Translation

Javinizer utilizes either the `googletrans` or `google_trans_new` python modules to perform translations on metadata scraped from your desired sources. The translation modules will automatically detect the source language and perform the translation as applicable.

For usage, you will need to utilize the following settings:

| Setting                              | Value                                                                                                                                                                                    |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| sort.metadata.nfo.translate          | true or false                                                                                                                                                                            |
| sort.metadata.nfo.translate.module   | googletrans or google\_trans\_new                                                                                                                                                        |
| sort.metadata.nfo.translate.language | Enter a language code from [here](https://developers.google.com/admin-sdk/directory/v1/languages).                                                                                       |
| sort.metadata.nfo.translate.field    | <p>An array of accepted metadata fields.</p><ul><li>Title</li><li>AlternateTitle</li><li>Description</li><li>Director</li><li>Series</li><li>Genre</li><li>Maker</li><li>Label</li></ul> |

The source language of the field does not matter, meaning that you are even able to translate English metadata fields to a language of your choice.

## Example

For this example, we will be translating the description, title, and genre metadata fields to Korean.

### Settings Values

```
    "sort.metadata.nfo.translate": true,
    "sort.metadata.nfo.translate.module": "googletrans",
    "sort.metadata.nfo.translate.field": ["description", "title", "genre"],
    "sort.metadata.nfo.translate.language": "ko",
```

### Metadata Search

```
Javinizer -Find abw-003 -Javlibrary -R18 -DmmJa -Aggregated

Id             : ABW-003
ContentId      : 118abw00003
DisplayName    : [ABW-003] Kana Kawaguchi가 최신 뷰티 살롱 중독자로 당신을 섬길 것입니다 49 그녀는 그녀의 고객의
                 욕망에 절묘한 상쾌함을 제공하고 그들의 굳은 자지를 풀어줍니다!
Title          : Kana Kawaguchi가 최신 뷰티 살롱 중독자로 당신을 섬길 것입니다 49 그녀는 그녀의 고객의 욕망에 절묘한
                 상쾌함을 제공하고 그들의 굳은 자지를 풀어줍니다!
AlternateTitle : 川口夏奈がご奉仕しちゃう超最新やみつきエステ 49 お客様の欲望で凝り固まったアソコを極上リフレッシュ！！
Description    : 프레스티지전속여배우"가와구치夏奈"매우최신중독성에스테틱을 맛볼 수있는'에스테틱de나츠
                 나'가오픈!미용사여름나나가자극적 인의상으로마중최선봉사♪털이F 컵으로 부드럽게감싸는씻음
                 체플레이를맛볼 수있는 「전신밀착리프레쉬코스」!젖꼭지를둥글 둥글만지작하면서페라&파이즈
                 리에서최고의사정으로 이끄는'딥코스」!불쾌한허리값어치마〇코를칠해이성붕괴설마실전 행위로 발전!?"가랑이
                 체험코스」!칙칙한로션치〇코를훑어보면서애무승천"집중치료코스」!기름투성이의몸을고객반대로마사지를베풀
                 어 져붙어욕정해 버리는"오일 마사지코스」!모두가중독이되는5개의코스에서행복한시간을제공합니다!!
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
Genre          : {큰 가슴, 코스프레, 마사지 응접실, 가슴 씨발}
CoverUrl       : https://pics.r18.com/digital/video/118abw00003/118abw00003pl.jpg
ScreenshotUrl  : {https://pics.r18.com/digital/video/118abw00003/118abw00003jp-1.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-2.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-3.jpg,
                 https://pics.r18.com/digital/video/118abw00003/118abw00003jp-4.jpg…}
TrailerUrl     : https://awscc3001.r18.com/litevideo/freepv/1/118/118abw003/118abw003_dmb_w.mp4
MediaInfo      :
```
