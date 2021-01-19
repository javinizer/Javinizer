function Get-JVModuleInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$ModuleManifestUrl
    )

    begin {
        if ($PSBoundParameters.ContainsKey('ModuleManifestUrl')) {
            try {
                $moduleManifest = Invoke-RestMethod -Uri $ModuleManifestUrl -Verbose:$false
            } catch {
                Write-Error "Error occurred when checking for new version: $PSItem" -ErrorAction Stop
            }
        } else {
            $moduleManifest = Get-Content -LiteralPath (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psd1')
        }
    }

    process {
        $moduleInfo = [PSCustomObject]@{
            Version      = ($moduleManifest | Select-String -Pattern "ModuleVersion\s*= '(.*)'").Matches.Groups[1].Value
            Prerelease   = ($moduleManifest | Select-String -Pattern "Prerelease\s*= '(.*)'").Matches.Groups[1].Value
            Project      = ($moduleManifest | Select-String -Pattern "ProjectUri\s*= '(.*)'").Matches.Groups[1].Value
            License      = ($moduleManifest | Select-String -Pattern "LicenseUri\s*= '(.*)'").Matches.Groups[1].Value
            ReleaseNotes = ($moduleManifest | Select-String -Pattern "ReleaseNotes\s*= '(.*)'").Matches.Groups[1].Value
        }

        Write-Output $moduleInfo
    }
}
