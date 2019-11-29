function Get-NewFileDirName {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject
    )

    begin {
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath
        $folderFormat = $settings.General.'rename-folder-string'
        $fileFormat = $settings.General.'rename-file-string'
        $displayNameFormat = $settings.General.'cms-displayname-string'
        $fileDirObject = @()
    }

    process {
        $newFolderName = Convert-FormatString -FormatString $folderFormat
        $newFileName = Convert-FormatString -FormatString $fileFormat
        $newDisplayName = Convert-FormatString -FormatString $displayNameFormat

        $fileDirObject = [pscustomobject]@{
            FolderName  = $newFolderName
            FileName    = $newFileName
            DisplayName = $newDisplayName
        }

        Write-Output $fileDirObject
    }
}

function Convert-FormatString {
    param (
        [string]$FormatString
    )

    process {
        $FormatString = $FormatString[1..($FormatString.Length - 2)] -join ''
        $newName = $FormatString `
            -replace '<ID>', "$($DataObject.Id)" `
            -replace '<TITLE>', "$($DataObject.Title)" `
            -replace '<RELEASEDATE>', "$($DataObject.ReleaseDate)" `
            -replace '<YEAR>', "$($DataObject.ReleaseYear)" `
            -replace '<STUDIO>', "$($DataObject.Maker)"
        Write-Output $newName
    }
}
