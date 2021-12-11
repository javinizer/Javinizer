# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.5.10]

### Fixed

- Fixed JAVLibrary actress name order (english/romaji) for movies with only one actress (#321)
- Fixed JAVBus actress thumbnail URL for actresses missing the baseURL (#316)

## [2.5.9]

### Fixed

- Fixed R18/DMM URL scraper due to changed R18 search HTML

## [2.5.8]

### Added

- Setting `sort.movesubtitles` to automatically detect and move subtitle files (#197)
  - This feature assumes that the root movie path is in its own contained folder with the subtitle files. Sorting files while using a flat directory structure will most likely not work as intended
  - Detects .ass, .ssa, .srt, .smi, .vtt
- DeepL translator support (Thanks @toastyice #302)
  - The setting `sort.metadata.nfo.translate.deeplapikey` requires a [DeepL developer API key](https://www.deepl.com/pro-api?cta=header-pro/) which allows 500,000 characters a month for free

### Fixed

- Suppress `SYSLIB0014` error when importing custom webscraper class (Thanks @Andor233)
- The GUI code editor now properly displays the correct custom location paths when clicking the `Edit` button (#301)

## [2.5.7]

### Added

- Setting `sort.metadata.nfo.addaliases` to add all actress aliases alongside the original name as separate actresses in the nfo (#290) (#291)

### Changed

- Improved filematcher (#289)
  - contentId matching is now improved
  - file names starting with `.*\.org@` are now matched properly (e.g. bbs2048.org@MOVIE-123.mp4)

### Fixed

- Fixed fields on `dmmja` scraper (#293) (#294)

## [2.5.6]

### Added

- Timeout configuration for trailer/screenshot download requests (in ms) (#286)
- CLI docker images (tag: `jvlflame/javinizer:latest-cli)

### Fixed

- Series metadata for r18 now properly uncensored
- Actresses with invalid thumburl no longer automatically added to r18 thumb csv (after r18 html changes)

## [2.5.5]

### Fixed

- Actresses now properly set on R18Zh scraper
- Screenshot URLs on R18/R18Zh scraper properly set if missing highest quality images

## [2.5.4]

### Fixed

- R18 scraper following movie page update (#282)

## [2.5.3]

### Fixed

- JAVLibrary cloudflare session now properly added to requests when running Javinizer without `-Path` (e.g. using location.input)
- Suppress errors related to regex partnumber match when no partnumber is present

## [2.5.2]

### Added

- Add setting to toggle the addition of generic actress role of `<role>Actress</role>` (#273)
  - `sort.metadata.nfo.addgenericrole`

### Fixed

- 3 -> 0 retries on webrequest to check for javlibrary cloudflare blocking to speed up initialization
- Fixed json conversion loop which was breaking multiple javinizer GUI components
- Regex multi-part matcher for movies that don't match standard DVD ID format should now match properly
- Duplicate actresses without Japanese name should now be ignored from actress autoadd to thumb csv (again)

## [2.5.1]

### Added

- Add functionality to rename folders in-place without moving files (#268)
  - To use: set `"sort.renamefolderinplace": true` and `"sort.movetofolder": false`
  - This will only work properly if there is a unique movie per directory, otherwise race conditions between conflicting movies will cause errors. I recommend testing this in a controlled environment before "production" use

### Changed

- JAVLibrary cookies changed following Cloudflare update
  - Added
    - `javlibrary.cookie.cf_chl_2`
    - `javlibrary.cookie.cf_chl_prog`
  - Changed
    - `javlibrary.cookie.cfclearance` => `javlibrary.cookie.cf_clearance`
  - Removed
    - `javlibrary.cookie.cfduid`

### Fixed

- Javbus actress thumburls returning a relative url instead of the full url
- Downloading images from alternate sources should now work properly (bug introduced from added proxy settings)
- Duplicate actresses without Japanese name should now be ignored from actress autoadd to thumb csv

## [2.5.0]

### Added

- Tokyohot scraper (#253)
- Add settings to use proxy for web requests
  - `proxy.enabled`
  - `proxy.host`
  - `proxy.username`
  - `proxy.password`
- <\thumb> tag added to nfo for the coverurl field (#267)
- `-Clean` parameter to clean JAV filenames without sorting
  - e.g. `Javinizer -Path C:\Javinizer\Unsorted -Clean -Verbose`

### Changed

- File matcher
  - Files beginning with `hhd800.com@` are now cleaned properly
  - Properly match multipart format with `.part, .pt, .cd`
  - Multipart format now works with letters up to Y (From A-D => to A-Y) to better work with JAV VR

### Fixed

- Javbus coverUrl scraper returning a relative path instead of the full path
- Single-word actresses from javlibrary being set as @Unknown in dynamic folder structures
- Automatically retry all requests on failure (up to 3 times) to attempt to resolve failed javlibrary requests

## [2.4.11]

### Changed

- Mgstage data scraper now includes trailer scraping (#262)
- Dmm url scraper now falls back to dmm search if the movie is missing on r18

## [2.4.10]

### Fixed

- Fixed error output caused by missing R18 (Zh) pages used by R18 actress scraper
- Fixed tags not being replaced properly by the tagcsv

## [2.4.9]

### Fixed

- Fixed setting `sort.metadata.nfo.preferactressalias` on JAVLibrary titles with only single actress (#219)

## [2.4.8]

### Added

- Added `EnglishAlias` and `JapaneseAlias` properties to JAVLibrary scraper output
- Setting `sort.metadata.nfo.preferactressalias` added to replace the default actress with the oldest alias in the aggregated metadata (#219)
  - This can be used to "normalize" your actresses if you use JAVLibrary as your primary actress metadata

### Fixed

- Various fixes to regex matcher which were altering results
- Mgstage scraper fixed for site HTML changes
- Tag/Genres no longer being automatically replaced on a null replacement value

## [2.4.7]

### Fixed

- Using `<TITLE>` at the end of a directory format string no longer errors when creating metadata files (#245)
- JavBus genre metadata scraper updated for site changes

## [2.4.6]

### Changed

- GUI: `-StartGUI` now checks for and applies updates to the GUI dashboard script before starting

### Fixed

- GUI: Running sort on an individual file on the filebrowser now properly displays metadata after scraping
- GUI: Committing sort on an individual file now prpoerly clears the sort screen
- GUI: `-InstallGUI` now properly applies file permissions to install directory for non-english locale systems (#244)

## [2.4.5]

### Changed

- Screenshot filename index padding is now configurable via setting `"sort.format.screenshotimg.padding": 1`

### Fixed

- GUI: Fixed issue where checkbox for sort.metadata.nfo.translate.keeporiginaldescription would always be checked if sort.metadata.nfo.translate was true

## [2.4.4]

### Added

- Added \<FILENAME> as a format string which converts to the movie's basename

### Changed

- Downloaded screenshot names now have a 2 digit padding for the incremented number
- `-UpdateModule` now copies tags, genre, history csv files to new module folder instead of doing a comparative replacement

### Fixed

- Fixed issue where sort would fail when downloading movie screenshots
- Fixed issue where filematcher would erroneously detect 5 digit movies with a single trailing '0' as a contentId during multipart matching (e.g. DMM-070807_1) (#227)
- Fixed issue where Jav321 scraper was failing due to invalid -AllResults parameter
- Fixed issue where error was being thrown when trying to translate from english => english
- Fixed issue where error was being thrown when movie was not matched

## [2.4.3]

### Fixed

- Fixed issue where genres were not being replaced from the genre csv (#235)
- Fixed issue where `-Update` was not being applied properly

## [2.4.2]

### Fixed

- GUI: Fixed custom appbar not being displayed

## [2.4.0]

### Added

- Added `-OpenModule` parameter to open the Javinizer module directory
- Added setting `scraper.option.addmaleactors` to scrape avdanyuwiki.com for male actors (#147)
  - Updated English names in the thumb csv will be added in a later release
- Sorting files via the CLI now populates the history csv file (-OpenHistory)
- GUI: Added ouput and filematcher preview
- GUI: Added recurse depth selection on sort card
- GUI: Added genre/tag editor popups
- GUI: Added stats page that corresponds with the history csv
- GUI: Added an advanced manual search workflow
- GUI: Added tooltip descriptions for most GUI actions and settings options
- GUI: Added better dark/light theme management, refreshed appbar
- GUI: Added 'not matched' count to sort progress popup

### Changed

- **Updated settings metadata priority defaults to favor javlibrary over r18**
- mgstageja scraper no longer includes actress aliases in the JapaneseName
- jav321 scrapers no longer include actress aliases in the JapaneseName
- History csv now includes all metadata fields
- GUI: Installing the GUI no longer requires first-run setup via `-OpenGUI` and Docker
- GUI: PowerShell Universal version upgraded from 1.4.7 => 1.5.13
- GUI: Default port changed from 5000 => 8600
- GUI: GUI now runs in a non-admin scope to allow easier access to network drives

### Fixed

- Fixed issue where actress images would fail to download if they contained special characters on mgstage (#223)
- Fixed issue causing update check to never run
- Fixed issue with javlibraryja and javlibraryzh scrapers not accepting manual cloudflare cookies
- Fixed issue where R18 series metadata included a blank 'tab' character

## [2.3.3]

### Changed

- `admin.updates.check` now checks on a 24 hour interval instead of on every run
- Removed local dependencies on `-UpdateModule` - now runs properly

### Fixed

- Fixed JAVLibrary scraper not returning cover urls for certain movies
- Fixed file matcher cleaning regex ".HD" => "\.HD"

## [2.3.2]

### Changed

- Javdb scraper now accepts relative ID match rather than exact ID match to support matching mgstage titles
  - mgstage `406FSDSS-169` <-> `FSDSS-169` javdb

### Fixed

- Additional fixes for -UpdateModule
- Filematcher now properly cleans ContentId (ID00123) to Id (ID-123) value
- `-Strict` now properly works on updated Dmm url scraper
- Added better debugging error when filematcher breaks on invalid multi-part format (#215)
- Javlibrary ratings now properly return null when there is no rating value

## [2.3.1]

### Fixed

- Fixed R18 url scraper failing to find movies that are listed on sale
- Fixed Dmm scraper warning output not displaying movie Id

## [2.3.0]

### Added

- Added javdb.com scraper (#184)
  - Settings:
    - `scraper.movie.javdb` - Enable English javdb scraper
    - `scraper.movie.javdbzh` - Enable Chinese javdb scraper
    - `javdb.cookie.session` - Allows you to specify `_jdb_session` login session cookie to scrape fc2 titles
- Added tag csv settings file (#193)
  - Settings:
    - `location.tagcsv` - Defines external tagcsv location
    - `sort.metadata.tagcsv` - Enables tag csv to replace tag values
    - `sort.metadata.tagcsv.autoadd` - Adds new tags to tag csv automatically on scrape
- Added feature to add actress as tags (#194)
  - Settings:
    - `sort.metadata.nfo.actressastag` - Adds each actress as an individual `<tag>` in the nfo

### Changed

- The JAVLibrary url scraper now prefers the non-bluray release if an alternative is available
- The default Javinizer file matcher now falls back to `-Strict` matchmaking automatically if the movie file is not detected as a standard DVD ID (#196)
- `-SetEmbyThumbs` now checks both Actress naming orders instead of only the selected one (#192)
- All url scrapers rewritten and optimized
  - DMM url scraper now defaults to using the R18 url scraper to match the `contentId` value
- `.*mosaic.*` added as a default ignored genre in the settings file
- Dmm/Mgstage rating metadata changed to round to 2 decimal points

### Fixed

- Fixed some series metadata value on R18 being displayed as an invalid html value (#202)
- Fixed AVEntertainments failing to retrieve runtime metadata for some movies
- `-UpdateModule` should now function properly

## [2.2.11]

### Changed

- `<releasedate>` changed to `<premiered>` to match updated Kodi NFO standard

### Fixed

- Fixed typo causing genre csv to not function correctly
- Fixed a bug in the filematcher where invalid part numbers were detected causing the script the fail
- Added a character replacement to mgstage metadata causing actress image downloads to fail

## [2.2.10]

### Added

- Added `-Preview` parameter to display file matcher details
- Added `-OutSettings` parameter to passthru Javinizer settings object to shell
- Added `admin.updates.check` setting to check for module updates on first run
- **Experimental** Added `-UpdateModule` parameter to perform Javinizer module update with settings persistence

### Fixed

- `sort.metadata.nfo.translate.keeporiginaldescription` no longer fails to check true/false value
- Using `-Update` will no longer recreate the nfo file with a filename title
- Directories with a file extension appended to the path name will no longer be detected as a movie

## [2.2.9]

### Added

- Added setting `sort.metadata.genrecsv.autoadd` to automatically add unknown genres to the genre csv file (#181)
  - `sort.metadata.genrecsv` functionality has been updated to ignore genres with a null `Replacement` value
- Added setting `sort.metadata.nfo.translate.keeporiginaldescription` to append the original description to the translated one (#182)

### Changed

- Changed default Javinizer GUI (PowerShell Universal) web port to 8600 to alleviate conflicts with Synology NAS ports
- `-OpenGUI` now checks for a valid Javinizer dashboard and self-fixes if missing

### Fixed

- Fixed the `-Url` parameter defaulting to JavLibrary detection when sorting manually with urls
- Fixed JavLibrary actress scraper not capturing Japanese names when using a mirror site

### Added

- Added GUI functions for easier Windows GUI setup
  - `Javinizer -InstallGUI`
  - `Javinizer -OpenGUI`

## [2.2.8]

### Fixed

- Fix breaking error causing sort to fail when trimming trailing periods on folder paths

## [2.2.4]

### Fixed

- JAVLibrary scraper now works correctly with b49t.com mirror
- Get-CfSession function now successfully accepts the \_\_cfduid, cf_clearance, and browser useragent when scraping from cloudflare protected JAVLibrary site
- Dynamic directory names with trailing periods are now trimmed to resolve terminating error during sort (Thanks @amdishigh)
- Japanese actress names are now correctly added to the format string when `sort.metadata.nfo.actresslanguageja` is true (Thanks @amdishigh)

## [2.2.3]

### Fixed

- Additional fixes to Dmm ID matcher

## [2.2.2]

### Fixed

- Resolved DMM ID match error
- Path and Destination path now resolve correctly for standard console paths when null or using "."
- Javinizer no longer throws an error when `sort.format.screenshotfolder` or `sort.format.actressimgfolder` are blank

## [2.2.1]

### Fixed

- Actress thumburl for movies with a single actress are now scraped correctly following scraper optimizations
- Setting `"sort.metadata.nfo.translate.module": "google_trans_new"` now correctly uses the google_trans_new module

## [2.2.0]

### Added

- MGStage scraper
- AVEntertainment scraper
- Enhanced metadata translation functionality
  - Multiple fields can now be translated instead of only description
  - Support multiple Python translation modules (googletrans, google_trans_new)
- `<DIRECTOR>` is now a supported tag in metadata format strings
- Added a setting to allow for creation of `<credits>` in nfo metadata

### Changed

- Metadata format strings will now be output as "Unknown" for null fields

### Fixed

- MacOS now correctly falls back to `Move-Item` if `mv` command fails
- DmmJa scraper now returns the correct actresses if an English actress name is present
- Javbus scrapers now correctly account for actress first/last name on inconsistent actress pages
- Javlibrary and R18 scrapers now run 40% faster with reduced requests for actress names

## [2.1.6]

### Changed

- Throttlelimit increased from 5 -> 10

### Fixed

- MediaInfo now functions correctly on linux

## [2.1.5]

### Changed

- Parameter `-SetOwned` now uses default path from settings

### Fixed

- Multiple tags are now created properly from setting `sort.metadata.nfo.format.tag`
- Aggregated data object actress is now always created as an array

## [2.1.4]

### Changed

- Url scraper now run within threads to increase sort speed
- Setting `sort.format.outputfolder` changed to array to allow nested output folders (#136)
- Parameter `-SetOwned` now uses the `javlibrary.baseurl` setting when setting owned movies
- Javlibrary re-added in settings as a default scraper, Javbus removed

### Fixed

- R18 Url scraper now correctly finds movies that match ID value XXX-00X (#138)
- Jav321Ja now correctly retrieves all genres when scraping (#135)
- Cookies are now prompted for when cloudflare IUAM is detected and a javlibrary url is specified when using -Find

## [2.1.3]

### Added

- Function `Get-CfSession` to create a websession object to access the Javlibrary scraper
- Settings `javlibrary.browser.useragent`, `javlibrary.cookie.cfduid`, and `javlibrary.cookie.cfclearance` to persist Javlibrary websession

### Changed

- Javinizer out-of-box-experience (OOBE) updated to remove Javlibrary as a default scraper due to Cloudflare IAUM protection
  - Javbus is now enabled as a default scraper

### Fixed

- Sort now properly fails when there are missing required metadata fields when using `-Url`
- Javbus scraper now properly finds uncensored videos when similar search results are found in the censored section
- Maxtitlelength behavior for Japanese titles now do not cut off at the last whitespace character

## [2.1.2]

### Added

- Setting `sort.format.groupactress` to convert the `<ACTORS>` format string. If enabled:
  - Multiple actresses => `@Group`
  - Unknown actress => `@Unknown`
- `-Strict` parameter is now available during `-Find` usage for R18 scraper only (#125)
  - R18 scraper does automatic conversion from ContentID => Id which failed for certain movie IDs ( MBR-AA063)

### Fixed

- Aliases for actresses with a single-word name are now properly replaced by the thumb csv
- Tags and tagline fields in the nfo now correctly replace invalid xml characters (#124)
  - Sort no longer fails when trying to download actress images
- Downloading actress images no longer fails when
- R18 title metadata is now properly uncensored

## [2.1.1]

### Added

- Setting `sort.format.outputfolder` to create a static or dynamic output folder for sorted movies in the destination path (#115)
  - This setting accepts a format string (i.e. `"sort.format.outputfolder": "<STUDIO>"` will sort movies into a folder of their studio name in the destination path)
- Setting `sort.metadata.nfo.altnamerole` to add the actress `<altname>` as the actress role (#110)
- Setting `javlibrary.cookie.session` and `javlibrary.cookie.userid` to set a path of movies as 'Owned' on JavLibrary. This runs on a single thread and is not affected by throttlelimit (#119)
  - Log into JavLibrary and view browser cookies [www.javlibrary.com / Cookies / session] and [www.javlibrary.com / Cookies / userid] and define them in your settings
  - Usage: `Javinizer -Path 'C:\JAV\Sorted' -Recurse -SetOwned`
- Setting `sort.metadata.nfo.originalpath` to add the path the movie was last sorted from to the nfo file under field `<originalpath>` (#116)

### Changed

- `<altname>` in the actress metadata in the nfo is now dynamic based on the selected actress name language (#110)

### Fixed

- Sort no longer fails when newlines are present in R18 maker and label metadata output (#121)

## [2.1.0]

### Added

- **EXPERIMENTAL** Dl.getchu scraper (#51)
  - This is scraper is only available via the `-Url` parameter when sorting a single file or using `-Find` to search the Url
- Setting `sort.metadata.nfo.mediainfo` added to allow user to add video/audio metadata to nfo (#94)
  - [MediaInfo](https://mediaarea.net/en/MediaInfo) required for use. MediaInfo will need to be added to your system PATH
  - `<RESOLUTION>` added to file formats
- Setting `sort.metadata.nfo.unknownactress` to allow `Unknown` actress to be written to nfo file when no actresses are scraped (#105)
- Setting `sort.metadata.nfo.format.tagline` to allow user to set a tagline which accepts file format strings (#106)
- Setting `sort.metadata.priority.contentid` to set the priority of the ContentId displayed by aggregated data object
  - `<CONTENTID>` added to file formats

### Changed

- Default file matcher updated to better match multipart videos and support DMM ContentId (#111)
- Setting `sort.metadata.nfo.seriesastag` is now `sort.metadata.nfo.format.tag`
  - This setting is now an array, which allows multiple file format strings to be created as separate tags (#106)
- Javinizer now performs a retry on the Javlibrary URL scraper and continues to run despite webrequest errors (#109)
- AggregatedData object now contains `ContentId`

### Fixed

- Get-DmmUrl now correctly assigns the URLs when searching for a movie with ID with a letter suffix (#107)
- Manually sorting with a DmmJa URL now functions properly (#111)
- Nfo file now correctly renames to the movie name when `sort.renamefile` is set to false, and `sort.create.nfoperfile` is true (#102)
- `<ACTORS>` file rename format now properly falls back to the alternate language when the primary is missing (#103)
- R18 scraper now properly assigns the genre and label fields for Amateur videos (#108)
- Extra html on the Description field for the DMM scraper is now removed

## [2.0.2]

### Fixed

- Dmm/DmmJa scraper
  - Aliases are now removed from the Japanese actress name
  - TrailerUrl no longer contains an invalid url with duplicate "https"
  - Actresses are now fully scraped if there are 10+ actresses in a movie
  - Maker, Series, and Label no longer pulls inaccurate data
- Javbus scraper
  - Search no longer fails when title html spans multiple lines
  - Both Japanese and English actress names are now pulled when scraping an uncensored movie
- Javinizer no longers fails to scrape when running in PowerShell 6

## [2.0.1]

### Added

- Setting `location.uncensorcsv` to allow user-defined uncensor csv path

### Changed

- Dmm scraper now includes TrailerUrl
- `-Update` parameter now downloads metadata items in addition to updating the nfo file
- Actress matcher logic updated for more accurate results
- Default file matcher logic updated to better clean filenames downloaded from torrent sites

### Fixed

- Javlibrary ratings are now properly assigned to the nfo
- Dmm scraper now correctly gets actresses
- Regex file match no longer incorrectly changes the movie ID during sort
- `sort.metadata.nfo.firstnameorder` now correctly applies to `<ACTORS>` in sort formats

## [2.0.0]

### Added

- Added `-Update` parameter to only update nfo when sorting a directory
  - This can replace v1.x.x functionality of using `-MoveToFolder:$false -RenameFile:$false`
- English 'dmm' scraper added
  - Somewhat unreliable as not all videos on the DMM Japanese site are available on the English site
  - Original 'dmm' scraper renamed to 'dmmja'
- Setting `scraper.option.dmm.scrapeactress` added to turn on/off both English/Japanese actress name scraping for dmm scrapers
  - Only enable this if you want to use Dmm as a primary scraper for your actress metadata as it greatly increases time taken to sort
- Parameter `-EmbyUrl` and `-EmbyApiKey` added to assign values in the commandline
- Parameter `-OpenUncensor` to open the R18 uncensored word replacement csv

### Changed

- JapaneseName added to nfo file as altname
- Setting `throttlelimit` limited to 5
- R18 uncensored words and replacements are now moved to a file at module root `jvUncensor.csv`
- Path will default to your current commandline location if `-Path` is not specified and setting `location.input` is blank
- DestinationPath will default to the sorted file's current directory if `-DestinationPath` is not specified and setting `location.output` is blank
- Setting `sort.metadata.thumbcsv.autoadd` no longer adds actresses with a missing thumburl
- Add warning if custom thumb or genre csv is not found at specified path

### Fixed

- Fixed scraped R18 actress names containing aliases in parentheses
- Writing thumbs to Emby/Jellyfin is now functional again with `-SetEmbyThumbs` following R18 resource restrictions
- Fixed failing screenshot download requests from R18 resources
- Parameter `-Find` with Javlibrary when using a custom javlibrary baseurl in your settings

## [2.0.0-alpha9]

### Fixed

- Fixed failing download requests from R18 resources

## [2.0.0-alpha8]

### Changed

- Default matcher now supports IDs ending with a letter (IBW-###z, KTRA-###e)
- Logging messages updated to be more consistent

### Fixed

- Jav321 scraper not running properly
- Javinizer now properly uses the thumb csv when a custom path is set in `location.thumbcsv`
- Error thrown when scraped genres are null and ignored genres are present

## [2.0.0-alpha7]

### Added

- Setting `sort.metadata.thumbcsv.autoadd` added
  - If enabled, actresses scraped from R18 and R18Zh scrapers are automatically added to the thumb csv if missing

### Changed

- Setting `sort.metadata.genre.ignore` changed to regex match
- Actresses are now only matched using JapaneseName while sorting
- Additional words added to r18 uncensor list

### Fixed

- Actresses being matched incorrectly due to false positives with FirstName/LastName matching
- Dmm match when searching for IDs ending with a letter (IBW-###z, KTRA-###e)
- Error being thrown when trying to trim a null translated description
- Actress names containing backslash `\` in R18 fixed

### Removed

- Parameter `-UpdateNfo` removed pending further testing/development

## [2.0.0-alpha6]

### Added

- `<YEAR>` re-added as a nfo field
- `<RATING>` re-added as nfo field

### Changed

- Javbus scraper now updated to 2.0.0 standards
- Jav321 scraper now updated to 2.0.0 standards
- `jav321` scraper setting now named `jav321ja`
- All javlibrary urls converted from http to https
- Allow `-SettingsPath` on `-Find` parameter set

### Fixed

- Javinizer erroring when using `-Url` due to logic errors
- JavbusJa and JavbusZh scrapers not running unless Javbus en scraper activated
- Javbus scraper erroneously being matched as JavbusZh
- Jav321 scraper failing due to incorrect variable call
- Jav321 actress output to match the rest of the scrapers
- Dmm not matching videos where content ID starts with string like `d_123`
- Nfo failing to create if translated description output a newline character

## [2.0.0-alpha5]

### Added

- Function to update existing nfo files using thumb and genre csv (actress name, actress thumburl, actress alias, genre replacements, genre ignores)
- R18 scraper now scrapes both English and Japanese actress names
- Javlibrary scraper now scrapes both English and Japanese actress names
- Thumb csv aliases now supports Japanese names
- `<ACTORS>` re-added as available rename fileformat, setting `sort.format.delimiter = ', '`

### Changed

- Setting `sort.format.posterimg` changed to array to allow creation of multiple poster images per video (e.g. poster.jpg, folder.jpg)
- Setting `sort.metadata.nfo.translate` changed to `sort.metadata.nfo.translatedescription`
- Setting `sort.metadata.nfo.translate.language` changed to `sort.metadata.nfo.translatedescription.language`
- `-Language` parameter removed from all url scraper functions, instead returns all available language urls by default
- Url scraper is now only run once when scraping multiple languages of the same site

### Fixed

- `<ACTORS>` now works as a set fileformat
- Resolved DMM scraper incorrectly matching IDs with similar name (e.g hrv00030 would match chrv00030)
- Resolved translated description not setting properly
- Some issues where aliases were not matching properly when scraping using thumb csv

## [2.0.0-alpha4]

### Changed

- Greatly improved performance when performing the Javinizer directory search
- Output missing required fields when sort fails

### Fixed

- Series not being set properly in R18 scraper
- Error output during sort caused by invalid path validation during file move
- Resolved errors when downloading metadata files for multi-part videos concurrently
- Properly set the description even if the translation fails when `sort.metadata.nfo.translate: 1`
- Javlibrary scraper now properly sets coverurl to null if the image is invalid
- Setting `regex.match` now applies properly
- Setting `match.minimumfilesize` now applies properly
- `-RenameFile` now applies to `sort.renamefile` properly
- `-MoveToFolder` now applies to `sort.movetofolder` properly
- `-Force` fixed to correctly replace metadata files

## [2.0.0-alpha3]

### Added

- Javinizer now runs multi-threaded by default by use of Invoke-Parallel (Allowed up to 10 threads)
- `-Depth` parameter to specify `-Recurse` depth
- `-Set` parameter to update any setting from the commandline via a hashtable
- `-SettingsPath` parameter to specify an external settings file
- `-HideProgress` parameter to hide the progress bar when sorting
- PSEdition Core requirement added to all public functions
- Settings validation function
- Re-added `-MoveToFolder` and `-RenameFile` parameters
- Re-added `-Strict` parameter

### Changed

- `FullName` column added to thumbnail csv - Not required if adding actress manually
- Changed function name `Update-JVThumbs` -> `Update-JVThumbCsv`
- Setting name `sort.metadata.thumbcsv.path` -> `location.thumbcsv`
- Setting name `sort.metadata.genrecsv.path` -> `location.genrecsv`
- Setting name `admin.log.path` -> `location.log`
- `-Version` parameter output
- Url matches using `-Find` are more intuitive

### Fixed

- Missing setting `scraper.movie.javbuzh` added to jvSettings.json file
- Encoding errors where `sort.metadata.nfo.translate` is enabled
- Error when running `-Find` without any scrapers enabled

### Removed

- `Logging` module dependency

## [2.0.0-alpha1]

### Added

- Site scrapers now run in asynchronous threads
- Scraping a single movie with -Url now works more intuitively
- Thumbnail csv is improved with both English/Japanese names
- Thumbnail csv now supports multiple actress aliases with '|' delimiter in the Alias column
- Thumbnail csv now better matches actresses
- Allow to prefer English or Japanese actress names in metadata
  - If a Japanese name is found from site metadata, thumbnail csv will automatically be used to try to match it to its English name and vice-versa
- User definable genre csv path
- User definable thumbnail csv path
- User definable javlibrary baseUrl - some reports of cloudflare issues
- Improved logging
- Functions now public for power users

### Changed:

- Settings file changed from .ini to .json format
- Path/DestinationPath now work a bit differently.
  - Running Javinizer -Path $Path used to automatically set the DestinationPath as $Path. Now it is either required to be set in the command line or it will default to the path in the settings file

### Removed

- \<year> data in nfo
- \<rating> data in nfo

## [1.7.3]

### Changed

- Restored some scraper settings defaults
  - .wmv to file extension default
  - scrape-r18/dmm to true

### Fixed

- Added `-Strict` functionality to `-SetJavlibraryOwned`
- Error when running with `-Multi` due to dev code

## [1.7.2]

### Added

- Settings file validation for:
  - True/False values
  - Integer values
  - Multi-sort throttle value

### Changed

- `-SetJavlibraryOwned` now accepts a Path as well as a text list of movie IDs
  - If a path is detected, it will use Javinizer's default movie matching scheme to match IDs (regex-match supported as well)
    - e.g. `Javinizer -SetJavlibraryOwned "C:\JAV\Sorted" -Recurse`
  - If a file is detected, it will use the text list of movie IDs
    - e.g. `Javinizer -SetJavlibraryOwned "C:\JAV\movies.txt"`
- Timeout for setting owned movies on JAVLibrary is now user-defined (in seconds)
  - Setting `request-timeout-sec`
- Regex match sorting now allows user-defined match values (use `$DebugPreference = 'Continue'` if troubleshooting your matches)
  - Setting `regex-id-match` and `regex-pt-match`
- `-Multi` sort now uses PowerShell native `Start-ThreadJob` cmdlet as opposed to PoshRSJob
- Progress bar when using parameter `-Multi` now includes current in-progress threads

### Fixed

- Movies failing to be sorted into separate folders when using `-Multi` with default settings
- Javinizer failing when regex match fails on an item and returns a null value
- Javinizer not ignoring movies that don't match the regex string when `regex-match=True`

### Removed

- PoshRSJob dependency removed

## [1.7.1]

### Added

- Parameter `-SetJavlibraryOwned` to add a list of movies as owned on JAVLibrary
  - Requires a flat text file of movie IDs
  - e.g. `Javinizer -SetJavlibraryOwned 'C:\Downloads\javlist.txt'

### Changed

- 60s timeout when attempting to set owned status on JAVLibrary
- Error check to test successful authentication to JAVLibrary before running sort

### Fixed

- Fixed movie count being doubled on sort
- Fixed movie mismatch when `regex-match=True`
- Fixed running Javinizer `-Multi` sort when `set-owned=True`

### Removed

- Removed verbose messages on GET/POST requests to JAVLibrary when setting owned status

## [1.7.0]

### Added

- Added setting to match JAV files using regular expressions
  - Regex match will not perform any string transformations, so the movie ID in your filename will need to match the website metadata exactly
  - This is intended for users who have previously sorted files using a unique template and are unable to match using Javinizer's default matcher
  ```
  # Default values
  [General]
  regex-match=false
  regex=([a-zA-Z|tT28]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})(?:-pt){0,1}(\d{1,2})?
  ```
- **Experimental** Added JAVLibrary integration with setting movies as "Owned" when sorting with Javinizer
  ```
  # Default values
  [JAVLibrary]
  set-owned=True
  username=
  session-cookie=
  ```

### Fixed

- Fixed `-GetThumbs` and `-UpdateThumbs` functionality
  - Removed PoshRSJob dependency, instead using PowerShell Core native `ForEach-Object -Parallel` for multi-threaded webpage scraping
    - There will no longer be a progress bar displayed
- Fixed error output due to missing native dependencies when checking for Javinizer module updates

## [1.6.0]

### Added

- Initial Jav321 scraper functionality
  - Setting scrape-jav321
- Actress thumb url scraping for JavBus scraper

## [1.5.0]

### Added

- Initial JavBus scraper functionality
  - Setting scrape-javbus, scrape-javbusja
- Setting toggle for r18.com actress name language scraping to csv when using -GetThumbs or -UpdateThumbs
  - scrape-actress-en
  - scrape-actress-ja
- Setting `max-path-length` to allow user to define maximum path length of sorted files
- Enhanced `-ViewLog` functionality and parameters
  - Colored output for ERROR and WARN log messages
  - -ViewLog <String> (List, Object, Table, Grid)
  - -Entries <Int>
  - -Order <String> (Asc, Desc) Default: Desc
  - -LogLevel <String> (Info, Error, Warn, Debug)
  - Examples:
    - `Javinizer -ViewLog List`
    - `Javinizer -ViewLog Table -LogLevel Error -Entries 10`
    - `Javinizer -ViewLog Object | Where-Object {$_.message -like 'Skipped*'}`

### Removed

- Host output when Javinizer function is started/stopped

## [1.4.2]

### Fixed

- `-MoveToFolder` and `-RenameFile` being incorrectly applied when `-Multi` is applied
- Files being moved/named incorrectly when `rename-file=False`
- nfo files being named incorrectly when `rename-file=False` and `create-nfo-per-file=True`

## [1.4.1]

### Fixed

- Fixed Javinizer update check

## [1.4.0]

### Added

- Ability to select which file extensions to use with Javinizer with setting `included-file-extensions`
- Ability to exclude files that match a string/wildcard value with setting `excluded-file-strings`
  - This uses the `-Exclude` parameter on cmdlet `Get-ChildItem` which supports string paths/strings with wildcard (\*) Regex is NOT supported
- Ability to omit the creation of a nfo file for a movie with setting `create-nfo`
- Ability to create a nfo file per movie file sorted (for multi-part videos) with setting `create-nfo-per-file`
  - This is now set as default, as this is a requirement for metadata to be loaded with movies into Emby/Jellyfin
- Better logging functionality and setting of a static log path with setting `log-path`
  - View logs from console with `Javinizer -ViewLog`
  - Output as a PowerShell object, so you can specify pipeline elements (e.g `Javinizer -ViewLog | Select-Object -First 10 | Sort-Object timestamp -Descending | Format-Table -Wrap`)

### Changed

- Removed r18 from default description
- Logging to JSON formatted

### Fixed

- `-MoveToFolder`, `-RenameFile`, `-Force` parameters when using `-Multi` sort not being passed through
- Duplicates being added to r18-thumbs.csv
- Poster images failing to be cropped from Python when using Windows UNC paths (e.g \\server\jav\unsorted\)

## [1.3.0]

### Added

- Additional language support for existing scraper sources
  - JavLibrary ZH (CN) `scrape-javlibraryzh=True`
  - JavLibrary JA `scrape-javlibraryja=True`
  - R18 ZH `scrape-r18zh=True`
- Original Japanese actress entries to r18-thumbs.csv
- Alternate language selection for description translation `translate-description-language=en`
- Parameter `-ImportSettings` to specify an external settings file
  - Example: `Javinizer -Path C:\Downloads\JAV-Unsorted -ImportSettings C:\settings-template1.ini -Multi`
  - This is for those of you running Javinizer in automation or want to just specify different presets when sorting
- Parameter `-MoveToFolder` and `-RenameFile` to set true/false value for `move-to-folder` and `rename-file` in the commandline
  - Example: `Javinizer -Path C:\Downloads\JAV-Sorted -Recurse -MoveToFolder:$false -RenameFile:$false`
  - This is for when you want to refresh metadata for already sorted videos but don't want to manually adjust your settings file

### Changed

- Default naming of `poster.jpg` -> `folder.jpg`
  - This allows the poster image to show up as the default folder thumbnail in Windows File explorer
  - I have not noticed any issues with Plex/Emby/Jellyfin for this naming convention but let me know if there is a conflict
- Default throttling of thumbnail updates to 5
  - Requests have been erroring out due to the speed of the requests and Cloudflare throttling
- Update check will only occur once per session by checking global variable

### Fixed

- Actresses from DMM not being properly added to nfo when `first-last-name-order=false`
- R18 thumbnail csv adding duplicate entries with reversed order when `first-last-name-order=false`

## [1.2.0]

### Added

- Functionality to download actress images that are pulled from r18-thumbs.csv
- Functionality to check for Javinizer module updates on startup
  - Setting `check-updates=<True/False>`

### Fixed

- Issue where actresses scraped from JAVLibrary found in the r18-thumbs.csv file but not matching the correct casing (upper/lowercase) would erroneously be replaced with the last entry in r18-thumbs.csv

## [1.1.15] 03-08-2020

### Fixed

- Hotfix for 1.1.13 - Actresses failing to write to metadata properly when falling back to secondary or greater priority

## [1.1.14] 03-08-2020

### Fixed

- Hotfix for 1.1.13 - Actors/screenshots metadata failing to download when setting `move-to-folder=false`

## [1.1.13] 03-07-2020

### Added

- Basic logging functionality for sorted and skipped files
  - Logs will be written by default, and cannot be turned off
  - View using `Javinizer -OpenLog`
- Additional file renaming strings
  - \<ACTORS>
  - \<SET>
  - \<LABEL>
  - \<ORIGINALTITLE>
- Setting option
  - `actors-name-delimiter=", "`

### Changed

- Cap of 215 max path length for created directories

### Fixed

- Genres failing to write to metadata properly when falling back to secondary or greater priority
- Actors/screenshots metadata failing to download when setting `move-to-folder=false`

## [1.1.12] 02-19-2020

### Added

- More flexible metadata file naming in settings
  - poster-file-string="poster"
  - thumbnail-file-string="fanart"
  - trailer-file-string="\<ID>-trailer"
  - nfo-file-string="\<ID>"
  - screenshot-folder-string="extrafanart"
  - screenshot-img-string="fanart"
  - actorimg-folder-string=".actors"

### Changed

- Console output now includes timestamps
- Condensed warning output on files failed to sort

### Fixed

- Files not failing to sort when genres are null

## [1.1.11] 02-08-2020

### Fixed

- Error on creating cloudflare session with Javlibrary.com
- Script failing when certain criteria are met when downloading actress thumbnails

## [1.1.10] 12-29-2019

### Added

- `-Strict` parameter to not clean filenames when scraping
- `rename-file` setting functionality

### Changed

- R18/DMM matching function to be more accurate and resilient
- JAVLibrary matching function to be more accurate and resilient

### Fixed

- Matching for r18 videos with only 1 returned search result or 0 matched search results

## [1.1.9] - 12-26-2019

### Fixed

- Additional error with downloading actress images with single actress video

## [1.1.8] - 12-26-2019

### Fixed

- Fixed single-word actresses appending underscore `_` to filename when downloading actress images
- Director and Genre metadata fields being cut off by slash `/` in Plex, replaced text with `-`

## [1.1.7] - 12-23-2019

### Changed

- Behavior when description translation fails to let original DMM description be written to nfo metadata

### Fixed

- Description metadata being set to null when `translate-description` is set to False
- JAVLibrary maker being set in director field when there is no director
- Additional R18 censors

## [1.1.6] - 12-19-2019

### Fixed

- `-UpdateThumbs` parameter erroring out on actress written due to missing ReversedFullName

## [1.1.5] - 12-19-2019

### Fixed

- Running Javinizer without `-Multi` parameter fails to sort any files
- Having setting `move-to-folder=False` writing non-video files to the root `-Path` directory

## [1.1.4] - 12-18-2019

### Changed

- Throttle limit from 5 --> 15
- `<set>` nfo metadata added by default, `<tag>` still optional

### Fixed

- Most redundant error messages when running multisort with multi-part videos
- Invalid trailer in aggregated object if R18 trailers not found

## [1.1.3] - 12-16-2019

### Changed

- Tag from `Series: <tag>` to `<tag>`

### Fixed

- Null series being added as a tag with `add-series-as-tag` true
- R18 series string not uncensoring censored words
- Additional R18 censored words

## [1.1.2] - 12-15-2019

### Fixed

- Additional issues to writing missing actresses to `r18-thumbs.csv`

## [1.1.1] - 12-15-2019

### Fixed

- Videos with 2+ actresses not writing to `r18-thumbs.csv` if missing

## [1.1.0] - 12-15-2019

### Added

- Add `SetEmbyActorThumbs` parameter to push actor thumbnails to your Emby/Jellyfin instance
- Add `BackupSettings` parameter to backup configuration files to an archive
- Add `RestoreSettings` parameter to restore configuration files from an archive to module root

### Changed

- Actor role tag `Actress` for each actress

### Fixed

- JAVLibrary metadata title null when scraping non-standard title such as T28-\*

## [1.0.1] - 12-14-2019

## Added

- Verbose messages for start/end of each file sort to more easily diagnose where issues arise during `multi` sort

### Fixed

- Null/invalid actresses being added to `r18-thumbs.csv` when found missing actress
- Direct file specified in `Path` parameter erroring due to DestinationPath being set to the file rather than its directory

## [1.0.0] - 12-14-2019 **Production-ready release**

### Added

- Setting `download-actress-img` to download actress images to video's local `.actors` folder
- Parameter `GetThumbs`, `UpdateThumbs`, and `OpenThumbs` to update r18 actress and thumburl csv file
- Parameter `Recurse` to find all video files recursively from sort path
- Feature to attempt to match actresses with missing thumburl to r18-thumbs.csv file
- Feature to automatically add scraped R18 actresses/thumburls to `r18-thumbs.csv file`
- Feature to normalize JAVLibrary genres to their R18 counterparts with setting `normalize-genres`
- `move-to-folder` functionality to allow user to not move file to new folder when sorting
- `minimum-filesize-to-sort` functionality to set minimum filesize video to sort
- `m4v` and `rmvb` video match support

### Changed

- Script to start cloudflare session before multi-sort begins
- All file downloads to run asynchronously except cover image

### Fixed

- Calling a relative destination path errored when running using `-Multi`
- Actress thumburl being ignored for single actress videos if actress priority set as `r18,javlibrary`

## [0.1.9] - 12-8-2019

### Added

- Parameter `OpenSettings` to open your settings file
- Parameter `Help` to display comment-based help for Javinizer usage

### Fixed

- Single actress sames scraped from R18 with trailing space

## [0.1.8] - 12-8-2019

### Changed

- Various parts for compatibility with PowerShell Gallery releases

## [0.1.7] - 12-8-2019

### Added

- Muli-threaded sorting functionality with parameter `Multi`
- Ability to select name order for actress with setting `first-last-name-order`
- Comment based help `PS> Help Javinizer`

### Changed

- Default DestinationPath will be set to your `Path` parameter rather than your settings `output-path`

### Fixed

- Javlibrary failing to match if the first result is error
- R18 failing to match video if ID doesn't return results, but ContentID does
- R18 finding `----` as ID set to null
- Actress thumburls being assigned to wrong actress
- File displayname being affected by `max-title-length`
- Invalid label on DMM when label is null
- Metadata values nulled if first priority did not return results
- Error message when actress is present but thumburl is null

## [0.1.6] - 12-6-2019

### Added

- `<RUNTIME>` as filename option
- Add setting `max-title-length`

### Changed

- Filename string replacement of `/` to `-`
- Keep empty `<thumb></thumb>` tag when actress thumburl is null

### Removed

- Alternate actress names surrounded by parentheses in metadata

### Fixed

- Brackets `[]` in filename titles erroring
- Writing actresses to nfo for videos with more than one actress

## [0.1.5] - 12-4-2019

### Added

- Settings being written in debug output
- T28/T-28 video recognition support
- String replacement for censored words on R18.com
- Error throw messages on unsuccessful download of images/trailer

### Changed

- Non-creation of `extrafanart` directory if no screenshots are downloaded
- More settings defaults to javlibrary
- Python dependency to Python3
- Unix operating systems will now call `python3` rather than `python`

### Removed

- Spaces between `-` in part number and trailer

### Fixed

- Genres failing to be written to nfo if first priority setting did not find video
- Actresses failing to be written to the nfo if there was only one actress
- Description translation failing due to unicode errors from Python 2 versions
- Having multipart videos in the sort directory causes non-multipart videos to have part number assigned to it
- JAVLibrary url search fail on first non-matched result
- Set `Test-Path` to literalpath for Unix compatibility
- Titles in directory name failing due to special characters not being removed

## [0.1.4] - 12-3-2019

### Changed

- .NET CultureInfo class conversion to hard coded month values for R18 data scrape
- Better catch for separation between multi-part and single videos

### Fixed

- Genre not being output in nfo
- Rating vote count not added in aggregated data object and nfo

## [0.1.3] - 12-2-2019

### Changed

- Setting `add-series-as-tag` set default false
- Remove debug output for `Convert-HTMLCharacter`

### Fixed

- Fixed `<trailer>` nfo data not appearing in scraped .nfo file
- Fixed javlibrary data object not being output
- Fix spacing in nfo between `<mpaa>` and next tags

## [0.1.2] - 12-1-2019

### Added

- Multi-part video support
- `<mpaa>XXX</mpaa>` tag in nfo metadata
- Better console output for skipped files
- Setting `download-trailer-vid` to allow downloading of movie trailers

### Changed

- `<rating>` tag in nfo metadata to legacy format
- Cloudflare `$session` scope to `global` instead of `script`
- `-Find` parameter better search output

### Fixed

- R18 series title scrape not working properly
- Function stopping on first skipped file
- Directory match Write-Host under the single match
- JAVLibrary url parsing and multiple result check
- Comma separated format with an extra space ', ' instead of ','
- Type 'attemping' to 'attempting'

## [0.1.1] - 11-30-2019

### Fixed

- Try/catch for directory sort

## [0.1.0] - 11-30-2019

### Added

- Initial functionality release
- Web searching with `-Find`
- File and directory sort with `-Path` and `-Apply`
