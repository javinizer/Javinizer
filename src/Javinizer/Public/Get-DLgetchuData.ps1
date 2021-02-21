function Get-DLgetchuData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Not found on DLgetchu [$Url]"
            continue
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action Stop
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = 'dlgetchuja'
            Url           = $Url
            Id            = Get-DLgetchuId -WebRequest $webRequest
            Title         = Get-DLgetchuTitle -WebRequest $webRequest
            Description   = Get-DLgetchuDescription -WebRequest $webRequest
            ReleaseDate   = Get-DLgetchuReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-DLgetchuReleaseYear -WebRequest $webRequest
            Runtime       = Get-DLgetchuRuntime -WebRequest $webRequest
            Maker         = Get-DLgetchuMaker -WebRequest $webRequest
            Genre         = Get-DLgetchuGenre -WebRequest $webRequest
            CoverUrl      = Get-DLgetchuCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-DLgetchuScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] DLgetchu data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
