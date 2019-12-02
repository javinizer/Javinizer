# JAV Organizer

Tool to organize your local Japanese Adult Video (JAV) collection

## Overview

[View changelog](./CHANGELOG.md)

## Installation

**Dependencies**

- PowerShell 6, 7
- Python 2.7+
    - Cloudscraper
    - Pillow
    - Googletrans

```
pip install googletrans
```

https://github.com/ssut/py-googletrans

```
pip install cloudscraper
```

https://github.com/VeNoMouS/cloudscraper

```
pip install pillow
```

https://pypi.org/project/Pillow/2.2.1/

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
- [] Better video name recognition
- [] Parallel/Threaded sort processing
- [] Allow switching firstname/lastname order
