# Sorting Files

Javinizer's primary function is to sort your local JAV media files into an ordered format to use within a media library. It is likely that you will want to read the settings documentation to make changes before sorting.  The commandline parameters are as follows:

```
Javinizer [[-Path] <String>] [[-DestinationPath] <String>] [-Recurse] 
[-Depth <Int32>] [-Url <Array>] [-SettingsPath <FileInfo>] [-Strict] 
[-MoveToFolder <Boolean>] [-RenameFile <Boolean>] [-Force] [-HideProgress]
[-Update] [-IsThread] [-Set <Hashtable>] [<CommonParameters>]
```

## Sorting a path of files

This will most likely be your go-to command when running Javinizer. This utilizes the `-Path`, `-DestinationPath`, and optionally the `-Recurse` command.

### Use settings locations

By default, Javinizer will assign the `-Path` and `-DestinationPath` via your settings.

* Path  -> `location.input`
* Destination Path -> `location.output`

```
Javinizer
```

### Use command-line locations

If  `-DestinationPath` is not assigned via the command-line or the `location.output` setting, then it will automatically be assigned to the same location as your `-Path`.

* Path -> `C:\JAV\Unsorted`
* Destination Path -> `C:\JAV\Unsorted`

```
Javinizer -Path 'C:\JAV\Unsorted'
```

Otherwise, you can just set both `-Path` and `-DestinationPath` on the command-line.

* Path -> `C:\JAV\Unsorted`
* Destination Path -> `C:\JAV\Sorted`

```
Javinizer -Path 'C:\JAV\Unsorted' -DestinationPath 'C:\JAV\Sorted'
```

## Movies not being matched

### Using direct URLs

If for whatever reason Javinizer is unable to find a movie via the ID on a scraper, you can use the URLs the sort the file. The URLs will need to be defined as an array. The `-Path` needs to be the direct path to the file, not a directory.

#### Use URLs in a single command

```
Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -Url 'http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/videos/vod/movies/detail/-/id=118abp00420/'
```

#### Use URLs in a separate variable

```
$Urls = @('http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/videos/vod/movies/detail/-/id=118abp00420/')
Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -Url $Urls
```

### Using -Strict

If a file is not being matched, it may be because the default filematcher is incorrectly matching your filename to the scraper source ID. View the documentation in the [File Matching](../file-matching/) article to see how the `-Strict` parameter can be used to directly match the filename as the ID.

```
Javinizer -Path 'C:\JAV\Unsorted' -Strict
```

## Updating already-sorted files

If you want to update metadata for already-sorted files, you can use the `-Update` parameter. The `-Update` parameter will not move any of your movie files, and only replace the `.nfo` metadata file by default.

```
Javinizer -Path 'C:\JAV\Sorted' -Recurse -Update
```

### Using -Force

Using the `-Force` parameter will also replace all image files.&#x20;

```
Javinizer -Path 'C:\JAV\Sorted' -Recurse -Update -Force
```
