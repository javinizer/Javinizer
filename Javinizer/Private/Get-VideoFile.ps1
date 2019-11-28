function Get-VideoFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [int]$FileSize = 10
    )

    process {
        # Test if Path is a directory
        if ((Get-Item $Path).Mode -eq 'd-----') {
            $Files = Get-ChildItem -Path $Path | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -and $_.Name -notlike '*1pon*'`
                    -and $_.Name -notlike '*carib*' `
                    -and $_.Name -notlike '*t28*'`
                    -and $_.Name -notlike '*fc2*'`
                    -and $_.Name -notlike '*COS☆ぱこ*'#`
                #-and $_.Length -ge ($FileSize * 1MB)`
            }
            # Test if the path is a file
        } elseif ((Get-Item $Path).Mode -eq '-a----' ) {
            $Files = Get-Item -Path $Path | Where-Object {
                $_.Name -like '*.mp4'`
                    -or $_.Name -like '*.avi'`
                    -or $_.Name -like '*.mkv'`
                    -or $_.Name -like '*.wmv'`
                    -or $_.Name -like '*.flv'`
                    -or $_.Name -like '*.mov'`
                    -and $_.Name -notlike '*1pon*'`
                    -and $_.Name -notlike '*carib*' `
                    -and $_.Name -notlike '*t28*'`
                    -and $_.Name -notlike '*fc2*'`
                    -and $_.Name -notlike '*COS☆ぱこ*'#`
                #-and $_.Length -ge ($FileSize * 1MB)`
            }
        } else {
            throw "The path specified is neither directory nor file"
        }

        Write-Output $Files
    }
}
