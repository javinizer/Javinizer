function Set-JVEmbyThumbs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('emby.url')]
        [String]$Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('emby.apikey')]
        [String]$ApiKey,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.firstnameorder')]
        [Boolean]$FirstNameOrder,

        [Parameter()]
        [System.IO.FileInfo]$Path = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv')
    )

    process {
        try {
            $actressUrl = "$Url/emby/Persons/?api_key=$ApiKey"
            Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$actressUrl]"
            $embyActresses = (Invoke-RestMethod -Method Get -Uri "$Url/emby/Persons/?api_key=$ApiKey" -ErrorAction Stop -Verbose:$false).Items | Select-Object Name, Id, ImageTags
        } catch {
            Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when getting actresses from Emby: $PSItem"
        }

        try {
            $actressCsv = Import-Csv -LiteralPath $Path -ErrorAction Stop
        } catch {
            Write-JVLog -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing thumbnail csv [$genreCsvPath]: $PSItem"
        }


        foreach ($actress in ($embyActresses | Where-Object { $null -eq $_.ImageTags })) {
            if ($actress.Name -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                $actressObject = [PSCustomObject]@{
                    JapaneseName = $actress.Name
                }

                if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName')) {
                    if ($matchedCount -eq 1) {
                        $thumbUrl = $matched.ThumbUrl
                    } elseif ($matchedCount -gt 1) {
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
                        if ($matchedCount -eq 1) {
                            $thumbUrl = $matched.ThumbUrl
                        } elseif ($matchedCount -gt 1) {
                            $thumbUrl = $matched[0].ThumbUrl
                        }
                    }
                } else {
                    $actressObject = [PSCustomObject]@{
                        LastName  = ($actress.Name -split ' ')[0]
                        FirstName = ($actress.name -split ' ')[1]
                    }

                    if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        if ($matchedCount -eq 1) {
                            $thumbUrl = $matched.ThumbUrl
                        } elseif ($matchedCount -gt 1) {
                            $thumbUrl = $matched[0].ThumbUrl
                        }
                    }
                }
            }

            if ($null -ne $thumbUrl) {
                $thumbPostUrl = "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$ApiKey"

                try {
                    Write-JVLog -Level Debug -Message "Performing [POST] on URL [$thumbPostUrl]"
                    Invoke-RestMethod -Method Post -Uri "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$ApiKey" -ErrorAction Continue -Verbose:$false
                } catch {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred on [POST] on URL [$thumbPostUrl]: $PSItem" -Action 'Continue'
                }

                $primaryPostUrl = "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$ApiKey"

                try {
                    Write-JVLog -Level Debug -Message "Performing [POST] on URL [$primaryPostUrl]"
                    Invoke-RestMethod -Method Post -Uri "$Url/emby/Items/$($actress.Id)/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$ApiKey" -ErrorAction Continue -Verbose:$false
                } catch {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred on [POST] on URL [$primaryPostUrl]: $PSItem" -Action 'Continue'
                }

                Write-JVLog -Level Info -Message "Set [$($actress.Name)] => [$thumbUrl]"
            }
        }
    }
}
