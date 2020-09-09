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

[**View changelog**](.github/CHANGELOG.md)

[**View v1.x.x docs**](https://github.com/jvlflame/Javinizer/blob/release/1.7.3/README.md)

## Installation

### Install module dependencies

- [PowerShell 6/7](https://github.com/PowerShell/PowerShell)
- [Python 3](https://www.python.org/downloads/)
    - [Pillow](https://pypi.org/project/Pillow/)
    - [Googletrans](https://pypi.org/project/googletrans/)

```powershell
# Python
# Use pip3 on Linux
> pip install pillow
> pip install googletrans

```

Running Javinizer on Linux will call Python commands with `python3`.

### Install the Javinizer module

Choose one of the methods below:

- Install the module directly from [PowerShell Gallery](https://www.powershellgallery.com/packages/Javinizer/) using PowerShell 6/7
```powershell
# Install the module from PowerShell gallery (This will install the latest version by default)
# Add -AllowPrelease to download a preview build
PS> Install-Module Javinizer

# Update the module to the newest version from PowerShell gallery
# Add -AllowPrelease to download a preview build
PS> Update-Module Javinizer
```

- Clone the repository or [download the latest release](https://github.com/jvlflame/Javinizer/releases)

```powershell
# Import the module (you will need to run this every time you open a new shell)
# Add this to your PS Profile for it to import automatically on startup
PS> Import-Module ./Javinizer.psm1

# Or add the module files to your appropriate PowerShell version module path
PS> $env:PSModulePath
```

## Usage

### Module settings

Look over the `jvSettings.json` file located in the root `Javinizer` module folder. The settings file contains important fields that you will need to fill out to effectively use the Javinizer program.

Settings documentation is located [here](#Settings-Information).

```powershell
# Opens your jvSettings.ini file
PS> Javinizer -OpenSettings
```


### Command-line usage

```
PS> help Javinizer

NAME
Javinizer

SYNOPSIS
A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.


SYNTAX
Javinizer [[-Path] <DirectoryInfo>] [[-DestinationPath] <DirectoryInfo>] [-Recurse] [-Depth <Int32>] [-Url <Array>] [-SettingsPath
<FileInfo>] [-Strict] [-MoveToFolder <Boolean>] [-RenameFile <Boolean>] [-Force] [-HideProgress] [-IsThread] [-Set <Hashtable>]
[<CommonParameters>]

Javinizer [-Path] <DirectoryInfo> [-Recurse] [-Depth <Int32>] -UpdateNfo [<CommonParameters>]

Javinizer [-Find] <PSObject> [-Aggregated] [-Nfo] [-R18] [-R18Zh] [-Dmm] [-Javlibrary] [-JavlibraryZh] [-JavlibraryJa] [-Javbus]
[-JavbusJa] [-JavbusZh] [-Jav321] [-Set <Hashtable>] [<CommonParameters>]

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

PS > Javinizer -Path 'C:\JAV\Sorted' -Recurse -UpdateNfo -Verbose

Description
-----------
Updates existing sorted nfo files from a path with updated aliases, thumburls, names, ignored genres, and genre replacements according to the settings.

-------------------------- EXAMPLE 14 --------------------------

PS > Javinizer -UpdateThumbs -Pages 1,10

Description
-----------
Updates the actress csv file using a range of pages to scrape from.

-------------------------- EXAMPLE 14 --------------------------

PS > Javinizer -OpenSettings

Description
-----------
Opens the settings file.

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

### In-depth usage

#### Actress Thumb Csv

Javinizer can utilize a csv file of actresses scraped from R18.com to further match actresses and their respective names/thumbnail URLs.

```powershell
# Opens the actress csv file
PS > Javinizer -OpenThumbs

# Scrapes the first 10 pages of actresses sorted by new in R18.com
PS > Javinizer -UpdateThumbs -Pages 1,10 -Verbose
```

It is enabled by the following settings:
- `location.thumbcsv` - If blank, this will point to the file located within your module root directory.
- `sort.metadata.thumbcsv`
- `sort.metadata.thumbcsv.convertalias`

After your scraper data is aggregated using your metadata priority settings, Javinizer will automatically attempt to match the actress by `JapaneseName` from the scraper.

If the actress is matched, then the full details (FirstName, LastName, JapaneseName, ThumbUrl) are written to that actress. The FullName column is not used in any way except for reference.

If `sort.metadata.thumbcsv.convertalias` is enabled in addition to `sort.metadata.thumbcsv`, then Javinizer will automatically convert any of the listed aliases (separated by `|` and entered in `LastName FirstName` format) to the actress that the alias corresponds to.

For example, if your jvThumbs.csv file looks like this:

| FullName | LastName | FirstName | JapaneseName | ThumbUrl | Alias |
| -------- | -------- | --------- | ------------ | -------- | ----- |
Aoi Rena | Aoi | Rena | あおいれな | https://[..]/aoi_rena.jpg | Kobayakawa Reiko\|小早川怜子
Hamasaki Mao | Hamasaki | Mao | 浜崎真緒 | https://[..]/hamasaki_mao.jpg | Fukada Eimi
Nagase Yui | Nagase | Yui | 永瀬ゆい |https://[..]/nagase_yui2.jpg | Aika

- Any scraped actress that matches `LastName: Kobayakawa; FirstName: Reiko` or `JapaneseName: 小早川怜子` will be converted to `Aoi Rena`
- Any scraped actress that matches `LastName: Fukada; FirstName: Eimi` will be converted to `Hamasaki Mao`
- Any scraped actress that matches `FirstName: Aika` will be converted to `Nagase Yui`

If `sort.metadata.thumbcsv.autoadd` is enabled in addition to `sort.metadata.thumbcsv`, then Javinizer will automatically add any missing actresses scraped from the R18 or R18Zh scrapers to your thumbnail csv.

#### Genre Csv

Javinizer can utilize a csv file of genres to replace them with a genre of your choice.

```powershell
# Opens the genre replacement csv file
PS > Javinizer -OpenGenres
```

It is enabled by the following settings:
- `location.genrecsv` - If blank, this will point to the file located within your module root directory.
- `sort.metadata.genrecsv`

A default genre csv file is included with Javinizer which will replace Javlibrary genres with their R18 counterparts.

For example, if your jvGenres.csv file looks like this:

| Original | Replacement |
| -------- | ----------- |
| Blow | Blowjob

- Any scraped genre that equals `Blow` will be replaced with `Blowjob`

## Settings Information

| Setting | Description | Accepted or Example Value |
| ------------- | ------------- | ------------- |
| `throttlelimit` | Specifies the limit Javinizer will run video sorting threads. | 1-10
| `location.input` | Specifies the default -Path that Javinizer will use to sort videos. | C:\\\JAV\\\Unsorted
| `location.output` | Specifies the default -DestinationPath that Javinizer will use to sort videos. | C:\\\JAV\\\Unsorted
| `location.thumbcsv` | Specifies the location of the actress thumbnail csv that is used to better match actresses. This will point to the file within the Javinizer module folder by default. | C:\\\JAV\\\jvThumbs.csv
| `location.genrecsv` | Specifies the location of the genre replacement csv that is used to do a string replacement of genres of your choice. This will point to the file within your Javinizer module folder by default. | C:\\\JAV\\\jvGenres.csv
| `location.log` | Specifies the location of the log file. This will point to the file within the Javinizer module folder by default. | C:\\\JAV\\\jvLogs.log
| `scraper.movie.dmm` | Specifies whether the dmm.com scraper is on/off. | 0, 1
| `scraper.movie.jav321ja` | Specifies whether the jav321.com scraper is on/off. | 0, 1
| `scraper.movie.javbus` | Specifies whether the javbus.com scraper is on/off. | 0, 1
| `scraper.movie.javbusja` | Specifies whether the javbus.com japanese scraper is on/off. | 0, 1
| `scraper.movie.javbuszh` | Specifies whether the javbus.com chinese scraper is on/off. | 0, 1
| `scraper.movie.javlibrary` | Specfies whether the javlibrary.com scraper is on/off. | 0, 1
| `scraper.movie.javlibraryja` | Specifies whether the javlibrary.com japanese scraper is on/off. | 0, 1
| `scraper.movie.javlibraryzh` | Specifies whether the javlibrary.com chinese scraper is on/off. | 0, 1
| `scraper.movie.r18` | Specifies whether the r18.com scraper is on/off. | 0, 1
| `scraper.movie.r18zh` | Specifies whether the r18.com chinese scraper is on/off. | 0, 1
| `match.minimumfilesize` | Specifies the minimum filesize that Javinizer will find when performing a directory search in MB. | Any number
| `match.includedfileextension` | Specifies the extensions that Javinizer will find when performing a directory search. | ".ext"
| `match.excludedfilestring` | Specifies the file strings that Javinizer will ignore when performing a directory search using regex | "^.*-trailer*"
| `match.regex` | Specifies that Javinizer will perform the directory search using regex rather than the default matcher | 0, 1
| `match.regex.string` | Specifies the regex string that Javinizer will use to perform the directory search. | Regex string
| `match.regex.idmatch` | Specifies the regex match of the movie's ID of the regex string. | Any number
| `match.regex.ptmatch` | Specifies the regex match of the movie's part number of the regex string. | Any number
| `sort.movetofolder` | Specifies to move the movie to its own folder after being sorted. | 0, 1
| `sort.renamefile` | Specifies to rename the movie file after being sorted. | 0, 1
| `sort.maxtitlelength` | Specifies the max metadata title length when using it in a format string. | Any number
| `sort.create.nfo` | Specifies to create the nfo file when sorting a movie. | 0, 1
| `sort.create.nfoperfile` | Specifies to create a nfo file per part when sorting a movie. This will override any renaming done on the nfo file and instead use the filename. | 0, 1
| `sort.download.actressimg` | Specifies to download actress images when sorting a movie. | 0, 1
| `sort.download.thumbimg` | Specifies to download the thumbnail image when sorting a movie. | 0, 1
| `sort.download.posterimg` | Specifies to create the poster image when sorting a movie. Sort.download.thumbimg is required for this to function. | 0, 1
| `sort.download.screenshotimg` | Specifies to download screenshot images when sorting a movie. | 0, 1
| `sort.download.trailervid` | Specifies to download the trailer video when sorting a movie. | 0, 1
| `sort.format.delimiter` | Specifies the delimiter between actresses when using \<ACTORS> in the format string. | Any string value
| `sort.format.file` | Specifies the format string when renaming a file. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.folder` | Specifies the format string when creating the folder. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.posterimg` | Specifies an array of format string when creating the poster image. Multiple strings will allow you to create multiple poster image files. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.thumbimg` | Specifies the format string when creating the thumbnail image. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.trailervid` | Specifies the format string when creating the trailer video. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.nfo` | Specifies the format string when creating the nfo. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.screenshotimg` | Specifies the format string when creating the screenshot images. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.screenshotfolder` | Specifies the format string when creating the screenshot images folder. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.format.actressimgfolder` | Specifies the format string when creating the actress image folder. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.metadata.nfo.translatedescription` | Specifies to translate the description | 0, 1
| `sort.metadata.nfo.translatedescription.language` | Specifies which language to translate to.  | Check [here](https://developers.google.com/admin-sdk/directory/v1/languages) for language codes
| `sort.metadata.nfo.displayname` | Specifies the format string of the displayname in the metadata nfo file. | <\ID>, <\TITLE>, <\RELEASEDATE>, <\YEAR>, <\STUDIO>, <\RUNTIME>, <\SET>, <\LABEL>, <\ACTORS>, <\ORIGINALTITLE>
| `sort.metadata.nfo.seriesastag` | Specifies to add the <\SET> metadata as <\TAG> as well for Emby/Jellyfin support | 0, 1
| `sort.metadata.nfo.actresslanguageja` | Specifies to prefer Japanese names when creating the metadata nfo. | 0, 1
| `sort.metadata.thumbcsv` | Specifies to use the thumbnail csv when aggregating metadata. | 0, 1
| `sort.metadata.thumbcsv.autoadd` | Specifies to automatically add missing actresses to the thumbnail csv when scraping using the R18 or R18Zh scrapers. | 0, 1
| `sort.metadata.thumbcsv.convertalias` | Specifies to use the thumbnail csv alias field to replace actresses in the metadata. | 0, 1
| `sort.metadata.genrecsv` | Specifies to use the genre csv to replace genres in the metadata. | 0, 1
| `sort.metadata.genre.ignore` | Specifies an array of genres to ignore in the metadata. | Array of string values
| `sort.metadata.requiredfield` | Specifies the required metadata fields which will constitute a successful sort. | Array of string metadata field names
| `sort.metadata.priority.actress` | Specifies the array of scrapers to prioritize the actress metadata. | Array of string metadata field names
| `sort.metadata.priority.alternatetitle` | Specifies the array of scrapers to prioritize the alternatetitle metadata. | Array of string metadata field names
| `sort.metadata.priority.coverurl` | Specifies the array of scrapers to prioritize the coverurl metadata. | Array of string metadata field names
| `sort.metadata.priority.description` | Specifies the array of scrapers to prioritize the description metadata. | Array of string metadata field names
| `sort.metadata.priority.director` | Specifies the array of scrapers to prioritize the director metadata. | Array of string metadata field names
| `sort.metadata.priority.genre` | Specifies the array of scrapers to prioritize the genre metadata. | Array of string metadata field names
| `sort.metadata.priority.id` | Specifies the array of scrapers to prioritize the ID metadata. | Array of string metadata field names
| `sort.metadata.priority.label` | Specifies the array of scrapers to prioritize the label metadata. | Array of string metadata field names
| `sort.metadata.priority.maker` | Specifies the array of scrapers to prioritize the maker metadata. | Array of string metadata field names
| `sort.metadata.priority.rating` | Specifies the array of scrapers to prioritize the rating metadata. | Array of string metadata field names
| `sort.metadata.priority.releasedate` | Specifies the array of scrapers to prioritize the releasedate metadata. | Array of string metadata field names
| `sort.metadata.priority.runtime` | Specifies the array of scrapers to prioritize the runtime metadata. | Array of string metadata field names
| `sort.metadata.priority.series` | Specifies the array of scrapers to prioritize the series metadata. | Array of string metadata field names
| `sort.metadata.priority.screenshoturl` | Specifies the array of scrapers to prioritize the screenshoturl metadata. | Array of string metadata field names
| `sort.metadata.priority.title` | Specifies the array of scrapers to prioritize the title metadata. | Array of string metadata field names
| `sort.metadata.priority.trailerurl` | Specifies the array of scrapers to prioritize the trailerurl metadata. | Array of string metadata field names
| `emby.url` | Specifies the base URL of your Emby/Jellyfin instance to add actress images. | http:\\/\\/192.168.0.1:8096
| `emby.apikey` | Specifies the API key of your Emby/Jellyfin instance. | API Key string
| `javlibrary.baseurl` | Specifies the base URL of the Javlibrary instance you want to scrape. This is useful if you are running into CloudFlare errors on the main site and want to use a mirror. | http:\\/\\/javlibrary.com
| `admin.log` | Specifies to write debug, warning, error, and verbose messages to the log file. | 0, 1
| `admin.log.level` | Specifies the level of logs that will be written to the log file. | Debug, Info, Warning, Error

## Media Library Setup

| CMS | How to use |
| ------------- | ------------- |
| Plex  | Set-up a `Movie` library with custom agent [XBMCnfoMoviesImporter.bundle](https://github.com/gboudreau/XBMCnfoMoviesImporter.bundle). Turn on settings `Enable generating collections from tags` and `Use plot instead of outline`   |
| Emby | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `jvSettings.json` file and use `Javinizer -SetEmbyThumbs` to set actress thumbnails |
| Jellyfin | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `jvSettings.json` file and use `Javinizer -SetEmbyThumbs` to set actress thumbnails |
