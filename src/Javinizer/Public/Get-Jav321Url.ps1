function Get-Jav321Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://jp.jav321.com/search"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Post -Body "sn=$Id" -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
        }

        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match '/video/') {
            try {
                $resultObject = [PSCustomObject]@{
                    Id    = Get-Jav321Id -Webrequest $webRequest.Content
                    Title = Get-Jav321Title -Webrequest $webRequest.Content
                    Url   = $searchResultUrl
                }
            } catch {
                # Do nothing
            }
        } else {
            $rawResults = ($webrequest.links | Where-Object { $_.href -like '*video*' })
            $resultObject = $rawResults | ForEach-Object {
                [PSCustomObject]@{
                    Id    = ((($_.outerHTML -split '<br>')[1] -split '<\/a>')[0] -replace '<span class="glyphicon glyphicon-download"></span>' -split ' ')[-1]
                    Title = (($_.outerHTML -split '<br>')[1] -split '<\/a>')[0] -replace '<span class="glyphicon glyphicon-download"></span>'
                    Url   = "https://jp.jav321.com" + (($_.outerHTML -split '<a href="')[1] -split '">')[0]
                }
            }
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            # If we have more than one exact match, select the first option
            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    Ja    = $entry.Url
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Search [$Id] not matched on Jav321"
            return
        }
    }
}
