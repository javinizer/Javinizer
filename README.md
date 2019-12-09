# Javinizer (JAV Organizer)
[![GitHub release](https://img.shields.io/github/v/release/jvlflame/Javinizer?include_prereleases&style=flat)](https://github.com/jvlflame/Javinizer/releases)
[![Commits since lastest release](https://img.shields.io/github/commits-since/jvlflame/Javinizer/latest?style=flat)](#)
[![Last commit](https://img.shields.io/github/last-commit/jvlflame/Javinizer?style=flat)](https://github.com/jvlflame/Javinizer/commits/master)
[![Discord](https://img.shields.io/discord/608449512352120834?style=flat)](https://discord.gg/K2Yjevk)
[![Build Status](https://dev.azure.com/jli141928/Javinizer/_apis/build/status/jvlflame.Javinizer?branchName=master)](https://dev.azure.com/jli141928/Javinizer/_build/latest?definitionId=2&branchName=master)

A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.

![Demo](media/demo.gif)

## Overview

**CAUTION:** As this is currently a beta release, please use responsibly and ensure that you use this program in an isolated environment, or that you have backups available for your targeted files/directories.
Please test it out and provide any feedback or feature requests if possible.

A rebuild of my previous project [JAV-Sort-Scrape-javlibrary](https://github.com/jvlflame/JAV-Sort-Scrape-javlibrary) as a console-focused application.


[View changelog](.github/CHANGELOG.md)

## Installation

**Dependencies**
- [PowerShell 6, PowerShell 7](https://github.com/PowerShell/PowerShell) - Windows PowerShell 5 is **NOT** supported
    - [PoshRSJob](https://github.com/proxb/PoshRSJob)
- [Python 3+ (64-bit)](https://www.python.org/downloads/) - Linux calls `python3`
    - [Cloudscraper](https://pypi.org/project/cloudscraper/)
    - [Pillow](https://pypi.org/project/Pillow/)
    - [Googletrans](https://pypi.org/project/googletrans/)

```
# From any compatible terminal

# pwsh
> Install-Module PoshRSJob

# python (Windows)
> pip install cloudscraper
> pip install pillow
> pip install googletrans

# python (Linux)
> pip3 install cloudscraper
> pip3 install pillow
> pip3 install googletrans
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

**Module settings**

Please look over the `settings.ini` file located in the root `Javinizer` module folder. The settings file contains important fields that you will need to fill out to effectively use the Javinizer program.
The fields are preset with my recommended default output.

## Installation

#### Install the module from PowerShell Gallery
```
PS> Install-Module -Name Javinizer
```

**---------- OR ----------**

#### Import the module

[Clone the repository](https://github.com/jvlflame/Javinizer/archive/master.zip) or [download the latest release](https://github.com/jvlflame/Javinizer/releases) and import the module.

```
PS> Import-Module ./Javinizer.psm1
```

### Usage

After installing or importing the module:

```
PS> help Javinizer

    NAME
        Javinizer

    SYNOPSIS
        A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files


    SYNTAX
        Javinizer [[-Path] <FileInfo>] [[-DestinationPath] <FileInfo>] [-Url <String>] [-Apply] [-Multi] [-R18] [-Dmm] [-Javlibrary] [-Force] [-ScriptRoot <String>] [<CommonParameters>]

        Javinizer [-Find] <String> [-Aggregated] [-Multi] [-R18] [-Dmm] [-Javlibrary] [-Force] [-ScriptRoot <String>] [<CommonParameters>]


    DESCRIPTION
        Javinizer is used to pull data from online data sources such as JAVLibrary, DMM, and R18 to aggregate data into a CMS (Plex,Emby,Jellyfin) parseable format.


    PARAMETERS
        -Find <String> [<Alias> -f]
            The find parameter will output a list-formatted data output from the data sources specified using a movie ID, file path, or URL.

        -Aggregated [<SwitchParameter>]
            The aggregated parameter will create an aggregated list-formatted data output from the data sources specified as well as metadata priorities in your settings.ini file.

        -Path <FileInfo> [<Alias> -p]
            The path parameter sets the file or directory path that Javinizer will search and sort files in.

        -DestinationPath <FileInfo> [<Alias> -d]
            The destinationpath parameter sets the directory path that Javinizer will send sorted files to.

        -Url <String> [<Alias> -u]
            The url parameter allows you to set direct URLs to JAVLibrary, DMM, and R18 data sources to scrape a video from in comma-separated-format (url1,url2,url3).

        -Apply [<SwitchParameter>] [<Alias> -a]
            The apply parameter allows you to automatically begin your sort using settings specified in your settings.ini file.

        -Multi [<SwitchParameter>] [<Alias> -m]
            The multi parameter will perform your sort using multiple concurrent threads with a throttle limit of (1-5) set in your settings.ini file.

        -R18 [<SwitchParameter>]
            The r18 parameter allows you to set your data source of R18 to true.

        -Dmm [<SwitchParameter>]
            The dmm parameter allows you to set your data source of DMM to true.

        -Javlibrary [<SwitchParameter>]
            The javlibrary parameter allows you to set your data source of JAVLibrary to true.

        -Force [<SwitchParameter>]
            The force parameter will attempt to force any new sorted files to be overwritten if it already exists.

        -ScriptRoot <String>
            The scriptroot parameter sets the default Javinizer module directory. This should not be touched.

        <CommonParameters>
            This cmdlet supports the common parameters: Verbose, Debug,
            ErrorAction, ErrorVariable, WarningAction, WarningVariable,
            OutBuffer, PipelineVariable, and OutVariable. For more information, see
            about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

        -------------------------- EXAMPLE 1 --------------------------

        PS> Javinizer -Apply -Multi

        Description
        -----------
        Performs a multi-threaded sort on your directories with settings specified in your settings.ini file.

        -------------------------- EXAMPLE 2 --------------------------

        PS> Javinizer -Path C:\Downloads -DestinationPath C:\Downloads\Sorted

        Description
        -----------
        Performs a single-threaded sort on your specified Path with other settings specified in your settings.ini file.

        -------------------------- EXAMPLE 3 --------------------------

        PS> Javinizer -Path 'C:\Downloads\Jav\snis-620.mp4' -DestinationPath C:\Downloads\JAV\Sorted\' -Url 'http://www.javlibrary.com/en/?v=javlilljyy,https://www.r18.com/videos/vod/movies/detail/-/id=snis00     620/?i3_ref=search&i3_ord=1,https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=snis00620/?i3_ref=search&i3_ord=4'

        Description
        -----------
        Performs a single-threaded sort on your specified file using direct URLs to match the file.

        -------------------------- EXAMPLE 4 --------------------------

        PS> Javinizer -Find SNIS-420

        Description
        -----------
        Performs a console search of SNIS-420 for all data sources specified in your settings.ini file

        -------------------------- EXAMPLE 5 --------------------------

        PS> Javinizer -Find SNIS-420 -R18 -DMM -Aggregated

        Description
        -----------
        Performs a console search of SNIS-420 for R18 and DMM and aggregates output to your settings specified in your settings.inifile.

        -------------------------- EXAMPLE 6 --------------------------

        PS> Javinizer -Find 'https://www.r18.com/videos/vod/movies/detail/-/id=pred00200/?dmmref=video.movies.new&i3_ref=list&i3_ord=2'

        Description
        -----------
        Performs a console search of PRED-200 using a direct url.
```

## Troubleshooting

Unicode error when trying to translate plot description
Try setting in Windows 10: `Region Settings` -> `Beta: Use Unicode UTF-8 for worldwide language support`



## Todo
- [x] Trailer scraping - [0.1.2]
- [x] Multi-part video directory sort support - [0.1.2]
- [x] Parallel/Threaded sort processing - [0.1.7]
- [x] Allow switching firstname/lastname order - [0.1.7]
- [ ] Normalize genre names between JAVLibrary and R18
- [ ] Normalize studio names between JAVLibrary and R18
