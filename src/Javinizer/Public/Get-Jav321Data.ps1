function Get-Jav321Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-RestMethod -Uri $Url -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = 'jav321ja'
            Url           = $Url
            Id            = Get-Jav321Id -WebRequest $webRequest
            Title         = Get-Jav321Title -WebRequest $webRequest
            Description   = Get-Jav321Description -WebRequest $webRequest
            ReleaseDate   = Get-Jav321ReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-Jav321ReleaseYear -WebRequest $webRequest
            Runtime       = Get-Jav321Runtime -WebRequest $webRequest
            Series        = Get-Jav321Series -WebRequest $webRequest
            Maker         = Get-Jav321Maker -WebRequest $webRequest
            Actress       = Get-Jav321Actress -WebRequest $webRequest
            Genre         = Get-Jav321Genre -WebRequest $webRequest
            CoverUrl      = Get-Jav321CoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-Jav321ScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Jav321 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
