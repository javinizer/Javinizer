function Get-VideoFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [int]$FileSize = 10,
        [switch]$Recurse
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
    }
    process {
        Test-ItemType

        if ((Get-Item $Path).Mode -match $directoryMode) {
            $files = Get-ChildItem -Path $Path -Recurse:$Recurse | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -and $_.Name -notlike '*1pon*'`
                    -and $_.Name -notlike '*carib*' `
                    -and $_.Name -notlike '*fc2*'`
                    -and $_.Name -notlike '*trailer'
                #-and $_.Length -ge ($FileSize * 1MB)`
            }
            # Test if the path is a file
        } elseif ((Get-Item $Path).Mode -match $itemMode) {
            $files = Get-Item -Path $Path | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -and $_.Name -notlike '*1pon*'`
                    -and $_.Name -notlike '*carib*' `
                    -and $_.Name -notlike '*fc2*'`
                    -and $_.Name -notlike '*trailer'
                #-and $_.Length -ge ($FileSize * 1MB)`
            }
        } else {
            throw "The path specified is neither directory nor file"
        }

        Write-Output $files
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
