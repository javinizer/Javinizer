function Get-Jav321Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-RestMethod -Uri $Url -Verbose:$false
        } catch {
            Write-JVLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source          = 'jav321'
            Url             = $Url
            Id              = Get-Jav321Id -WebRequest $webRequest
            Title           = Get-Jav321Title -WebRequest $webRequest
            ReleaseDate     = Get-Jav321ReleaseDate -WebRequest $webRequest
            ReleaseYear     = Get-Jav321ReleaseYear -WebRequest $webRequest
            Runtime         = Get-Jav321Runtime -WebRequest $webRequest
            Maker           = Get-Jav321Maker -WebRequest $webRequest
            Actress         = (Get-Jav321Actress -WebRequest $webRequest).Name
            ActressThumbUrl = (Get-Jav321Actress -WebRequest $webRequest).ThumbUrl
            Genre           = Get-Jav321Genre -WebRequest $webRequest
            CoverUrl        = Get-Jav321CoverUrl -WebRequest $webRequest
            ScreenshotUrl   = Get-Jav321ScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Level Debug -Message "Jav321 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
