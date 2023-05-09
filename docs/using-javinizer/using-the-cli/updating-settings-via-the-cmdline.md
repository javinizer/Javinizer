# Updating Settings via the Cmdline

If you are a power user, it is likely that you will want to use different settings depending on what type of files you are sorting. In that case, it would be not be in your best interest to constantly change out settings between sorts.

For these cases, you have two options to dynamically assign settings via the command-line.

## Use the -SettingsPath parameter

You are able to create alternative settings file using the default file.

The `-SettingsPath` parameter allows you to assign that alternate settings file via the command-line. By default, Javinizer uses the default `jvSettings.json` file located within your module root folder.

```
Javinizer -Path 'C:\JAV\Unsorted' -SettingsPath 'C:\JAV\altSettings.json'
```

## Use the -Set parameter

The `-Set` parameter allows you to assign individual settings via the command-line. It accepts a [hashtable](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about\_hash\_tables?view=powershell-7.1) of valid settings which will override the defaults provided by the settings file.

### Update a single setting

```
Javinizer -Path 'C:\JAV\Unsorted' -Set @{'sort.download.trailervid' = true}
```

### Update multiple settings

```
Javinizer -Path 'C:\JAV\Unsorted' -Set @{'sort.download.trailervid' = true; 'sort.format.nfo' = '<ID>
```
