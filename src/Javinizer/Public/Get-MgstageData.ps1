function Get-MgstageData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    begin {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie
        $cookie.Name = 'adc'
        $cookie.Value = '1'
        $cookie.Domain = '.mgstage.com'
        $session.Cookies.Add($cookie)
    }

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $session -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = 'mgstageja'
            Url           = $Url
            Id            = Get-MgstageId -WebRequest $webRequest
            Title         = Get-MgstageTitle -WebRequest $webRequest
            Description   = Get-MgstageDescription -WebRequest $webRequest
            ReleaseDate   = Get-MgstageReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-MgstageReleaseYear -WebRequest $webRequest
            Runtime       = Get-MgstageRuntime -WebRequest $webRequest
            Maker         = Get-MgstageMaker -WebRequest $webRequest
            Label         = Get-MgstageLabel -WebRequest $webRequest
            Series        = Get-MgstageSeries -WebRequest $webRequest
            Rating        = Get-MGstageRating -WebRequest $webRequest
            Actress       = Get-MgstageActress -WebRequest $webRequest
            Genre         = Get-MgstageGenre -WebRequest $webRequest
            CoverUrl      = Get-MgstageCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-MgstageScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-MgstageTrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Mgstage data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
