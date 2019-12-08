function Start-MultiSort {
    [CmdletBinding()]
    param (
        [system.io.fileinfo]$Path,
        [system.io.fileinfo]$DestinationPath,
        [int]$Throttle
    )

    #$files = Get-ChildItem "Z:\git\Projects\JAV-Organizer\dev\dev" | Where-Object { $_.Mode -eq '-a----' -and $_.Extension -eq '.mp4' }
    $files = Get-VideoFile -Path $Path
    $ScriptRoot = $PSScriptRoot
    $ScriptRoot = (Get-Item $ScriptRoot).Parent

    $importVariables = @(
        'ScriptRoot',
        'DestinationPath'
    )

    $files | Start-RSJob -VariablesToImport $importVariables -Verbose -ScriptBlock {
        $debugPreference = 'continue'
        $verbosePreference = 'continue'
        Javinizer -Path $_.FullName -DestinationPath $DestinationPath -r18 -Scriptroot $ScriptRoot -Verbose
    } -Throttle $Throttle -FunctionFilesToImport (Join-Path $PSScriptRoot -ChildPath 'Get-AggregatedDataObject.ps1'), `
    (Join-Path -Path (Get-Item $PSScriptRoot).Parent -ChildPath (Join-Path 'Public' -ChildPath 'javinizer.ps1')), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-CommaDelimitedString.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-HtmlCharacter.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-JavTitle.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-DmmDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-FindDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-JavlibraryDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-JavlibraryUrl.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-MetadataNfo.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-MetadataPriority.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-NewFileDirName.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18DataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18ThumbUrl.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18Url.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-TranslatedString.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-VideoFile.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Import-IniSettings.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'New-CloudflareSession.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Set-JavMovie.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-RequiredMetadata.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-UrlLocation.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-UrlMatch.ps1')

}
