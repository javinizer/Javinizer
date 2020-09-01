#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

function Set-JVEmbyThumbs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('emby.url')]
        [String]$Url,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Alias('emby.apikey')]
        [String]$ApiKey,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.firstnameorder')]
        [Boolean]$FirstNameOrder,

        [Parameter()]
        [System.IO.FileInfo]$ThumbCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'),

        [Parameter()]
        [Switch]$ReplaceAll
    )

    process {
        if ($Url[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $Url = $BaseUrl[0..($BaseUrl.Length - 1)] -join ''
        }

        try {
            $actressUrl = "$Url/emby/Persons/?api_key=$ApiKey"
            Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$actressUrl]"
            $embyActress = (Invoke-RestMethod -Method Get -Uri $actressUrl -ErrorAction Stop -Verbose:$false).Items | Select-Object Name, Id, ImageTags
        } catch {
            Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when getting actresses from Emby: $PSItem"
        }

        try {
            Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [ActressCsv - $ThumbCsvPath] imported"
            $actressCsv = Import-Csv -LiteralPath $ThumbCsvPath -ErrorAction Stop
        } catch {
            Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when importing thumbnail csv [$ThumbCsvPath]: $PSItem"
        }

        if ($ReplaceAll) {
            $toDoActress = $embyActress
        } else {
            $toDoActress = ($embyActress | Where-Object { $null -eq $_.ImageTags.Thumb -and $null -eq $_.ImageTags.Primary })
        }
        Write-Host "[$($MyInvocation.MyCommand.Name)] [Url - $Url] [Actress without thumbs - $($toDoActress.Count)]"
        foreach ($actress in $toDoActress) {
            $matched = $null
            $thumbUrl = $null

            if ($actress.Name -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                $actressObject = [PSCustomObject]@{
                    JapaneseName = $actress.Name
                }

                if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName')) {
                    if ($matched.Count -eq 1) {
                        $thumbUrl = $matched.ThumbUrl
                    } elseif ($matched.Count -gt 1) {
                        $thumbUrl = $matched[0].ThumbUrl
                    }
                }

            } else {
                if ($FirstNameOrder) {
                    $actressObject = [PSCustomObject]@{
                        LastName  = ($actress.Name -split ' ')[1]
                        FirstName = ($actress.name -split ' ')[0]
                    }

                    if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        if ($matched.Count -eq 1) {
                            $thumbUrl = $matched.ThumbUrl
                        } elseif ($matched.Count -gt 1) {
                            $thumbUrl = $matched[0].ThumbUrl
                        }
                    }
                } else {
                    $actressObject = [PSCustomObject]@{
                        LastName  = ($actress.Name -split ' ')[0]
                        FirstName = ($actress.name -split ' ')[1]
                    }

                    if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        if ($matched.Count -eq 1) {
                            $thumbUrl = $matched.ThumbUrl
                        } elseif ($matched.Count -gt 1) {
                            $thumbUrl = $matched[0].ThumbUrl
                        }
                    }
                }
            }

            if ($null -ne $thumbUrl) {
                Write-Debug "$thumbUrl not null"
                $thumbPostUrl = "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$ApiKey"

                try {
                    Write-JVLog -Level Debug -Message "Performing [POST] on URL [$thumbPostUrl]"
                    Invoke-RestMethod -Method Post -Uri "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$ApiKey" -ErrorAction Continue -Verbose:$false | Out-Null
                } catch {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred on [POST] on URL [$thumbPostUrl]: $PSItem" -Action 'Continue'
                }

                $primaryPostUrl = "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$ApiKey"

                try {
                    Write-JVLog -Level Debug -Message "Performing [POST] on URL [$primaryPostUrl]"
                    Invoke-RestMethod -Method Post -Uri "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$ApiKey" -ErrorAction Continue -Verbose:$false | Out-Null
                } catch {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred on [POST] on URL [$primaryPostUrl]: $PSItem" -Action 'Continue'
                }

                Write-JVLog -Level Info -Message "Set [$($actress.Name)] => [$thumbUrl]"
            }
        }
    }
}
