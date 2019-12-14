function Get-VideoFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [int]$FileSize,
        [switch]$Recurse,
        [object]$Settings
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $FileSize = $Settings.General.'minimum-filesize-to-sort'
    }

    process {
        # Test if Path is a directory or item
        if (Test-Path -Path (Get-Item -LiteralPath $Path) -PathType Container) {
            $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -or $_.Name -like '*.m4v'`
                    -or $_.Name -like '*.rmvb'`
                    -and $_.Name -notlike '*trailer'`
                    -and $_.Length -ge ($FileSize * 1MB)
            }
            # Test if the path is a file
        } elseif (Test-Path -Path (Get-Item -LiteralPath $Path) -PathType Leaf) {
            $files = Get-Item -LiteralPath $Path | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -or $_.Name -like '*.m4v'`
                    -or $_.Name -like '*.rmvb'`
                    -and $_.Name -notlike '*trailer'`
                    -and $_.Length -ge ($FileSize * 1MB)
            }
        } else {
            throw "[$($MyInvocation.MyCommand.Name)] The path specified is neither directory nor file"
        }

        Write-Output $files
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
