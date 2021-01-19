function Get-JVSettings {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.IO.FileInfo]$Path
    )

    process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            $settingsPath = $Path
        } else {
            $settingsPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvSettings.json'
        }

        try {
            $rawSettings = Get-Content -Path $settingsPath -Raw
            $settings = $rawSettings | ConvertFrom-Json -Depth 32
        } catch {
            Write-Error "Error occurred when retrieving settings: $PSItem" -ErrorAction Stop
        }

        Write-Output $settings
    }
}
