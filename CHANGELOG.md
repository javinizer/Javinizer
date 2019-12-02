# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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

