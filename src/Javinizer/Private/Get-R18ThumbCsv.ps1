function Get-R18ThumbCsv {
    [CmdletBinding()]
    param(
        [int]$StartPage = 1,
        [int]$EndPage,
        [string]$ScriptRoot,
        [switch]$Force
    )

    begin {
        $ProgressPreference = 'SilentlyContinue'
        $csvPath = Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv'
    }

    process {
        $webRequest = Invoke-WebRequest -Uri "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=popular/page=1/" -Method Get -Verbose:$false

        if (-not ($PSBoundParameters.ContainsKey('EndPage'))) {
            $EndPage = ((($webRequest.Content -split '<li>\.\.\.<\/li>')[1] -split '<\/a><\/li>')[0] -split '>')[2]
        }

        try {
            $originalCsv = Import-Csv -LiteralPath $csvPath -ErrorAction SilentlyContinue
        } catch {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] Csv [r18-thumbs.csv] does not exist in your module root [$ScriptRoot]; Creating..."
        }

        $importVariables = @(
            'originalCsv',
            'csvPath',
            'Force'
        )

        $StartPage..$EndPage | Start-RSJob -VariablesToImport $importVariables -ScriptBlock {
            $actressBlock  = @()
            $actressObject = @()

            $webRequest  = Invoke-WebRequest "https://www.r18.com/videos/vod/movies/actress/letter=a/sort=popular/page=$_" -Verbose:$false
            $actressHtml = $webRequest.Content -split '<p><img '
            $actressHtml = $actressHtml | Where-Object { $_ -like 'src=*' }

            foreach ($actress in $actressHtml) {
                $actressBlock     = ($actress -split '<\/a>')[0]
                $actressThumbUrl  = (($actressBlock -split 'src="')[1] -split '"')[0] -replace '\.\.\.', ''
                $actressFirstName = (($actressBlock -split '<div>')[1] -split '<\/div>')[0] -replace '\.\.\.', ''
                $actressLastName  = (($actressBlock -split '<div>')[2] -split '<\/div>')[0] -replace '\.\.\.', ''

                if (-not (($originalCsv -match $actressThumbUrl) -and ($originalCsv -match $actressFirstName) -and ($originalCsv -match $actressLastName))) {
                    $actressObject += [pscustomobject]@{
                        FirstName = $actressFirstName
                        LastName  = $actressLastName
                        ThumbUrl  = $actressThumbUrl
                    }
                }
            }
            Write-Output $actressObject
        } | Wait-RSJob -ShowProgress | Receive-RSJob | Export-Csv -LiteralPath $csvPath -Force:$Force -Append -NoTypeInformation
    }
}

