<#
    .SYNOPSIS
        Emits a log record

    .DESCRIPTION
        This function write a log record to configured targets with the matching level

    .PARAMETER Level
        The log level of the message. Valid values are DEBUG, INFO, WARNING, ERROR, NOTSET
        Other custom levels can be added and are a valid value for the parameter
        INFO is the default

    .PARAMETER Message
        The text message to write

    .PARAMETER Arguments
        An array of objects used to format <Message>

    .PARAMETER Body
        An object that can contain additional log metadata (used in target like ElasticSearch)

    .PARAMETER ExceptionInfo
        An optional ErrorRecord

    .EXAMPLE
        PS C:\> Write-Log 'Hello, World!'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, World!'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World' -Body @{Server='srv01.contoso.com'}

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Write-Log.ps1
#>
Function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Position = 2,
            Mandatory = $true)]
        [string] $Message,
        [Parameter(Position = 3,
            Mandatory = $false)]
        [array] $Arguments,
        [Parameter(Position = 4,
            Mandatory = $false)]
        [object] $Body = $null,
        [Parameter(Position = 5,
            Mandatory = $false)]
        [System.Management.Automation.ErrorRecord] $ExceptionInfo = $null
    )

    DynamicParam {
        New-LoggingDynamicParam -Level -Mandatory $false -Name "Level"
        $PSBoundParameters["Level"] = "INFO"
    }

    End {
        [string] $messageText = $Message

        if ($PSBoundParameters.ContainsKey('Arguments')) {
            $messageText = $messageText -f $Arguments
        }

        $levelNumber = Get-LevelNumber -Level $PSBoundParameters.Level
        $invocationInfo = (Get-PSCallStack)[$Script:Logging.CallerScope]

        # Split-Path throws an exception if called with a -Path that is null or empty.
        [string] $fileName = [string]::Empty
        if (-not [string]::IsNullOrEmpty($invocationInfo.ScriptName)) {
            $fileName = Split-Path -Path $invocationInfo.ScriptName -Leaf
        }

        $logMessage = [hashtable] @{
            timestamp    = Get-Date -UFormat $Defaults.Timestamp
            timestamputc = Get-Date ([datetime]::UtcNow) -UFormat $Defaults.Timestamp
            level        = Get-LevelName -Level $levelNumber
            levelno      = $levelNumber
            lineno       = $invocationInfo.ScriptLineNumber
            pathname     = $invocationInfo.ScriptName
            filename     = $fileName
            caller       = $invocationInfo.Command
            message      = $messageText
            body         = $Body
            execinfo     = $ExceptionInfo
            pid          = $PID
        }

        #This variable is initiated via Start-LoggingManager
        $Script:LoggingEventQueue.Add($logMessage)
    }
}
