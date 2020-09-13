#Requires -PSEdition Core

function Get-R18Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter()]
        [System.IO.FileInfo]$UncensorCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv')
    )

    process {
        $movieDataObject = @()
        try {
            $replaceHashtable = Import-Csv -LiteralPath $UncensorCsvPath
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when import uncensor csv at path [$UncensorCsvPath]: $PSItem"
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'lg=zh') { 'r18zh' } else { 'r18' }
            Url           = $Url
            ContentId     = Get-R18ContentId -WebRequest $webRequest
            Id            = Get-R18Id -WebRequest $webRequest
            Title         = Get-R18Title -WebRequest $webRequest -Replace $replaceHashTable
            Description   = Get-R18Description -WebRequest $webRequest
            ReleaseDate   = Get-R18ReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-R18ReleaseYear -WebRequest $webRequest
            Runtime       = Get-R18Runtime -WebRequest $webRequest
            Director      = Get-R18Director -WebRequest $webRequest
            Maker         = Get-R18Maker -WebRequest $webRequest
            Label         = Get-R18Label -WebRequest $webRequest
            Series        = Get-R18Series -WebRequest $webRequest -Replace $replaceHashTable
            Actress       = Get-R18Actress -WebRequest $webRequest
            Genre         = Get-R18Genre -WebRequest $webRequest -Replace $replaceHashTable
            CoverUrl      = Get-R18CoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-R18ScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-R18TrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
