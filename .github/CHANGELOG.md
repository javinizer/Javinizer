# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.3] - 12-16-2019
### Fixed
- Null series being added as a tag with `add-series-as-tag` true
- R18 series string not uncensoring censored words
- Additional R18 censored words

### Changed
- Tag from `Series: <tag>` to `<tag>`

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
- JAVLibrary metadata title null when scraping non-standard title such as T28-*

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
- Spaces between ` - ` in  part number and trailer

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

