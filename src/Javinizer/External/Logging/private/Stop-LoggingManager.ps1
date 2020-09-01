function Stop-LoggingManager {
    param ()

    $Script:LoggingEventQueue.CompleteAdding()
    $Script:LoggingEventQueue.Dispose()

    [void] $Script:LoggingRunspace.Powershell.EndInvoke($Script:LoggingRunspace.Handle)
    [void] $Script:LoggingRunspace.Powershell.Dispose()

    $ExecutionContext.SessionState.Module.OnRemove = $null
    Get-EventSubscriber | Where-Object { $_.Action.Id -eq $Script:LoggingRunspace.EngineEventJob.Id } | Unregister-Event

    Remove-Variable -Scope Script -Force -Name LoggingEventQueue
    Remove-Variable -Scope Script -Force -Name LoggingRunspace
    Remove-Variable -Scope Script -Force -Name TargetsInitSync
}