# JAV Organizer

Tool to organize your local Japanese Adult Video (JAV) collection

## Overview

[View changelog](./CHANGELOG.md)

## Installation

**Dependencies**

- [PowerShell 6, **7**](https://github.com/PowerShell/PowerShell)
- [Python 2.7+](https://www.python.org/downloads/) - If you are a Linux user, make sure to install a compatible Python 2.7 version
    - [Cloudscraper](https://pypi.org/project/cloudscraper/)
    - [Pillow](https://pypi.org/project/Pillow/)
    - [Googletrans](https://pypi.org/project/googletrans/)

```
# From any compatible Python terminal
> pip install cloudscraper
> pip install pillow
> pip install googletrans
```

**Multi-part video supported naming schemes**

```
# Naming schemes  - Example filename
------------------------------------
ID-###[a-iA-I]    - ID-069A, ID-069B
ID-###-[a-iA-I]   - ID-069-a, ID-069-b
ID-###-\d         - ID-069-1, ID-069-2
ID-###-0\d        - ID-069-01, ID-069-02
ID-###-00\d       - ID-069-001, ID-069-003
ID-###-pt\d       - ID-069-pt1, ID-069-pt2
ID-### - pt\d     - ID-069 - pt1, ID-069 - pt2
ID-###-part\d     - ID-069-part1, ID-069-part2
ID-### - part\d   - ID-069 - part1, ID-069 - part2
ID-###_\d         - ID-069_1, ID-069_2
ID-###_0\d        - ID-069_01, ID-069_02
```

**Usage**
Import the module
```
PS> Import-Module .\Javinizer.psd1
```

## Examples

Search JAV data from web using `settings.ini` defined sources
```
PS> Javinizer -Find snis-620
```

Search JAV from web using console-defined sources
```
PS> Javinizer -Find snis-620 -R18 -Dmm
```

Search JAV from web using direct urls
```
PS> Javinizer -Find 'https://www.r18.com/videos/vod/movies/detail/-/id=pred00200/?dmmref=video.movies.new&i3_ref=list&i3_ord=2'
```

Search JAV from web and get aggregated data output from `settings.ini` defined metadata priority
```
PS> Javinizer -Find snis-620 -R18 -Javlibrary -Aggregated
```

Sort a single file defined in console with `DestinationPath` defined as `output-path` in `settings.ini`
```
PS> Javinizer -Path 'C:\Downloads\JAV\snis-620.mp4'
```

Sort a single file defined in console with direct URLs
```
PS> Javinizer -Path 'C:\Downloads\Jav\snis-620.mp4' -DestinationPath C:\Downloads\JAV\Sorted\' -Url 'http://www.javlibrary.com/en/?v=javlilljyy,https://www.r18.com/videos/vod/movies/detail/-/id=snis00620/?i3_ref=search&i3_ord=1,https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=snis00620/?i3_ref=search&i3_ord=4'
```

Sort directory defined in `settings.ini` at `input-path` and `output-path`
```
PS> Javinizer -Apply
```

Sort directory defined in console
```
PS> Javinizer -Path 'C:\Downloads\JAV\' -DestinationPath 'C:\Downloads\JAV\Sorted\'
```


## Todo
- [x] Trailer scraping - [0.1.2]
- [x] Multi-part video directory sort support - [0.1.2]
- [] Parallel/Threaded sort processing
- [] Allow switching firstname/lastname order
