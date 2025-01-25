$UserAgent = 'Javinizer (+https://github.com/javinizer/Javinizer)'

function Get-R18DevData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter()]
        [Switch]$Ja,

        [Parameter()]
        [System.IO.FileInfo]$UncensorCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv')
    )

    process {
        $movieDataObject = @()
        if ($Url -like '*id=*') {
            $contentId = (($Url -split 'id=')[1] -split '\/')[0]
        } elseif ($Url -like '*combined=*') {
            $contentId = (($Url -split 'combined=')[1] -split '\/')[0]
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Invalid URL provided [$Url]: $PSItem"
        }

        $apiUrl = "https://r18.dev/videos/vod/movies/detail/-/combined=$($contentId)/json"

        try {
            $replaceHashtable = Import-Csv -LiteralPath $UncensorCsvPath
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when import uncensor csv at path [$UncensorCsvPath]: $PSItem"
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$apiUrl]"
            $webRequest = (Invoke-WebRequest -Uri $apiUrl -UserAgent $UserAgent -Method Get -Verbose:$false).Content | ConvertFrom-Json
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Ja) { 'r18dev-ja' } else { 'r18dev' }
            Url           = $Url
            ContentId     = Get-R18DevContentId -WebRequest $webRequest
            Id            = Get-R18DevId -WebRequest $webRequest
            Title         = Get-R18DevTitle -WebRequest $webRequest -Replace $replaceHashTable -Ja:$Ja
            Description   = Get-R18DevDescription -WebRequest $webRequest -Ja:$Ja
            ReleaseDate   = Get-R18DevReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-R18DevReleaseYear -WebRequest $webRequest
            Runtime       = Get-R18DevRuntime -WebRequest $webRequest
            Director      = Get-R18DevDirector -WebRequest $webRequest -Ja:$Ja
            Maker         = Get-R18DevMaker -WebRequest $webRequest -Ja:$Ja
            Label         = Get-R18DevLabel -WebRequest $webRequest -Replace $replaceHashTable -Ja:$Ja
            Series        = Get-R18DevSeries -WebRequest $webRequest -Replace $replaceHashTable -Ja:$Ja
            Actress       = Get-R18DevActress -WebRequest $webRequest -Url $Url
            Genre         = Get-R18DevGenre -WebRequest $webRequest -Replace $replaceHashTable -Ja:$Ja
            CoverUrl      = Get-R18DevCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-R18DevScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-R18DevTrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
