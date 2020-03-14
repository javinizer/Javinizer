function Update-Javinizer {
    $currentVer = (Get-InstalledModule -Name Javinizer).Version
    $latestVer = (Find-Module -Name Javinizer).Version

    if ($currentVer -ne $latestVer) {
        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] There is a newer version of Javinizer available: [$currentVer --> $latestVer]"
    }
}


<#
function Update-Javinizer {
    param (
        [string]$ScriptRoot,
        [object]$Settings
    )

    $currentVer = (Get-InstalledModule -Name Javinizer).Version
    $latestVer = (Find-Module -Name Javinizer).Version
    Update-Module -Name Javinizer -AcceptLicense -Confirm:$false -Force

    $modulePaths = (Get-Module -ListAvailable).Path | Where-Object { $_ -match 'Javinizer' }
    $currentVerPath = (Get-Item ($modulePaths | Where-Object { $_ -match "$currentVer" })).DirectoryName
    $latestVerPath = (Get-Item ($modulePaths | Where-Object { $_ -match "$latestVer" })).DirectoryName

}
#>
