# Media Library Setup

Javinizer supports any media library that accepts `.nfo` metadata files including but not limited to:

* Plex
* Emby
* Jellyfin
* Kodi

## Plex

Install the [XBMCnfoMoviesImporter.bundle](https://github.com/gboudreau/XBMCnfoMoviesImporter.bundle) plugin to your Plex Media Server.

Add a `Movies` library with:

* Scanner: Plex Movie Scanner
* Agent: XMBCnfoMoviesImporter
* Use plot instead of outline
* Enable generating collections from tags

## Emby/Jellyfin

Add a `Movies` library with (toggle show advanced settings on):

* All movie metadata downloaders unchecked
* All movie image fetchers unchecked

Create an API key and define it in your settings. This will be used to set actor thumb images to your Emby/Jellyfin instance via the `jvThumbs.csv` file in your Javinizer module folder.

| Setting     | Value                         | Example                       |
| ----------- | ----------------------------- | ----------------------------- |
| emby.url    | Emby/Jellyfin application URL | http:\\/\\/192.168.0.1:8096   |
| emby.apikey | Emby/Jellyfin API key         | 05f723d1380f4bb69233211911357 |

### Update all actors with a missing ThumbUrl

```
Javinizer -SetEmbyThumbs
```

### Update all actors

You may want to replace all actor images if you have made multiple modifications to the thumbnails in the [actor thumbnail csv](../configuration/settings/actor-thumbnail-csv.md) file.

```
Javinizer -SetEmbyThumbs -ReplaceAll
```

### Using -EmbyUrl and -EmbyApiKey

If you would rather use the command-line to define your URL and API Key, then you can use the `-EmbyUrl` and `-EmbyApiKey` commands. The two commands must be specified together.

```
Javinizer -SetEmbythumbs -EmbyUrl 'http://192.168.0.1:8096' -EmbyApiKey '05f723d1380f4bb69233211911357' `
-SetEmbyThumbs
```
