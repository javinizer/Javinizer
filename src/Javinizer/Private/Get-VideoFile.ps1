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
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $FileSize = $Settings.General.'minimum-filesize-to-sort'
    }

    process {
        $fixedPath = ($Path).replace('`[', '[').replace('`]', ']')
        $files = Get-ChildItem -LiteralPath $fixedPath -Recurse:$Recurse | Where-Object {
            $_.Name -like '*.mp4'`
                -or $_.Name -like '*.avi'`
                -or $_.Name -like '*.mkv'`
                -or $_.Name -like '*.wmv'`
                -or $_.Name -like '*.flv'`
                -or $_.Name -like '*.mov'`
                -or $_.Name -like '*.m4v'`
                -or $_.Name -like '*.rmvb'`
                -and $_.Name -notlike '*-trailer*'`
                -and $_.Length -ge ($FileSize * 1MB)
        }

        Write-Output $files
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
