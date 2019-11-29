function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    begin {
        $modulePath = (Get-Item $PSScriptroot).Parent
        $translatePath = Join-Path -Path $modulePath -ChildPath 'translate.py'
    }

    process {
        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
            $translatedString = python $translatePath $String
        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
            $translatedString = python3 $translatePath $String
        }

        Write-Output $translatedString
    }
}
