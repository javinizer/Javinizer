function Get-FindDataObject {
    [CmdletBinding()]
    param(
        [string]$Find
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        if (Test-Path -Path $find) {
            $getItem = Get-Item $Find
        }

        if ($Find -match 'http:\/\/') {
            if ($urlLocation.Result -eq 'r18') {
                $r18Data = Get-R18DataObject -Url $Find
                Write-Output $r18Data
            }

            if ($urlLocation.Result -eq 'dmm') {
                $dmmData = Get-DmmDataObject -Url $Find
                Write-Output $dmmData
            }

            if ($urlLocation.Result -eq 'javlibrary') {
                $javlibraryData = Get-JavlibraryDataObject -Url $Find
                Write-Output $javlibraryData
            }
        } elseif ($getItem.Mode -eq '-a----') {
            $fileDetails = Convert-JavTitle -Path $Find
            if ($r18) {
                $r18Data = Get-R18DataObject -Name $fileDetails.Id
                Write-Output $r18Data
            }

            if ($dmm) {
                $dmmData = Get-DmmDataObject -Name $fileDetails.Id
                Write-Output $dmmData
            }

            if ($javlibrary) {
                $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id
                Write-Output $javlibraryData
            }
        } else {
            if ($r18) {
                $r18Data = Get-R18DataObject -Name $Find
                Write-Output $r18Data
            }

            if ($dmm) {
                $dmmData = Get-DmmDataObject -Name $Find
                Write-Output $dmmData
            }

            if ($javlibrary) {
                $javlibraryData = Get-JavlibraryDataObject -Name $Find
                Write-Output $javlibraryData
            }
        }

    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
