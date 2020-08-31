function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$String,
        [String]$Language
    )

    process {
        $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate.py'

        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
            $translatedString = python $translatePath $String $Language
        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
            $translatedString = python3 $translatePath $String $Language
        }

        Write-Output $translatedString
    }
}
