function Test-RequiredMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [Parameter(Mandatory = $true, Position = 1)]
        [object]$Settings
    )

    begin {
        Write-JLog -Level Debug -Message "Function started"
        $nullFields = @()
        $errors = 0
    }

    process {
        $requiredFields = Convert-CommaDelimitedString -String $Settings.Metadata.'required-metadata-fields'
        if ($null -ne $requiredFields) {
            foreach ($field in $requiredFields) {
                if ($null -eq $DataObject.($field) -or $DataObject.($field) -eq '') {
                    $nullFields += $field
                    $errors++
                }
            }
            $nullFields = $nullFields -join ', '
        }

        if ($errors -eq 0) {
            Write-Output $DataObject
        } else {
            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Skipped: [$($DataObject.OriginalFileName)] $errors null required fields: [$nullFields]"
            Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFullName -Text "Skipped: [$($DataObject.OriginalFileName)] $errors null required fields: [$nullFields]"
            continue
        }
    }

    end {
        Write-JLog -Level Debug -Message "Function ended"
    }
}
