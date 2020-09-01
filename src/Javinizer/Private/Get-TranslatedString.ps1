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
            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                $translatedString = python $translatePath $String $Language
            } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                $translatedString = python3 $translatePath $String $Language
            }
        }

        Write-Output $translatedString
    }
}
