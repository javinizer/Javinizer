function Update-JVThumbs {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param(
        [Parameter()]
        [System.IO.FileInfo]$Path = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'),
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Page')]
        [Int]$StartPage,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Page')]
        [Int]$EndPage
    )

    process {
        try {
            $ProgressPreference = 'SilentlyContinue'

            if (!(Test-Path -LiteralPath $Path)) {
                New-Item -Path $Path -ItemType File | Out-Null
            }

            $actressCsv = Import-Csv -LiteralPath $Path

            if ($StartPage) {
                $pageUrl = 'https://www.r18.com/videos/vod/movies/actress/letter=a/sort=new/page='
            } else {
                $pageUrl = 'https://www.r18.com/videos/vod/movies/actress/letter=a/sort=new/page='
                $StartPage = 1
                $webRequest = Invoke-WebRequest -Uri "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=popular/page=1/" -Method Get -Verbose:$false
                $EndPage = ((($webRequest.Content -split '<li>\.\.\.<\/li>')[1] -split '<\/a><\/li>')[0] -split '>')[2]
            }

            for ($x = $StartPage; $x -le $EndPage; $x++) {
                Write-Host "[$($MyInvocation.MyCommand.Name)] Scraping actress page [$x]"
                $actressObject = @()
                $actressObjectJa = @()
                $combinedActressObject = @()

                $webRequest = Invoke-WebRequest "$pageUrl$x" -Verbose:$false
                $matchedActresses = ($webRequest.Content | Select-String -Pattern '<img src="(.*)" width="135" height="135" alt="(.*)">' -AllMatches).Matches
                foreach ($match in $matchedActresses) {
                    $actressObject += [PSCustomObject]@{
                        Name     = $match.Groups[2].Value
                        ThumbUrl = $match.Groups[1].Value
                    }
                }

                $webRequestJa = Invoke-WebRequest "$pageUrl$x/?lg=zh" -Verbose:$false
                $matchedActressesJa = ($webRequestJa.Content | Select-String -Pattern '<img src="(.*)" width="135" height="135" alt="(.*)">' -AllMatches).Matches
                foreach ($match in $matchedActressesJa) {
                    $actressObjectJa += [PSCustomObject]@{
                        Name     = $match.Groups[2].Value
                        ThumbUrl = $match.Groups[1].Value
                    }
                }

                $groupedObject = ($actressObject + $actressObjectJa | Group-Object ThumbUrl) | Where-Object { $_.Count -eq 2 }
                foreach ($actress in $groupedObject) {
                    $combinedActressObject += [PSCustomObject]@{
                        LastName     = (($actress.Group[0].Name -replace '\.\.\.', '' -replace '&amp;', '&').Trim() -split ' ')[1]
                        FirstName    = (($actress.Group[0].Name -replace '\.\.\.', '' -replace '&amp;', '&').Trim() -split ' ')[0]
                        JapaneseName = ($actress.Group[1].Name).Trim() -replace '（.*）', '' -replace '&amp;', '&'
                        ThumbUrl     = $actress.Group[0].ThumbUrl -replace '&amp;', '&'
                        Alias        = $null
                    }
                }

                foreach ($actress in $combinedActressObject) {
                    if ($null -ne $actressCsv) {
                        if (!(Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actress -IncludeEqual -ExcludeDifferent -Property @('JapaneseName', 'ThumbUrl'))) {
                            $actressString = "$($actress.LastName) $($actress.FirstName)".Trim()
                            Write-JLog -Level Info -Message "[$($MyInvocation.MyCommand.Name)] [Page $x] Actress [($actressString - $($actress.JapaneseName)] written to [$Path]"
                            $actress | Export-Csv -LiteralPath $Path -Append -Encoding utf8
                        }
                    } else {
                        $actressString = "$($actress.LastName) $($actress.FirstName)".Trim()
                        Write-JLog -Level Info -Message "[$($MyInvocation.MyCommand.Name)] [Page $x] Actress [($actressString - $($actress.JapaneseName)] written to [$Path]"
                        $actress | Export-Csv -LiteralPath $Path -Append -Encoding utf8
                    }
                }
            }
        } catch {
            Write-JLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occured when updating Javinizer thumb csv at path [$Path]: $PSItem"
        }
    }
}
