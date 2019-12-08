function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String,
        [string]$ScriptRoot
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $translatePath = Join-Path -Path $ScriptRoot -ChildPath 'translate.py'
    }

    process {
        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
            $translatedString = python $translatePath $String
        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
            $translatedString = python3 $translatePath $String
        }

        Write-Output $translatedString
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
