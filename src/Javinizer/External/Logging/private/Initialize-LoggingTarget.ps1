function Initialize-LoggingTarget {
    param()

    $targets = @()
    $targets += Get-ChildItem "$ScriptRoot\targets" -Filter '*.ps1'

    if ((![String]::IsNullOrWhiteSpace($Script:Logging.CustomTargets)) -and (Test-Path -Path $Script:Logging.CustomTargets -PathType Container)) {
        $targets += Get-ChildItem -Path $Script:Logging.CustomTargets -Filter '*.ps1'
    }

    foreach ($target in $targets) {
        $module = . $target.FullName
        $Script:Logging.Targets[$module.Name] = @{
            Init           = $module.Init
            Logger         = $module.Logger
            Description    = $module.Description
            Defaults       = $module.Configuration
            ParamsRequired = $module.Configuration.GetEnumerator() | Where-Object {$_.Value.Required -eq $true} | Select-Object -ExpandProperty Name | Sort-Object
        }
    }
}
