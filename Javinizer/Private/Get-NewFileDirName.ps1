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
        $fileDirObject = @()
    }

    process {
        $folderFormat = $folderFormat[1..($folderFormat.Length - 2)] -join ''
        $fileFormat = $fileFormat[1..($fileFormat.Length - 2)] -join ''

        $newFolderName = $folderFormat `
            -replace '<ID>', "$($DataObject.Id)" `
            -replace '<TITLE>', "$($DataObject.Title)" `
            -replace '<RELEASEDATE>', "$($DataObject.Date)" `
            -replace '<YEAR>', "$($DataObject.Year)" `
            -replace '<STUDIO>', "$($DataObject.Maker)" `

        $newFileName = $fileFormat `
            -replace '<ID>', "$($DataObject.Id)" `
            -replace '<TITLE>', "$($DataObject.Title)" `
            -replace '<RELEASEDATE>', "$($DataObject.Date)" `
            -replace '<YEAR>', "$($DataObject.Year)" `
            -replace '<STUDIO>', "$($DataObject.Maker)" `

        $fileDirObject = [pscustomobject]@{
            FolderName = $newFolderName
            FileName   = $newFileName
        }

        Write-Output $fileDirObject
    }
}
