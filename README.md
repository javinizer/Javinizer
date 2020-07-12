# Javinizer (JAV Organizer)
[![Build Status](https://dev.azure.com/jli141928/Javinizer/_apis/build/status/jvlflame.Javinizer?branchName=master)](https://dev.azure.com/jli141928/Javinizer/_build/latest?definitionId=2&branchName=master)
[![GitHub release](https://img.shields.io/github/v/release/jvlflame/Javinizer?include_prereleases&style=flat&label=release)](https://github.com/jvlflame/Javinizer/releases)
[![Last commit](https://img.shields.io/github/commits-since/jvlflame/Javinizer/latest/staging?style=flat&color=blue)](https://github.com/jvlflame/Javinizer/commits/staging)
[![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/javinizer?color=red&label=psgallery%20downloads&style=flat)](https://www.powershellgallery.com/packages/Javinizer/)
[![GitHub Downloads](https://img.shields.io/github/downloads/jvlflame/javinizer/total?color=red&label=github%20downloads&style=flat)](https://github.com/jvlflame/Javinizer/releases)
[![Discord](https://img.shields.io/discord/608449512352120834?color=brightgreen&style=flat&label=discord%20chat)](https://discord.gg/K2Yjevk)

A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.

![Demo](media/demo.gif)

## Overview

Build a local JAV media library in a content management system (CMS) like Plex, Jellyfin, or Emby.

A rebuild of my previous project [JAV-Sort-Scrape-javlibrary](https://github.com/jvlflame/JAV-Sort-Scrape-javlibrary) as a console-focused application.

[View changelog](.github/CHANGELOG.md)

## Installation

### Install module dependencies

- [PowerShell 6 or PowerShell 7](https://github.com/PowerShell/PowerShell) - Windows PowerShell 5 is **NOT** supported
- [Python 3+ (64-bit)](https://www.python.org/downloads/) - Linux calls `python3`
    - [Cloudscraper](https://pypi.org/project/cloudscraper/)
    - [Pillow](https://pypi.org/project/Pillow/)
    - [Googletrans](https://pypi.org/project/googletrans/)

```powershell
# python (Windows)
> pip install cloudscraper
> pip install pillow
> pip install googletrans

# python (Linux)
> pip3 install cloudscraper
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

Please look over the `settings.ini` file located in the root `Javinizer` module folder. The settings file contains important fields that you will need to fill out to effectively use the Javinizer program.

```powershell
# Opens your settings.ini file
PS> Javinizer -OpenSettings

# Backup your settings.ini and r18-thumbs.csv file to an archive, use if you want to persist your settings between module upgrades
PS> Javinizer -BackupSettings 'C:\Users\UserName\Documents\JavinizerSettings.zip'

# Restore your backup settings archive to the module folder
PS> Javinizer -RestoreSettings 'C:\Users\UserName\Documents\JavinizerSettings.zip'
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
    A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files


SYNTAX
    Javinizer [[-Path] <String>] [[-DestinationPath] <String>] [-Url <String>] [-Apply] [-Multi] [-Recurse] [-Strict][-Force] [-ImportSettings <String>]
    [-MoveToFolder <Boolean>] [-RenameFile <Boolean>] [-R18] [-R18Zh] [-Dmm] [-Javlibrary] [-JavlibraryZh] [-JavlibraryJa] [-Javbus] [-JavbusJa] [-Jav321] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-Find] <String> [-Aggregated] [-R18] [-R18Zh] [-Dmm] [-Javlibrary] [-JavlibraryZh] [-JavlibraryJa] [-Javbus] [-JavbusJa] [-Jav321] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-Help] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-Version] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-OpenSettings] [-BackupSettings <String>] [-RestoreSettings <String>] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-OpenLog] [-ViewLog <String>] [-LogLevel <String>] [-Entries <Int32>] [-Order <String>] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-SetJavlibraryOwned <String>] [-ScriptRoot <String>] [<CommonParameters>]

    Javinizer [-GetThumbs] [-UpdateThumbs <Int32>] [-OpenThumbs] [-SetEmbyActorThumbs] [-ScriptRoot <String>] [<CommonParameters>]


DESCRIPTION
    Javinizer is used to pull data from online data sources such as JAVLibrary, DMM, and R18 to aggregate data into a CMS (Plex,Emby,Jellyfin) parseable format.


PARAMETERS
    -Find <String>
        The find parameter will output a list-formatted data output from the data sources specified using a movie ID, file path, or URL.

    -Aggregated [<SwitchParameter>]
        The aggregated parameter will create an aggregated list-formatted data output from the data sources specified as well as metadata priorities in your settings.ini file.

    -Path <String>
        The path parameter sets the file or directory path that Javinizer will search and sort files in.

    -DestinationPath <String>
        The destinationpath parameter sets the directory path that Javinizer will send sorted files to.

    -Url <String>
        The url parameter allows you to set direct URLs to JAVLibrary, DMM, and R18 data sources to scrape a video from in direct URLs comma-separated-format (url1,url2,url3).

    -Apply [<SwitchParameter>]
        The apply parameter allows you to automatically begin your sort using settings specified in your settings.ini file.

    -Multi [<SwitchParameter>]
        The multi parameter will perform your sort using multiple concurrent threads with a throttle limit of (1-5) set in your settings.ini file.

    -Recurse [<SwitchParameter>]
        The recurse parameter will perform your sort recursively within your specified sort directory.

    -Strict [<SwitchParameter>]
        The strict parameter will perform your sort without automatically cleaning your filenames. It will read the exact filename.

    -Force [<SwitchParameter>]
        The force parameter will attempt to force any new sorted files to be overwritten if it already exists.

    -ImportSettings <String>
        The importsettings parameter allows you to specify an external settings file. This is useful if you want to have different presets for groups of videos.

    -MoveToFolder <Boolean>
        The movetofolder parameter will allow you to set a true/false value for the setting move-to-folder from the commandline.

    -RenameFile <Boolean>
        The renamefile parameter will allow you to set a true/false value for the setting rename-file from the commandline.

    -Help [<SwitchParameter>]
        The help parameter will open a help dialogue in your console for Javinizer usage.

    -Version [<SwitchParameter>]
        The version parameter will display Javinizer's current module version.

    -OpenSettings [<SwitchParameter>]
        The opensettings parameter will open your settings.ini file for you to view and edit.

    -BackupSettings <String>
        The backupsettings parameter will backup your settings.ini and r18-thumbs.csv file to an archive.

    -RestoreSettings <String>
        The restoresettings parameter will restore your archive created from the backupsettings parameter to the root module folder.

    -OpenLog [<SwitchParameter>]
        The openlog parameter will open your Javinizer.log file located in your module path.

    -ViewLog <String>
        The viewlog parameter will output the Javinizer.log file as a JSON object in your PowerShell console.

    -LogLevel <String>
        The loglevel parameter will allow you to select which logging level to view (INFO, ERROR, WARN, DEBUG)

    -Entries <Int32>
        The entries parameter lets you select the amount of log entries to view

    -Order <String>
        The order parameter lets you select which sort order to view your log entries (Asc, Desc) with descending being default

    -SetJavlibraryOwned <String>
        The setjavlibraryowned parameter lets you reference a path to a list of your JAV movies in line separated format in a flat text file to set as owned on JAVLibrary

    -GetThumbs [<SwitchParameter>]
        The getthumbs parameter will fully update your R18 actress and thumbnail csv database file which will attempt to write
        unknown actress thumburls on sort.

    -UpdateThumbs <Int32>
        The updatethumbs parameter will partially update your R18 actress and thumbnail csv database file with a specified number of R18.com pages.

    -OpenThumbs [<SwitchParameter>]
        The openthumbs parameter will open your r18-thumbs.csv file for you to view and edit.

    -SetEmbyActorThumbs [<SwitchParameter>]
        The setembyactorthumbs parameter will POST matching R18 actor images from `r18-thumbs.csv` to your Emby or Jellyfin instance.

    -R18 [<SwitchParameter>]
        The r18 parameter allows you to set your data source of R18 to true.

    -R18Zh [<SwitchParameter>]
        The r18zh parameter allows you to set your data source of R18Zh to true.

    -Dmm [<SwitchParameter>]
        The dmm parameter allows you to set your data source of DMM to true.

    -Jav321 [<SwitchParameter>]
        The jav321 parameter allows you to set your data source of Jav321 to true.

    -Javbus [<SwitchParameter>]
        The javbus parameter allows you to set your data source of JAVLibraryJa to true.

    -JavbusJa [<SwitchParameter>]
        The javbusja parameter allows you to set your data source of JavbusJa to true.

    -Javlibrary [<SwitchParameter>]
        The javlibrary parameter allows you to set your data source of JAVLibrary to true.

    -JavlibraryZh [<SwitchParameter>]
        The javlibraryzh parameter allows you to set your data source of JAVLibraryZh to true.

    -JavlibraryJa [<SwitchParameter>]
        The javlibraryja parameter allows you to set your data source of JAVLibraryJa to true.

    -ScriptRoot <String>
        The scriptroot parameter sets the default Javinizer module directory. This should not be touched.

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

```

### Examples

```

    -------------------------- EXAMPLE 1 --------------------------

    PS>Javinizer -OpenSettings

    Description
    -----------
    Opens your Javinizer settings.ini file in the root module directory.

    -------------------------- EXAMPLE 2 --------------------------

    PS>Javinizer -Path C:\Downloads\Unsorted -Multi

    Description
    -----------
    Performs a multi-threaded sort on C:\Downloads\Unsorted with settings specified in your settings.ini file.

    -------------------------- EXAMPLE 3 --------------------------

    PS>Javinizer -Apply -Multi

    Description
    -----------
    Performs a multi-threaded sort on your directories with settings specified in your settings.ini file.

    -------------------------- EXAMPLE 4 --------------------------

    PS>Javinizer -Path C:\Downloads\Jav\Sorted -Recurse -MoveToFolder:$false -RenameFile:$false -Multi

    Description
    -----------
    Performs a multi-threaded recursive sort on your directories while setting move-to-folder and rename-file false to refresh metadata within those directories.

    -------------------------- EXAMPLE 5 --------------------------

    PS>Javinizer -Path C:\Downloads -ImportSettings C:\Downloads\settings-template1.ini -Multi

    Description
    -----------
    Performs a multi-threaded sort on your directories while importing an external settings file.

    -------------------------- EXAMPLE 6 --------------------------

    PS>Javinizer -Path C:\Downloads -DestinationPath C:\Downloads\Sorted -Recurse

    Description
    -----------
    Performs a single-threaded recursive sort on your specified Path with other settings specified in your settings.ini file.

    -------------------------- EXAMPLE 7 --------------------------

    PS> Javinizer -Path 'C:\Downloads\Jav\snis-620.mp4' -DestinationPath C:\Downloads\JAV\Sorted\ -Url 'http://www.javlibrary.com/en/?v=javlilljyy,https://www.r18.com/videos/vod/movies/detail/-/id=snis00620/?i3_ref=search&i3_ord=1,https://www.dmm.co.jp/digitalvideoa/-/detail/=/cid=snis00620/?i3_ref=search&i3_ord=4'

    Description
    -----------
    Performs a single-threaded sort on your specified file using direct URLs to match the file.

    -------------------------- EXAMPLE 8 --------------------------

    PS>Javinizer -Find SNIS-420

    Description
    -----------
    Performs a console search of SNIS-420 for all data sources specified in your settings.ini file.

    -------------------------- EXAMPLE 9 --------------------------

    PS>Javinizer -Find SNIS-420 -R18 -DMM -Aggregated

    Description
    -----------
    Performs a console search of SNIS-420 for R18 and DMM and aggregates output to your settings specified in your settings.ini file.

    -------------------------- EXAMPLE 10 --------------------------

    PS>Javinizer -Find 'https://www.r18.com/videos/vod/movies/detail/-/id=pred00200/?dmmref=video.movies.new&i3_ref=list&i3_ord=2'

    Description
    -----------
    Performs a console search of PRED-200 using a direct url.

    -------------------------- EXAMPLE 11 --------------------------

    PS>Javinizer -SetEmbyActorThumbs

    Description
    -----------
    Writes actor thumbnails to your Emby/Jellyfin server instance from your r18-thumbs.csv file.

    -------------------------- EXAMPLE 12 --------------------------

    PS> Javinizer -ViewLog List -Entries 5 -LogLevel Error

    Description
    -----------
    Writes your latest 5 error log entries in list view to the console from your Javinizer log file.

    -------------------------- EXAMPLE 13 --------------------------

    PS>Javinizer -ViewLog | Select-Object -First 10 | Sort-Object timestamp -Descending | Format-Table wrap

    Description
    -----------
    Outputs your Javinizer log file to the console as a PowerShell object.

```

## Content Management System (CMS) Setup

| CMS | How to use |
| ------------- | ------------- |
| Plex  | Set-up a `Movie` library with custom agent [XBMCnfoMoviesImporter.bundle](https://github.com/gboudreau/XBMCnfoMoviesImporter.bundle). Turn on settings `Enable generating Collections from tags` and `Use plot instead of outline`   |
| Emby | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `settings.ini` file and use `Javinizer -SetEmbyActorThumbs` to set actress thumbnails |
| Jellyfin | Set-up a `Movie` library with all metadata/image downloaders disabled. Input your server url and API key in the `settings.ini` file and use `Javinizer -SetEmbyActorThumbs` to set actress thumbnails |

## Settings Information

Setting | Accepted Values | Details
--- | :---: | ---
scrape-r18 | True/False | Turns on the scraper for the English version of r18.com
scrape-r18zh | True/False | Turns on the scraper for the Chinese version of r18.com
scrape-dmm | True/False | Turns on the scraper for dmm.co.jp
scrape-javlibrary | True/False | Turns on the scraper for the English version of javlibrary.com
scrape-javlibraryja | True/False | Turns on the scraper for the Japanese version of javlibrary.com
scrape-javlibraryzh | True/False | Turns on the scraper for the Chinese version of javlibrary.com
scrape-javbus | True/False | Turns on the scraper for the English version of javbus.com
scrape-javbusja | True/False | Turns on the scraper for the Japanese version of javbus.com
scrape-jav321 | True/False | Turns on the scraper for the Japanese version of jav321.com
scrape-actress-en | True/False | Turns on the scraper for english actress names on R18.com
scrape-actress-ja | True/False | Turns on the scraper for japanese actress names on R18.com
multi-sort-throttle-limit | Integer value (1-15) | Sets the amount of threads to run the sort in parallel
move-to-folder | True/False | Moves the sorted video to a new directory if found by scrapers
rename-file | True/False | Renames the sorted video if found by scrapers
rename-file-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the file to your designated string value if `rename-file` is True
rename-folder-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the folder to your designated string value if `move-to-folder` is True
cms-displayname-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the nfo title to your designated string value which is displayed in Plex/Emby/Jellyfin
actors-name-delimiter | String value | Sets the delimiter between actor names in your rename strings
poster-file-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the poster image to your designated string value
thumbnail-filestring | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the thumbnail image to your designated string value
trailer-file-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the trailer video to your designated string value
nfo-file-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the nfo metadata file to your designated string value
screenshot-folder-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the movie screenshot folder to your designated string value
screenshot-img-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the movie screenshot image to your designated string value with an appended increasing numeric value
actorimg-folder-string | \<ID> \<TITLE> \<STUDIO> \<YEAR> \<RELEASEDATE> \<RUNTIME> \<ACTORS> \<LABEL> \<SET> \<ORIGINALTITLE> | Renames the actor image folder to your designated string value
max-title-length | Integer value (1-255) | Sets the amount of characters to limit the metadata \<TITLE> to if it is included in your `rename-file-string` or `rename-folder-string`
max-path-length | Integer value (0+) | Sets the amount of characters to limit the full path length of sorted file (e.g `C:\JAV\Sorted\MIRD-149 [MOODYZ] - Fan Thanksgiving Day From MOODYZ! Creampies From The Comfort Of Home! A 4 Hour Large Orgies Special (2015)\MIRD-149.wmv` is 153 characters)
minimum-filesze-to-sort | Integer value (0+) | Sets the minimum filesize video for Javinizer to read from your sort directory in MB
included-file-extensions | String value | Sets the file extension types for Javinizer to read from your sort directory in comma separated format (no spaces)
excluded-file-strings | String value | Sets the paths/string values with wildcards (*) for Javinizer to ignore from your sort directory in comma separated format (no spaces)
regex-match | True/False | Sets Javinizer to match your JAV files using a regular expression instead of the default matcher; The JAV ID in the filename must match website metadata exactly to successfully match
regex-id-match | Integer value (0+) | Sets the regex match value of the movie Id in the filename
regex-pt-match | Integer value (0+) | Sets the regex match value of the movie part number in the filename
regex | String value | The regular expression string to match files if `regex-match=True`; Match 1 should be the movie ID (e.g. ABP-234), Match 2 (optional) should be the part number of the movie (e.g. 2)
create-nfo | True/False | Creates a .nfo metadata file for the sorted movie that follows the nfo-file-string naming format
create-nfo-per-file | True/False |  Creates a .nfo metadata for each sorted movie that mirrors the name of the movie (Required for Emby/Jellyfin)
download-thumb-img | True/False | Downloads the movie full-size cover image
download-poster-img | True/False | Crops the movie full-size cover image to poster size
download-trailer-vid | True/False | Downloads the movie trailer to your movie directory
download-actress-img | True/False | Downloads the actress images to the `.actors` directory in your movie directory
translate-description | True/False | Translates the Japanese movie description from dmm.co.jp
translate-description-language | String value | Sets the language of the movie description translation. Check [here](https://developers.google.com/admin-sdk/directory/v1/languages) for language codes
add-series-as-tag | True/False | Adds the \<tag> metadata line to your movie nfo to work with Emby tags; \<set> is added by default
first-last-name-order | True/False | Sets the first/last name order for the actresses in your nfo metadata; True = `FirstName LastName` / False = `LastName FirstName`
convert-alias-to-originalname | True/False | Converts actresses scraped from other sources (JAVLibrary) to their respective names on R18 if added to the `Alias` column in your `r18-thumbs.csv` file
normalize-genres | True/False | Converts genres scraped from JAVLibrary to their respective names on R18 using your `genres.csv` file
ignored-genres | String value | Sets genres to ignore from adding to your nfo metadata in comma separated format (no spaces)
required-metadata-fields | actress, actressthumburl, alternatetitle, coverurl, description, director, genre, id, label, maker, rating, ratingcount, releasedate, releaseyear, runtime, series, screenshoturl, title, trailerurl | Sets the required metadata fields that are required to be scraped to successfully sort the video in comma separated format (no spaces)
\<metadata>-priority | r18, r18zh, javlibrary, javlibraryja, javlibraryzh, dmm | Sets the order in which each metadata field is scraped in comma separated format (no spaces). Some sources may not contain the specific metadata field, so play around with the `-Find` parameter to see which source contains which fields
input-path | String value (Path) | The path to your unsorted JAV files
output-path | String value (Path) | The path to where you want your unsorted JAV files to be sent to when sorted successfully
server-url | String value (URL) | The address to your Emby/Jellyfin server
server-api-key | String value | The API key for your Emby/Jellyfin server instance
set-owned | True/False | Sets sorted movies as "Owned" on JAVLibrary, requires a JAVLibrary account
username | String value | Your JAVLibrary username
session-cookie | String value | After logging in, view the cookies under the `www.javlibrary.com/cookies/session` directory and copy the cookie content
request-timeout-sec | Integer value (0+) | Sets the timeout value in seconds on how long Javinizer will continue polling Javinizer to set the owned status (polls every 3 seconds)
log-path | String value (Path) | Sets the path to your log file; If left blank, it will default to a location within your module folder
check-updates | True/False | Checks for updates to the Javinizer module upon your first console session runtime
verbose-shell-output | True/False | Displays verbose output to your shell
debug-shell-output | True/False | Displays debug output to your shell

## Other notes
- If your library consists of both censored and uncensored movies, I recommend keeping 2 separate settings files for each group. You can then use the `-ImportSettings` parameter to specify the second settings file
- If you are scraping large amounts of videos (1000+) with `translate-description=True`, do note that you may get IP banned from the Google Translate API for an indeterminate amount of time (up to 24 hours?)
    - You may want to scrape your library in batches, or set `translate-description=False` to avoid this altogether
- If you want to update/refresh your existing metadata scraped from Javinizer, you can run a `Javinizer -Path <Path> -Recurse -MoveToFolder:$false -RenameFile:$false -Multi`
    - By default, only nfo metadata will be overwritten when running Javinizer on already sorted directories
        - If you use the `-Force` parameter, Javinizer will also overwrite your image/trailer/etc files
- Actress metadata scraped from JAVLibrary will match actresses with their thumbnails from your `r18-thumbs.csv` file
- Actress metadata scraped from JAVLibrary will replace the JAVLibrary names with their R18 names if added to the Alias column in your `r18-thumbs.csv` file
- If you want to primarily have R18/Dmm metadata, you can set `normalize-genres=True` to have the JAVLibrary genre names converted to their R18 counterparts to have a cleaner/consistent library
    - If you want to primarily use JAVLibrary metadata, set `normalize-genres=False`

## Troubleshooting

| Issue | Resolution |
| --- | --- |
| Unicode error when trying to translate plot description  | Try setting in Windows 10: `Region Settings` -> `Beta: Use Unicode UTF-8 for worldwide language support`. |
| Descriptions still in Japanese even with `translate-description=True` | You may have been IP banned from the Google Translate API for scraping too much in a short amount of time. Wait a few hours and try again.
| `crop.py` error when sorting multi-part videos using `-Multi` parameter | Ignore this error as it should not effect the end-result. |
| Unable to sort videos with letters following the numeric ID (e.g. LE-01D, IBW-500z) | Sort using direct URLs with the `-Url` parameter, or rename the file to exactly how the ID appears on R18/JAVLibrary, and use the `-Strict` parameter (e.g. `Javinizer -Path . -Strict`) when calling Javinizer. This may cause the filename to be appended with `-pt#` depending on which letter is used, but you can also set the setting `rename-file=False` or just rename it manually after.  |


## Todo
- [x] Trailer scraping - [0.1.2]
- [x] Multi-part video directory sort support - [0.1.2]
- [x] Parallel/Threaded sort processing - [0.1.7]
- [x] Allow switching firstname/lastname order - [0.1.7]
- [x] Add R18 actress thumburl scraping for non-r18 actress data source scrapes - [1.0.0]
- [x] Normalize genre names between JAVLibrary and R18 - [1.0.0]
- [x] Add functionality to POST Emby/Jellyfin actress images from `r18-thumbs.csv` - [1.1.0]
- [x] Add additional language support [1.3.0]
