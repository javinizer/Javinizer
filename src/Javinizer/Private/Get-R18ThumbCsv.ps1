function Get-R18ThumbCsv {
    [CmdletBinding()]
    param(
        [int]$NewPages,
        [string]$ScriptRoot,
        [switch]$Force
    )

    begin {
        $ProgressPreference = 'SilentlyContinue'
        $csvPath = Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv'
        $actressCheck = @()
        $actressObject = @()
        Write-Host "[$($MyInvocation.MyCommand.Name)] Updating R18 thumbnail csv located at [$csvPath]"
    }

    process {
        try {
            $webRequest = Invoke-WebRequest -Uri "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=popular/page=1/" -Method Get -Verbose:$false
            $EndPage = ((($webRequest.Content -split '<li>\.\.\.<\/li>')[1] -split '<\/a><\/li>')[0] -split '>')[2]
            if (-not ($PSBoundParameters.ContainsKey('NewPages'))) {
                $NewPages = $EndPage
            }

            Write-Host "[$($MyInvocation.MyCommand.Name)] Scraping [$NewPages] of [$EndPage] actress pages on R18.com"

            try {
                $originalCsv = Import-Csv -LiteralPath $csvPath -ErrorAction SilentlyContinue
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Csv [r18-thumbs.csv] does not exist in your module root [$ScriptRoot]; Creating..."
                New-Item -Path $csvPath -Force:$Force | Out-Null
            }

            $importVariables = @(
                'originalCsv',
                'csvPath',
                'Force',
                'NewPages'
            )

            if ($PSBoundParameters.ContainsKey('NewPages')) {
                1..$NewPages | Start-RSJob -VariablesToImport $importVariables -ScriptBlock {
                    $actressBlock = @()
                    $actressObject = @()

                    $webRequest = Invoke-WebRequest "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=new/page=$_" -Verbose:$false
                    $actressHtml = $webRequest.Content -split '<p><img '
                    $actressHtml = $actressHtml | Where-Object { $_ -like 'src=*' }

                    foreach ($actress in $actressHtml) {
                        $actressBlock = ($actress -split '<\/a>')[0]
                        $actressThumbUrl = ((($actressBlock -split 'src="')[1] -split '"')[0] -replace '\.\.\.', '') -replace '\\', ''
                        $actressFirstName = ((($actressBlock -split '<div>')[1] -split '<\/div>')[0] -replace '\.\.\.', '') -replace '\\', ''
                        $actressLastName = ((($actressBlock -split '<div>')[2] -split '<\/div>')[0] -replace '\.\.\.', '') -replace '\\', ''
                        $actressFullName = $ActressFirstName + ' ' + $actressLastName

                        if (-not ($originalCsv -match $actressFullName)) {
                            $actressObject += [pscustomobject]@{
                                FirstName = $actressFirstName.Trim()
                                LastName  = $actressLastName.Trim()
                                FullName  = $actressFullName.Trim()
                                ThumbUrl  = $actressThumbUrl
                            }
                        }
                    }
                    Write-Output $actressObject
                } | Wait-RSJob -ShowProgress | Receive-RSJob | Export-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs-temp.csv') -Append
            } else {
                if (Test-Path -LiteralPath $csvPath) {
                    $selection = Display-ConfirmMessage -Message "R18 actress thumbnail database [$csvPath] already exists`nAre you sure you want to do a full scrape?" -Default 'N'
                }

                if ($selection -eq 'y') {

                    1..$NewPages | Start-RSJob -VariablesToImport $importVariables -ScriptBlock {
                        $actressBlock = @()
                        $actressObject = @()

                        $webRequest = Invoke-WebRequest "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=popular/page=$_" -Verbose:$false
                        $actressHtml = $webRequest.Content -split '<p><img '
                        $actressHtml = $actressHtml | Where-Object { $_ -like 'src=*' }

                        foreach ($actress in $actressHtml) {
                            $actressBlock = ($actress -split '<\/a>')[0]
                            $actressThumbUrl = ((($actressBlock -split 'src="')[1] -split '"')[0] -replace '\.\.\.', '') -replace '\\', ''
                            $actressFirstName = ((($actressBlock -split '<div>')[1] -split '<\/div>')[0] -replace '\.\.\.', '') -replace '\\', ''
                            $actressLastName = ((($actressBlock -split '<div>')[2] -split '<\/div>')[0] -replace '\.\.\.', '') -replace '\\', ''
                            $actressFullName = $ActressFirstName + ' ' + $actressLastName

                            if (-not ($originalCsv -match $actressFullName)) {
                                $actressObject += [pscustomobject]@{
                                    FirstName = $actressFirstName.Trim()
                                    LastName  = $actressLastName.Trim()
                                    FullName  = $actressFullName.Trim()
                                    ThumbUrl  = $actressThumbUrl
                                }
                            }
                        }
                        Write-Output $actressObject
                    } | Wait-RSJob -ShowProgress | Receive-RSJob | Export-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs-temp.csv') -Append -Force:$Force
                } else {
                    return
                }
            }

            $scrapedActresses = Import-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs-temp.csv')
            foreach ($actress in $scrapedActresses) {
                if ($originalCsv.FullName -like $actress.FullName) {
                    # Skip actress if 'FullName' already exists in existing csv
                } else {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($actress.FullName)] written to [$csvPath]"
                    if ($actressCheck.FullName -like $actress.FullName) {
                        # Skip actress if actress with identical 'FullName' already written in current session
                    } else {
                        $actress | Export-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv') -Append -Force:$Force
                        $actressCheck += $actress
                    }
                }
            }

        } catch {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] Ran into errors while scraping r18 actresses"
            throw $_
        } finally {
            Remove-Item -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs-temp.csv') -ErrorAction SilentlyContinue
        }
    }
}

# Alternative method which is much slower
# Reads the existing csv every time it is written
<# ForEach-Object {
            $originalCsv = Import-Csv -LiteralPath $csvPath -ErrorAction SilentlyContinue
            if ($originalCsv.FullName -like $_.FullName) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($_.FullName)] SKIPPED--------------------"
                # Skip actress if already fullname already matched
            } else {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($_.FullName)] written to [$csvPath]"
                $_ | Export-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv') -Force -Append
            }
        }
    } #>
