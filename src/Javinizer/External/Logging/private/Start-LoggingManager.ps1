function Start-LoggingManager {
    [CmdletBinding()]
    param(
        [TimeSpan]$ConsumerStartupTimeout = "00:00:10"
    )

    New-Variable -Name LoggingEventQueue    -Scope Script -Value ([System.Collections.Concurrent.BlockingCollection[hashtable]]::new(100))
    New-Variable -Name LoggingRunspace      -Scope Script -Option ReadOnly -Value ([hashtable]::Synchronized(@{ }))
    New-Variable -Name TargetsInitSync      -Scope Script -Option ReadOnly -Value ([System.Threading.ManualResetEventSlim]::new($false))

    $Script:InitialSessionState = [initialsessionstate]::CreateDefault()

    if ($Script:InitialSessionState.psobject.Properties['ApartmentState']) {
        $Script:InitialSessionState.ApartmentState = [System.Threading.ApartmentState]::MTA
    }

    # Importing variables into runspace
    foreach ($sessionVariable in 'ScriptRoot', 'LevelNames', 'Logging', 'LoggingEventQueue', 'TargetsInitSync') {
        $Value = Get-Variable -Name $sessionVariable -ErrorAction Continue -ValueOnly
        Write-Verbose "Importing variable $sessionVariable`: $Value into runspace"
        $v = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $sessionVariable, $Value, '', ([System.Management.Automation.ScopedItemOptions]::AllScope)
        $Script:InitialSessionState.Variables.Add($v)
    }

    # Importing functions into runspace
    foreach ($Function in 'Replace-Token', 'Initialize-LoggingTarget', 'Get-LevelNumber') {
        Write-Verbose "Importing function $($Function) into runspace"
        $Body = Get-Content Function:\$Function
        $f = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $Function, $Body
        $Script:InitialSessionState.Commands.Add($f)
    }

    #Setup runspace
    $Script:LoggingRunspace.Runspace = [runspacefactory]::CreateRunspace($Script:InitialSessionState)
    $Script:LoggingRunspace.Runspace.Name = 'LoggingQueueConsumer'
    $Script:LoggingRunspace.Runspace.Open()
    $Script:LoggingRunspace.Runspace.SessionStateProxy.SetVariable('ParentHost', $Host)
    $Script:LoggingRunspace.Runspace.SessionStateProxy.SetVariable('VerbosePreference', $VerbosePreference)

    # Spawn Logging Consumer
    $Consumer = {
        Initialize-LoggingTarget

        $TargetsInitSync.Set(); # Signal to the parent runspace that logging targets have been loaded

        foreach ($Log in $Script:LoggingEventQueue.GetConsumingEnumerable()) {
            if ($Script:Logging.EnabledTargets) {
                $ParentHost.NotifyBeginApplication()

                try {
                    #Enumerating through a collection is intrinsically not a thread-safe procedure
                    for ($targetEnum = $Script:Logging.EnabledTargets.GetEnumerator(); $targetEnum.MoveNext(); ) {
                        [string] $LoggingTarget = $targetEnum.Current.key
                        [hashtable] $TargetConfiguration = $targetEnum.Current.Value
                        $Logger = [scriptblock] $Script:Logging.Targets[$LoggingTarget].Logger

                        $targetLevelNo = Get-LevelNumber -Level $TargetConfiguration.Level

                        if ($Log.LevelNo -ge $targetLevelNo) {
                            Invoke-Command -ScriptBlock $Logger -ArgumentList @($Log, $TargetConfiguration)
                        }
                    }
                }
                catch {
                    $ParentHost.UI.WriteErrorLine($_)
                }
                finally {
                    $ParentHost.NotifyEndApplication()
                }
            }
        }
    }

    $Script:LoggingRunspace.Powershell = [Powershell]::Create().AddScript($Consumer, $true)
    $Script:LoggingRunspace.Powershell.Runspace = $Script:LoggingRunspace.Runspace
    $Script:LoggingRunspace.Handle = $Script:LoggingRunspace.Powershell.BeginInvoke()

    #region Handle Module Removal
    $OnRemoval = {
        $Module = Get-Module Logging

        if ($Module) {
            $Module.Invoke({
                Wait-Logging
                Stop-LoggingManager
            })
        }

        [System.GC]::Collect()
    }

    # This scriptblock would be called within the module scope
    $ExecutionContext.SessionState.Module.OnRemove += $OnRemoval

    # This scriptblock would be called within the global scope and wouldn't have access to internal module variables and functions that we need
    $Script:LoggingRunspace.EngineEventJob = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnRemoval
    #endregion Handle Module Removal

    if(-not $TargetsInitSync.Wait($ConsumerStartupTimeout)){
        throw 'Timed out while waiting for logging consumer to start up'
    }
}