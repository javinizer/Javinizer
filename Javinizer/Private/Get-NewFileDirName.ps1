function Get-NewFileDirName {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath
        $folderFormat = $settings.General.'rename-folder-string'
        $fileFormat = $settings.General.'rename-file-string'
        $displayNameFormat = $settings.General.'cms-displayname-string'
        $fileDirObject = @()
    }

    process {
        $newFolderName = Convert-FormatString -FormatString $folderFormat
        $newDisplayName = Convert-FormatString -FormatString $displayNameFormat
        $originalNewFileName = Convert-FormatString -FormatString $fileFormat

        if ($null -ne $DataObject.PartNumber) {
            $newFileName = $originalNewFileName + "-pt$($dataObject.PartNumber)"
        } else {
            $newFileName = $originalNewFileName
        }

        $fileDirObject = [pscustomobject]@{
            FolderName       = $newFolderName
            FileName         = $newFileName
            OriginalFileName = $originalNewFileName
            DisplayName      = $newDisplayName
        }

        Write-Output $fileDirObject
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Convert-FormatString {
    param (
        [string]$FormatString
    )

    begin {
        $invalidSymbols = @(
            '\',
            '/',
            ':',
            '*',
            '?',
            '"',
            '<',
            '>',
            '|'
        )
    }

    process {
        $title = $DataObject.Title
        # Remove invalid Windows filename symbols from title
        foreach ($symbol in $invalidSymbols) {
            $title = $title -replace [regex]::Escape($symbol), ''
        }

        $FormatString = $FormatString[1..($FormatString.Length - 2)] -join ''
        $newName = $FormatString `
            -replace '<ID>', "$($DataObject.Id)" `
            -replace '<TITLE>', "$title" `
            -replace '<RELEASEDATE>', "$($DataObject.ReleaseDate)" `
            -replace '<YEAR>', "$($DataObject.ReleaseYear)" `
            -replace '<STUDIO>', "$($DataObject.Maker)"

        Write-Output $newName
    }
}
