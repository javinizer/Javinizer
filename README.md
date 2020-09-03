# Javinizer (JAV Organizer)
[![Build Status](https://dev.azure.com/jli141928/Javinizer/_apis/build/status/jvlflame.Javinizer?branchName=master)](https://dev.azure.com/jli141928/Javinizer/_build/latest?definitionId=2&branchName=dev)
[![GitHub release](https://img.shields.io/github/v/release/jvlflame/Javinizer?include_prereleases&style=flat&label=release)](https://github.com/jvlflame/Javinizer/releases)
[![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/javinizer?color=red&label=psgallery%20downloads&style=flat)](https://www.powershellgallery.com/packages/Javinizer/)
[![GitHub Downloads](https://img.shields.io/github/downloads/jvlflame/javinizer/total?color=red&label=github%20downloads&style=flat)](https://github.com/jvlflame/Javinizer/releases)
[![Discord](https://img.shields.io/discord/608449512352120834?color=brightgreen&style=flat&label=discord%20chat)](https://discord.gg/K2Yjevk)

A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.

![Demo](media/demo.gif)

## Overview

Build a local JAV media library in a media library like Plex, Jellyfin, Emby, or Kodi.

Javinizer detects your local JAV files and structures them into media library compatible formats. Nfo metadata files are created to be read by the media library.

A rebuild of my previous project [JAV-Sort-Scrape-javlibrary](https://github.com/jvlflame/JAV-Sort-Scrape-javlibrary) as a console-focused application.

[View changelog](.github/CHANGELOG.md)

## Installation

### Install module dependencies

- [PowerShell 6 or PowerShell 7](https://github.com/PowerShell/PowerShell)
- [Python 3+ (64-bit)](https://www.python.org/downloads/) - Linux calls `python3`
    - [Pillow](https://pypi.org/project/Pillow/)
    - [Googletrans](https://pypi.org/project/googletrans/)

```powershell
# python (Windows)
> pip install pillow
> pip install googletrans

# python (Linux)
> pip3 install pillow
> pip3 install googletrans
```

### Install the Javinizer module

Choose one of the methods below:

- Install the module directly from [PowerShell Gallery](https://www.powershellgallery.com/packages/Javinizer/).
```powershell
# Install the module from PowerShell gallery (This will install the latest version by default)
PS> Install-Module Javinizer

# Update the module to the newest version from PowerShell gallery
PS> Update-Module Javinizer
```

- Clone the repository or [download the latest release](https://github.com/jvlflame/Javinizer/releases)

```powershell
# Import the module (you will need to run this every time you open a new shell)
PS> Import-Module ./Javinizer.psm1

# Or add the module files to your appropriate PowerShell version module path
PS> $env:PSModulePath
```

## Usage

### Module settings

Look over the `jvSettings.json` file located in the root `Javinizer` module folder. The settings file contains important fields that you will need to fill out to effectively use the Javinizer program.

```powershell
# Opens your jvSettings.ini file
PS> Javinizer -OpenSettings
```

### Supported multi-part-video naming schemes

The supported filenames for multi-part-videos are as follows. When sorted, all multi-part-videos will be renamed to `ID-###-pt#`.

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
ID-###-cd\d       - ID-069-cd1, ID-069-cd2
```

### Command-line switches

```
PS> help Javinizer

NAME
    Javinizer

SYNOPSIS
    A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.


SYNTAX
    Javinizer [[-Path] <DirectoryInfo>] [[-DestinationPath] <DirectoryInfo>] [-Recurse] [-Depth <Int32>] [-Url <Array>] [-SettingsPath <FileInfo>] [-Strict] [-MoveToFolder <Boolean>]
    [-RenameFile <Boolean>] [-Force] [-HideProgress] [-IsThread] [-Set <Hashtable>] [<CommonParameters>]

    Javinizer [-Find] <PSObject> [-Aggregated] [-Nfo] [-R18] [-R18Zh] [-Dmm] [-Javlibrary] [-JavlibraryZh] [-JavlibraryJa] [-Javbus] [-JavbusJa] [-JavbusZh] [-Jav321] [-Set <Hashtable>]
    [<CommonParameters>]

    Javinizer [-SetEmbyThumbs] [-ReplaceAll] [-Set <Hashtable>] [<CommonParameters>]

    Javinizer [-OpenSettings] [-OpenLog] [-OpenThumbs] [-OpenGenres] [-Set <Hashtable>] [<CommonParameters>]

    Javinizer -UpdateThumbs [-Pages <Array>] [-Set <Hashtable>] [<CommonParameters>]

    Javinizer -Version [<CommonParameters>]

    Javinizer -Help [<CommonParameters>]


DESCRIPTION
    Javinizer detects your local JAV files and structures them into self-hosted media player compatible
    formats. A metadata nfo file is created per file to be read by the media player library.


PARAMETERS
    -Path <DirectoryInfo>
        Specifies the file or directory path to JAV files. Defaults to 'location.input' in the settings file.

    -DestinationPath <DirectoryInfo>
        Specifies the directory path to output sorted JAV files. Defaults to 'location.output' in the settings file.

    -Recurse [<SwitchParameter>]
        Specifies to search sub-directories in your Path.

    -Depth <Int32>
        Specifies the depth of sub-directories to search when using -Recurse.

    -Url <Array>
        Specifies a url or an array of urls to sort a single JAV file.

    -SettingsPath <FileInfo>
        Specifies the path to the settings file you want Javinizer to use. Defaults to the jvSettings.json file in the module root.

    -Strict [<SwitchParameter>]
        Specifies to not automatically try to match filenames to the movie ID. Can be useful for movies like T28- and R18-.

    -MoveToFolder <Boolean>
        Specifies whether or not to move sorted files to its own folder. Defaults to 'sort.movetofolder' in the settings file.

    -RenameFile <Boolean>
        Specifies whether or not to rename sorted files. Defaults to 'sort.renamefile' in the settings file.

    -Force [<SwitchParameter>]
        Specifies to replace all sort files (nfo, images, trailers, etc.) if they already exist. Without -Force,
        only the nfo file will be replaced if it already exists.

    -HideProgress [<SwitchParameter>]
        Specifies to hide the progress bar during sort.

    -IsThread [<SwitchParameter>]
        Specifies that the current running Javinizer instance is a thread. This is for internal purposes only.

    -Find <PSObject>
        Specifies an ID or an array of URLs to search metadata for.

    -Aggregated [<SwitchParameter>]
        Specifies to aggregate the data from -Find according to your settings.

    -Nfo [<SwitchParameter>]
        Specifies to output the nfo contents from -Find.

    -R18 [<SwitchParameter>]
        Specifies to search R18 when using -Find.

    -R18Zh [<SwitchParameter>]
        Specifies to search R18-Chinese when using -Find.

    -Dmm [<SwitchParameter>]
        Specifies to search R18 when using -Find.

    -Javlibrary [<SwitchParameter>]
        Specifies to search Javlibrary when using -Find.

    -JavlibraryZh [<SwitchParameter>]
        Specifies to search Javlibrary-Chinese when using -Find.

    -JavlibraryJa [<SwitchParameter>]
        Specifies to search Javlibrary-Japanese when using -Find.

    -Javbus [<SwitchParameter>]
        Specifies to search Javbus when using -Find.

    -JavbusJa [<SwitchParameter>]
        Specifies to search Javbus-Japanese when using -Find.

    -JavbusZh [<SwitchParameter>]
        Specifies to search Javbus-Chinese when using -Find.

    -Jav321 [<SwitchParameter>]
        Specifies to search Jav321 when using -Find.

    -SetEmbyThumbs [<SwitchParameter>]
        Specifies to set Emby/Jellyfin actress thumbnails using the thumbnail csv. If 'location.thumbcsv' is not specified in the settings file,
        it defaults to the jvGenres.csv file in the module root. 'emby.url' and 'emby.apikey' need to be defined in the settings file.

    -ReplaceAll [<SwitchParameter>]
        Specifies to replace all Emby/Jellyfin actress thumbnails regardless if they already have one.

    -OpenSettings [<SwitchParameter>]
        Specifies to open the settings file.

    -OpenLog [<SwitchParameter>]
        Specifies to open the log file.

    -OpenThumbs [<SwitchParameter>]
        Specifies to open the actress thumbnails file.

    -OpenGenres [<SwitchParameter>]
        Specifies to open the genre replacements file.

    -UpdateThumbs [<SwitchParameter>]
        Specifies to update the actress thumbnails file.

    -Pages <Array>
        Specifies an array as a range of pages to search for and update the actress thumbnails file.

    -Set <Hashtable>
        Specifies a hashtable to update specific settings on the command-line.

    -Version [<SwitchParameter>]
        Specifies to display the Javinizer module version.

    -Help [<SwitchParameter>]
        Specifies to display the Javinizer help.

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


```

### Examples

```
-------------------------- EXAMPLE 1 --------------------------

    PS > Javinizer

    Description
    -----------
    Sorts a path of files using 'location.input' and 'location.output' from your settings file.


    -------------------------- EXAMPLE 2 --------------------------

    PS > Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -DestinationPath 'C:\JAV\Sorted'

    Description
    -----------
    Sorts a single file and move it to the destination path.


    -------------------------- EXAMPLE 3 --------------------------

    PS > Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -Url 'http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/[..]/id=118abp00420/'

    Description
    -----------
    Sorts a single file using specific urls.


    -------------------------- EXAMPLE 4 --------------------------

    PS > Javinizer -Path 'C:\JAV\Unsorted' -Strict

    Description
    -----------
    Sorts a path of JAV files without attemping automatic filename cleaning.


    -------------------------- EXAMPLE 5 --------------------------

    PS > Javinizer -Path 'C:\JAV\Sorted' -DestinationPath 'C:\JAV\Sorted' -RenameFile:$false -MoveToFolder:$false

    Description
    -----------
    Sorts a path of JAV files to its own directory without renaming or moving any files. This is useful for updating already existing directories.


    -------------------------- EXAMPLE 6 --------------------------

    Javinizer -Path 'C:\JAV\Sorted' -Set @{'sort.download.actressimg' = 1; 'sort.format.file' = '<ID>- <TITLE>'}

    Description
    -----------
    Sorts files from a path and specify updated settings from the commmand-line using a hashtable.


    -------------------------- EXAMPLE 7 --------------------------

    PS > Javinizer -Path 'C:\JAV\Sorted' -SettingsPath 'C:\JAV\alternateSettings.json'

    Description
    -----------
    Sorts files from a path and specify an external settings file to use.


    -------------------------- EXAMPLE 8 --------------------------

    PS > Javinizer -Find 'ABP-420' -R18 -Dmm

    Description
    -----------
    Find a movie metadata on R18 and DMM by specifying its id.


    -------------------------- EXAMPLE 9 --------------------------

    PS > Javinizer -Find 'http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/[..]/id=118abp00420/' -Aggregated

    Description
    -----------
    Find an array of urls metadata and aggregates them according to your settings file.


    -------------------------- EXAMPLE 10 --------------------------

    PS > Javinizer -Find 'ABP-420' -R18 -Javlibrary -Dmm -Aggregated -Nfo

    Description
    -----------
    Find a movie metadata on R18 and DMM by specifying its id, aggrregates the data, and outputs the corresponding nfo contents.


    -------------------------- EXAMPLE 11 --------------------------

    PS > Javinizer -SetEmbyThumbs

    Description
    -----------
    Sets missing Emby/Jellyfin actress thumbnails using the actress thumbnail file. Settings 'emby.url' and 'emby.apikey' need to be defined.


    -------------------------- EXAMPLE 12 --------------------------

    PS > Javinizer -SetEmbyThumbs -ReplaceAll

    Description
    -----------
    Sets/replaces all Emby/Jellyfin actress thumbnails using the actress thumbnail file. Settings 'emby.url' and 'emby.apikey' need to be defined.


    -------------------------- EXAMPLE 13 --------------------------

    PS > Javinizer -OpenSettings

    Description
    -----------
    Opens the settings file.
```

## Content Management System (CMS) Setup

| CMS | How to use |
| ------------- | ------------- |
| Plex  | Set-up a `Movie` library with custom agent [XBMCnfoMoviesImporter.bundle](https://github.com/gboudreau/XBMCnfoMoviesImporter.bundle). Turn on settings `Enable generating Collections from tags` and `Use plot instead of outline`   |
| Emby | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `settings.ini` file and use `Javinizer -SetEmbyActorThumbs` to set actress thumbnails |
| Jellyfin | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `settings.ini` file and use `Javinizer -SetEmbyActorThumbs` to set actress thumbnails |

## Settings Information

To do
