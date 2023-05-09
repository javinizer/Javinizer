# Updating Javinizer

Javinizer updates via the native PowerShell cmdlet `Update-Module` or using the inbuilt `-UpdateModule` command.&#x20;

## -UpdateModule (recommended)

`-UpdateModule` is a custom command for updating Javinizer to the latest version while persisting your existing settings files. This command requires that Javinizer is already installed on your system.

To update, run the following command:

```
Javinizer -UpdateModule
```

You may receive some errors while running, but it is largely ok to ignore them. If you are concerned, feel free to reach out via GitHub issues or my discord.

## Update-Module

{% hint style="danger" %}
Due to how modules work with PowerShell, your settings will not carry over from the previous version IF you use Update-Module. Make sure to back up your settings and copy them over to the new installation once it is complete.
{% endhint %}

`Update-Module` is the native PowerShell method to update modules to their latest version. As this method does not carry over your existing settings from the previous version, I do not recommend it unless your are comfortable with transferring your settings yourself.

To update, run the following command:

```
Update-Module Javinizer -Force
```

In the case that you forgot to copy your previous settings, don't worry! Updating the module does not fully remove the previous version.

To open your parent Javinizer module directory, run the following command and manually copy any desired files to your latest version:

```
Invoke-Item (Get-Item (Get-InstalledModule Javinizer).InstalledLocation).Parent
```
