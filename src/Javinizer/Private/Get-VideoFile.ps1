function Get-VideoFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [Parameter()]
        [switch]$Recurse,
        [Parameter()]
        [int]$MinimumFileSize,
        [Parameter()]
        [array]$ExcludedStrings,
        [Parameter()]
        [array]$IncludedExtensions,
        [Parameter()]
        [string]$RegexEnabled,
        [Parameter()]
        [string]$RegexString
    )

    begin {
        Write-JLog -Level Debug -Message "Function started"
    }

    process {
        if ($ExcludedStrings) {
            $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Exclude:$ExcludedStrings | Where-Object {
                $_.Extension -in $IncludedExtensions `
                    -and $_.Length -ge ($FileSize * 1MB)
            }
        } else {
            $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse | Where-Object {
                $_.Extension -in $IncludedExtensions `
                    -and $_.Length -ge ($FileSize * 1MB)
            }
        }

        if ($RegexEnabled -eq 'true') {
            $files = $files | Where-Object { $_.BaseName -match $RegexString }
        }

        Write-Output $files
    }

    end {
        Write-JLog -Level Debug -Message "Function ended"
    }
}
