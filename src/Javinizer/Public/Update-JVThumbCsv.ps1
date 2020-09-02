#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

function Update-JVThumbCsv {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param(
        [Parameter()]
        [System.IO.FileInfo]$ThumbCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'),

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Page')]
        [Int]$StartPage,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Page')]
        [Int]$EndPage
    )

    process {
        try {
            $ProgressPreference = 'SilentlyContinue'

            if (!(Test-Path -LiteralPath $ThumbCsvPath)) {
                New-Item -Path $ThumbCsvPath -ItemType File | Out-Null
            }

            $actressCsv = Import-Csv -LiteralPath $ThumbCsvPath
            $pageUrl = 'https://www.r18.com/videos/vod/movies/actress/letter=a/sort=new/page='
            $webRequest = Invoke-WebRequest -Uri "$($pageUrl)1" -Method Get -Verbose:$false
            $lastPage = ((($webRequest.Content -split '<li>\.\.\.<\/li>')[1] -split '<\/a><\/li>')[0] -split '>')[2]

            if ($StartPage -eq '' -or $null -eq $StartPage) {
                $StartPage = 1
            }

            if ($EndPage -eq '' -or $null -eq $EndPage) {
                $EndPage = $lastPage
            }

            if ($EndPage -gt $lastPage) {
                $EndPage = $LastPage
            }

            Write-Host "[$($MyInvocation.MyCommand.Name)] [Path - $ThumbCsvPath] [Total Pages - $lastPage] [Scraping - $StartPage => $EndPage]"

            for ($x = $StartPage; $x -le $EndPage; $x++) {
                Write-Host "[$x of $EndPage] Scraping page [$x]"
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
                        FullName     = "$((($actress.Group[0].Name -replace '\.\.\.', '' -replace '&amp;', '&').Trim() -split ' ')[1]) $((($actress.Group[0].Name -replace '\.\.\.', '' -replace '&amp;', '&').Trim() -split ' ')[0])".Trim()
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
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[Page $x] Actress [$actressString - $($actress.JapaneseName)] written to thumb csv"
                            $actress | Export-Csv -LiteralPath $ThumbCsvPath -Append -Encoding utf8
                        }
                    } else {
                        $actressString = "$($actress.LastName) $($actress.FirstName)".Trim()
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[Page $x] Actress [$actressString - $($actress.JapaneseName)] written to thumb csv"
                        $actress | Export-Csv -LiteralPath $ThumbCsvPath -Append -Encoding utf8
                    }
                }
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occured when updating Javinizer thumb csv at path [$ThumbCsvPath]: $PSItem"
        }
    }
}
