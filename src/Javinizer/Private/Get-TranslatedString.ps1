function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [String]$String,

        [String]$Language = 'en',

        [ValidateSet('googletrans', 'google_trans_new')]
        [String]$Module
    )

    process {
        if ($Module -eq 'googletrans') {
            $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate.py'
        } else {
            $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate_new.py'
        }

        if ($null -ne $String -and $String -ne '') {
            try {
                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                    $tempFile = python $translatePath $String $Language
                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                    $tempFile = python3 $translatePath $String $Language
                }
                $translatedString = Get-Content -Path $tempFile -Encoding utf8 -Raw
            } finally {
                Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
            }
        }

        Write-Output $translatedString
    }
}
