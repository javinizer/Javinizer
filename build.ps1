[cmdletbinding(DefaultParameterSetName = 'Task')]
param(
    # Build task(s) to execute
    [parameter(ParameterSetName = 'task', position = 0)]
    [string[]]$Task = 'default',

    # Bootstrap dependencies
    [switch]$Bootstrap,

    # List available build tasks
    [parameter(ParameterSetName = 'Help')]
    [switch]$Help,

    # Optional properties to pass to psake
    [hashtable]$Properties
)

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (Test-Path -Path (Join-Path -Path $PSScriptRoot -Childpath "requirements.psd1")) {
        if (-not (Get-Module -Name PSDepend -ListAvailable)) {
            Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force
        }
        Import-Module -Name PSDepend -Verbose:$false
        Invoke-PSDepend -Path (Join-Path -Path $PSScriptRoot -Childpath "requirements.psd1") -Install -Import -Force -WarningAction SilentlyContinue
    } else {
        Write-Warning "No [requirements.psd1] found. Skipping build dependency installation."
    }
}

# Execute psake task(s)
$psakeFile = (Join-Path -Path $PSScriptRoot -Childpath "psakefile.ps1")
if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Get-PSakeScriptTasks -buildFile $psakeFile |
        Format-Table -Property Name, Description, Alias, DependsOn
} else {
    Set-BuildEnvironment -Force
    Invoke-psake -buildFile $psakeFile -taskList $Task -nologo -properties $Properties
    exit ([int](-not $psake.build_success))
}
