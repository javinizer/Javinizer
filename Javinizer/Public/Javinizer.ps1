function Javinizer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Name,
        [System.IO.FileInfo]$Path,
        [switch]$cf,
        [switch]$r18,
        [switch]$dmm,
        [switch]$javlibrary
    )

    begin {
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath
    }

    process {
        if ($cf.IsPresent) {
            New-CloudflareSession
        }

        if ($r18.IsPresent) {
            $r18Data = Get-R18DataObject -Name $Name
        }

        if ($dmm.IsPresent) {
            $dmmData = Get-DmmDataObject -Name $Name
        }

        if ($javlibrary.IsPresent) {
            $javlibraryData = Get-JavLibraryDataObject -Name $Name
        }
    }
}
