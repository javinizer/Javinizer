# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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

