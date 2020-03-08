function Test-RequiredMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [Parameter(Mandatory = $true, Position = 1)]
        [object]$Settings
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
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
            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Skipped: [$($DataObject.Search)] $errors missing fields: [$nullFields]"
            Write-Log -Log $logPath -Level WARN -Text "Skipped: [$($DataObject.Search)] $errors missing fields: [$nullFields]" -UseMutex
            return
        }
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

