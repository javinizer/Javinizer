<# Borrowed from http://draith.azurewebsites.net/?p=337
    .SYNOPSIS
        Simple function to write to a log file

    .DESCRIPTION
        This function will write to a log file, pre-pending the date/time, level of detail, and supplied information

    .PARAMETER text
        This is the main text to log

    .PARAMETER Level
        INFO,WARN,ERROR,DEBUG

    .PARAMETER Log
        Name of the log file to send the data to.

    .PARAMETER UseMutex
        A description of the UseMutex parameter.

    .EXAMPLE
        write-log -text "This is the main problem." -level ERROR -log c:\test.log

    .NOTES
        Created by Donnie Taylor.
        Version 1.0     Date 4/5/2016
#>
function Write-Log {
    param
    (
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ValidateNotNull()]
        [string]$Text,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')]
        [string]$Level,
        [Parameter(Mandatory = $true,
            Position = 2)]
        [system.io.fileinfo]$Log,
        [Parameter(Position = 3)]
        [switch]$UseMutex
    )

    $date = Get-TimeStamp
    $line = "$date  $level  $text"
    if ($UseMutex.IsPresent) {
        $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
        $LogMutex.WaitOne() | Out-Null
        $line | Out-File -FilePath $log -Append
        $LogMutex.ReleaseMutex() | Out-Null
    } else {
        $line | Out-File -FilePath $log -Append
    }
}
