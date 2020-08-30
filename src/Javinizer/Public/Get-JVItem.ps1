function Get-JVItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Path,
        [Parameter()]
        [Switch]$Recurse,
        [Parameter()]
        [Switch]$Strict,
        [Parameter(ValueFromPipeline = $true)]
        [PSObject]$Settings,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.minimumfilesize')]
        [Int]$MinimumFileSize,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.excludedfilestring')]
        [Array]$ExcludedStrings,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.includedfileextension')]
        [Array]$IncludedExtensions,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex')]
        [Boolean]$RegexEnabled,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.string')]
        [String]$RegexString,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.idmatch')]
        [Int]$RegexIdMatch,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.ptmatch')]
        [Int]$RegexPtMatch
    )

    process {
        $fileObject = @()
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

        if ($RegexEnabled) {
            $files = $files | Where-Object { $_.BaseName -match $RegexString }
            foreach ($file in $files) {
                $fileObject += $file | Convert-JVTitle -Strict:$Strict -RegexEnabled:$RegexEnabled -RegexString $RegexString -RegexIdMatch $RegexIdMatch -RegexPtMatch $RegexPtMatch
            }
        } else {
            foreach ($file in $files) {
                $fileObject += $file | Convert-JVTitle -Strict:$Strict -RegexEnabled:$RegexEnabled
            }
        }

        Write-Output $fileObject
    }
}
