#Requires -PSEdition Core

function Get-DmmData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()
        if ($Url -match '/en/') {
            $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'ckcy'
            $cookie.Value = '2'
            $cookie.Domain = 'dmm.co.jp'
            $session.Cookies.Add($cookie)
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'cklg'
            $cookie.Value = 'en'
            $cookie.Domain = 'dmm.co.jp'
            $session.Cookies.Add($cookie)
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'age_check_done'
            $cookie.Value = '1'
            $cookie.Domain = 'dmm.co.jp'
            $session.Cookies.Add($cookie)
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -WebSession $session -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match '/en/') { 'dmm' } else { 'dmmja' }
            Url           = $Url
            Id            = Get-DmmContentId -WebRequest $webRequest
            Title         = Get-DmmTitle -WebRequest $webRequest
            Description   = Get-DmmDescription -WebRequest $webRequest
            ReleaseDate   = Get-DmmReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-DmmReleaseYear -WebRequest $webRequest
            Runtime       = Get-DmmRuntime -WebRequest $webRequest
            Director      = Get-DmmDirector -WebRequest $webRequest
            Maker         = Get-DmmMaker -WebRequest $webRequest
            Label         = Get-DmmLabel -WebRequest $webRequest
            Series        = Get-DmmSeries -WebRequest $webRequest
            Rating        = Get-DmmRating -WebRequest $webRequest
            Actress       = Get-DmmActress -WebRequest $webRequest
            Genre         = Get-DmmGenre -WebRequest $webRequest
            CoverUrl      = Get-DmmCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-DmmScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] DMM data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
