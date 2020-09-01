$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$PSModule = $ExecutionContext.SessionState.Module
$PSModuleRoot = $PSModule.ModuleBase

# Dot source public/private functions
$PublicFunctions = @(Get-ChildItem -Path "$SCriptPath\public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path "$SCriptPath\private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)

$AllFunctions = $PublicFunctions + $PrivateFunctions
foreach ($Function in $AllFunctions) {
    try {
        . $Function.FullName
    } catch {
        throw ('Unable to dot source {0}' -f $Function.FullName)
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName

Set-LoggingVariables

Start-LoggingManager
