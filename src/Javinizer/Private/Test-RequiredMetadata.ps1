function Test-RequiredMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [Parameter(Mandatory = $true, Position = 1)]
        [object]$Settings
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $errors = 0
    }

    process {
        $requiredFields = Convert-CommaDelimitedString -String $Settings.Metadata.'required-metadata-fields'
        if ($null -ne $requiredFields) {
            foreach ($field in $requiredFields) {
                if ($null -eq $DataObject.($field)) {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] [$($DataObject.Search)] Required field: [$field] is null"
                    $errors++
                }
            }
        }

        if ($errors -eq 0) {
            Write-Output $DataObject
        } else {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] [$($DataObject.Search)] Skipped with missing fields: [$errors]"
            return
        }
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

