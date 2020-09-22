#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'Javinizer'
$PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$WarningPreference = "SilentlyContinue"
#-------------------------------------------------------------------------
#Import-Module $moduleNamePath -Force

InModuleScope 'Javinizer' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Javinizer Private Function Tests' -Tag Unit {
        Context 'Convert-JVTitle' {
            It 'Should convert multipart ID-### accordingly' {
                $fileNames = @(
                    "bbi-094a.wmv",
                    "bbi-094-b.wmv",
                    "bbi-094 - c.wmv",
                    "bbi-094-4.wmv",
                    "bbi-094 - 5.wmv",
                    "bbi-094-06.wmv",
                    "bbi-094-007.wmv",
                    "bbi-094 - 008.wmv",
                    "bbi-094-pt9.wmv",
                    "bbi-094 - pt10.wmv",
                    "bbi-094-part11.wmv",
                    "bbi-094 - part12.wmv",
                    "bbi-094-cd13.wmv",
                    "bbi-094 - cd14.wmv",
                    "bbi00094o.wmv",
                    "bbi00094-p.wmv",
                    "bbi00094 - q.wmv",
                    "bbi00094-pt18.wmv",
                    "bbi00094 - pt19.wmv",
                    "bbi00094-cd20.wmv",
                    "bbi00094 - cd21.wmv"
                )

                Mock Get-ChildItem {
                    $files = @()
                    foreach($file in $fileNames) {
                        $file = [PSCustomObject]@{
                            Name = $file
                            BaseName = $file.Substring(0, $file.Length - 4)
                        }
                        $files += $file
                    }
                    return $files
                }

                $files = Get-ChildItem
                $results = Convert-JVTitle $files -RegexEnabled $false
                $results.ContentId | Should -Be (,"BBI00094" * $fileNames.Length)
                $results.Id | Should -Be (,"BBI-094" * $fileNames.Length)
                $results.PartNumber | Should -Be (1..$fileNames.Length)
            }
        }

    }#describe_PrivateFunctions
    Describe 'Javinizer Public Function Tests' -Tag Unit {
        Context 'FunctionName' {
            <#
                It 'should ...' {

                }#it
                #>
        }#context_FunctionName
    }#describe_testFunctions
}#inModule
