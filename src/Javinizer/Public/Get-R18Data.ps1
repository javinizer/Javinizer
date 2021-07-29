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
        $contentId = (($Url -split 'id=')[1] -split '\/')[0]
        $enApiUrl = "https://www.r18.com/api/v4f/contents/$($contentId)?lang=en"
        $zhApiUrl = "https://www.r18.com/api/v4f/contents/$($contentId)?lang=zh"

        try {
            $replaceHashtable = Import-Csv -LiteralPath $UncensorCsvPath
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when import uncensor csv at path [$UncensorCsvPath]: $PSItem"
        }

        if ($Url -match 'lg=zh') {
            $Zh = $true
            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$zhApiUrl]"
                $webRequest = (Invoke-WebRequest -Uri $zhApiUrl -Method Get -Verbose:$false).Content | ConvertFrom-Json

                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$enApiUrl]"
                $altWebRequest = (Invoke-WebRequest -Uri $enApiUrl -Method Get -Verbose:$false).Content | ConvertFrom-Json

            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
            }

        } else {
            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$enApiUrl]"
                $webRequest = (Invoke-WebRequest -Uri $enApiUrl -Method Get -Verbose:$false).Content | ConvertFrom-Json
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
            }

            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$zhApiUrl]"
            $altWebRequest = (Invoke-WebRequest -Uri $zhApiUrl -Method Get -Verbose:$false).Content | ConvertFrom-Json
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
            Label         = Get-R18Label -WebRequest $webRequest -Replace $replaceHashTable
            Series        = Get-R18Series -WebRequest $webRequest -Replace $replaceHashTable
            Actress       = Get-R18Actress -WebRequest $webRequest -Url $Url -AltWebrequest $altWebRequest -Zh:$Zh
            Genre         = Get-R18Genre -WebRequest $webRequest -Replace $replaceHashTable
            CoverUrl      = Get-R18CoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-R18ScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-R18TrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
