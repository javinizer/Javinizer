function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [String]$String,

        [String]$Language = 'en'
    )

    process {
        $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate.py'

        if ($String -eq $null -or $String -eq '') {
            # Do not translate if empty
        } else {
            try {
                $tempFile = New-TemporaryFile
                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                    python $translatePath $String $Language | Set-Content $tempFile -Encoding oem
                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                    python3 $translatePath $String $Language | Set-Content $tempFile -Encoding oem
                }
                $translatedString = Get-Content -Path $tempFile -Encoding utf8 -Raw
            } finally {
                Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
            }
        }
        Write-Output $translatedString
    }
}
