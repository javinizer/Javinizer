# Using the CLI

```
help Javinizer
```

```
NAME
Javinizer

SYNOPSIS
A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.


SYNTAX
Javinizer [[-Path] <String>] [[-DestinationPath] <String>] [-Recurse] 
[-Depth <Int32>] [-Url <Array>] [-SettingsPath <FileInfo>] [-Strict] 
[-MoveToFolder <Boolean>] [-RenameFile <Boolean>] [-Force] [-HideProgress]
[-Update] [-IsThread] [-Set <Hashtable>] [<CommonParameters>]

Javinizer [[-Path] <String>] [-Recurse] [-Depth <Int32>] 
[-SettingsPath <FileInfo>] -UpdateNfo [<CommonParameters>]

Javinizer [[-Path] <String>] [-Recurse] [-Depth <Int32>] 
[-SettingsPath <FileInfo>] [-Strict] [-HideProgress]
[-SetOwned] [-Set <Hashtable>] [<CommonParameters>]

Javinizer [-SettingsPath <FileInfo>] [-Find] <PSObject> [-Aggregated] 
[-Nfo] [-R18Dev] [-Dmm] [-DmmJa] [-Javlibrary] [-JavlibraryZh] 
[-JavlibraryJa] [-Javbus] [-JavbusJa] [-JavbusZh] [-Jav321Ja] [-Set <Hashtable>]
[<CommonParameters>]

Javinizer [-SetEmbyThumbs] [-EmbyUrl <String>] [-EmbyApiKey <String>]
[-ReplaceAll] [-Set <Hashtable>] [<CommonParameters>]

Javinizer [-OpenSettings] [-OpenLog] [-OpenThumbs] [-OpenGenres] [-OpenUncensor] 
[-Set <Hashtable>] [<CommonParameters>]

Javinizer -UpdateThumbs [-Pages <Array>] [-Set <Hashtable>] [<CommonParameters>]

Javinizer -Version [<CommonParameters>]

Javinizer -Help [<CommonParameters>]


DESCRIPTION
Javinizer detects your local JAV files and structures them into self-hosted 
media player compatible formats. A metadata nfo file is created per file 
to be read by the media player library.


PARAMETERS
-Path <DirectoryInfo>
    Specifies the file or directory path to JAV files. 
    Defaults to 'location.input' in the settings file.

-DestinationPath <DirectoryInfo>
    Specifies the directory path to output sorted JAV files. 
    Defaults to 'location.output' in the settings file.

-Recurse [<SwitchParameter>]
    Specifies to search sub-directories in your Path.

-Depth <Int32>
    Specifies the depth of sub-directories to search when using -Recurse.

-Url <Array>
    Specifies a url or an array of urls to sort a single JAV file.

-SettingsPath <FileInfo>
    Specifies the path to the settings file you want Javinizer to use. 
    Defaults to the jvSettings.json file in the module root.

-Strict [<SwitchParameter>]
    Specifies to not automatically try to match filenames to the movie ID. 
    Can be useful for movies like T28- and R18-.

-Update [<SwitchParameter>]
    Specifies to only create/update metadata files without moving any 
    existing files.

-MoveToFolder <Boolean>
    Specifies whether or not to move sorted files to its own folder. 
    Defaults to 'sort.movetofolder' in the settings file.

-RenameFile <Boolean>
    Specifies whether or not to rename sorted files. 
    Defaults to 'sort.renamefile' in the settings file.

-Force [<SwitchParameter>]
    Specifies to replace all sort files (nfo, images, trailers, etc.) 
    if they already exist. Without -Force, only the nfo file will 
    be replaced if it already exists.

-HideProgress [<SwitchParameter>]
    Specifies to hide the progress bar during sort.

-IsThread [<SwitchParameter>]
    Specifies that the current running Javinizer instance is a thread. 
    This is for internal purposes only.

-Find <PSObject>
    Specifies an ID or an array of URLs to search metadata for.

-Aggregated [<SwitchParameter>]
    Specifies to aggregate the data from -Find according to your settings.

-Nfo [<SwitchParameter>]
    Specifies to output the nfo contents from -Find.

-R18Dev [<SwitchParameter>]
    Specifies to search R18.dev when using -Find.

-Dmm [<SwitchParameter>]
    Specifies to search Dmm when using -Find.

-DmmJa [<SwitchParameter>]
    Specifies to search Dmm-Japanese when using -Find.

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
    Specifies to set Emby/Jellyfin actress thumbnails using the thumbnail csv. 
    If 'location.thumbcsv' is not specified in the settings file, it defaults 
    to the jvGenres.csv file in the module root. 'emby.url' and 'emby.apikey'
    need to be defined in the settings file.

-EmbyUrl <String>
    Specifies the Emby/Jellyfin baseurl instead of using the setting 'emby.url'.

-EmbyApiKey <String>
    Specifies the Emby/Jellyfin API key instead of using the setting 'emby.apikey'.

-ReplaceAll [<SwitchParameter>]
    Specifies to replace all Emby/Jellyfin actress thumbnails regardless if 
    they already have one.

-OpenSettings [<SwitchParameter>]
    Specifies to open the settings file.

-OpenLog [<SwitchParameter>]
    Specifies to open the log file.

-OpenThumbs [<SwitchParameter>]
    Specifies to open the actress thumbnails file.

-OpenGenres [<SwitchParameter>]
    Specifies to open the genre replacements file.

-OpenUncensor [<SwitchParameter>]
    Specifies to open the R18 uncensor replacements file.

-UpdateThumbs [<SwitchParameter>]
    Specifies to update the actress thumbnails file.

-Pages <Array>
    Specifies an array as a range of pages to search for and update the 
    actress thumbnails file.

-Set <Hashtable>
    Specifies a hashtable to update specific settings on the command-line.

-SetOwned [<SwitchParameter>]
    Specifies to set a path of movie files as owned on JavLibrary.

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
