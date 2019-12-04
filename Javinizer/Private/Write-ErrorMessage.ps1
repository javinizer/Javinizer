function Write-ErrorMessage {
    [CmdletBinding(DefaultParameterSetName = 'ErrorMessage')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'ErrorMessage', ValueFromPipeline, Mandatory)][string]$errorMessage,
         [Parameter(ParameterSetName = 'ErrorRecord', ValueFromPipeline)][System.Management.Automation.ErrorRecord]$errorRecord,
         [Parameter(ParameterSetName = 'Exception', ValueFromPipeline)][Exception]$exception
    )

    switch ($PsCmdlet.ParameterSetName) {
        'ErrorMessage' {
            $err = $errorMessage
        }
        'ErrorRecord' {
            $errorMessage = @($error)[0]
            $err = $errorRecord
        }
        'Exception' {
            $errorMessage = $exception.Message
            $err = $exception
        }
    }

    Write-Error -Message $err -ErrorAction SilentlyContinue
    $Host.UI.WriteErrorLine($errorMessage)
}