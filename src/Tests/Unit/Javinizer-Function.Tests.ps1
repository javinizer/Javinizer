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

        BeforeAll {
            function Get-Files ($fileNames) {
                $files = @()
                foreach ($file in $FileNames) {
                    $file = [PSCustomObject]@{
                        Name     = $file
                        BaseName = $file.Substring(0, $file.Length - 4)
                    }
                    $files += $file
                }
                return $files
            }
        }

        Context 'Convert-JVTitle' {
            It 'Should convert multipart ID-### accordingly' {
                $fileNames = @(
                    "bbi-094a.wmv",
                    "bbi-094-b.wmv",
                    "bbi-094 - c.wmv",
                    "bbi-094-4.wmv",
                    "bbi-094 - 1.wmv",
                    "bbi-094-02.wmv",
                    "bbi-094-003.wmv",
                    "bbi-094 - 004.wmv",
                    "bbi-094-pt1.wmv",
                    "bbi-094 - pt2.wmv",
                    "bbi-094-part3.wmv",
                    "bbi-094 - part4.wmv",
                    "bbi-094-cd1.wmv",
                    "bbi-094 - cd2.wmv",
                    "bbi00094c.wmv",
                    "bbi00094-d.wmv",
                    "bbi00094 - a.wmv",
                    "bbi00094-pt2.wmv",
                    "bbi00094 - pt3.wmv",
                    "bbi00094-cd4.wmv",
                    "bbi00094 - cd1.wmv"
                )

                $files = Get-Files $fileNames
                $results = Convert-JVTitle $files -RegexEnabled $false
                $results.ContentId | Should -Be (, "BBI00094" * $fileNames.Length)
                $results.Id | Should -Be (, "BBI-094" * $fileNames.Length)
                $results.PartNumber | Should -Be ((1..4) * [Math]::Ceiling($fileNames.Length / 4))[0..($fileNames.Length - 1)]
            }

            It 'Should work fine for ID ending in Z' {
                $fileNames = @(
                    "ibw-230z.mp4"
                )

                $files = @()
                foreach ($file in $FileNames) {
                    $file = [PSCustomObject]@{
                        Name     = $file
                        BaseName = $file.Substring(0, $file.Length - 4)
                    }
                    $files += $file
                }

                $results = Convert-JVTitle $files -RegexEnabled $false
                $results.ContentId | Should -Be ("IBW00230Z")
                $results.Id | Should -Be ("IBW-230Z")
                $results.PartNumber | Should -Be (, $null * $fileNames.Length)
            }

            It 'Should work fine for multipart ID ending in Z' {
                $fileNames = @(
                    "ibw-230za.mp4",
                    "ibw-230z-b.mp4",
                    "ibw-230z - c.mp4",
                    "ibw-230z-4.mp4",
                    "ibw-230z - 1.mp4",
                    "ibw-230z-02.mp4",
                    "ibw-230z-003.mp4",
                    "ibw-230z - 004.mp4",
                    "ibw-230z-pt1.mp4",
                    "ibw-230z - pt2.mp4",
                    "ibw-230z-part3.mp4",
                    "ibw-230z - part4.mp4",
                    "ibw-230z-cd1.mp4",
                    "ibw-230z - cd2.mp4",
                    "ibw00230zc.mp4",
                    "ibw00230z-d.mp4",
                    "ibw00230z - a.mp4",
                    "ibw00230z-pt2.mp4",
                    "ibw00230z - pt3.mp4",
                    "ibw00230z-cd4.mp4",
                    "ibw00230z - cd1.mp4"
                )

                $files = Get-Files $fileNames
                $results = Convert-JVTitle $files -RegexEnabled $false
                $results.ContentId | Should -Be (, "IBW00230Z" * $fileNames.Length)
                $results.Id | Should -Be (, "IBW-230Z" * $fileNames.Length)
                $results.PartNumber | Should -Be ((1..4) * [Math]::Ceiling($fileNames.Length / 4))[0..($fileNames.Length - 1)]
            }

            It 'Should fail for multiparts > D except Z. Numerics are OK.' {
                $fileNames = @(
                    "bbi-094f.wmv",
                    "bbi-094 - g.mp4",
                    "bbi-094-pt5.mp4"
                )

                $files = Get-Files $fileNames
                $results = Convert-JVTitle $files -RegexEnabled $false
                $results.ContentId | Should -Be (, "BBI00094" * $fileNames.Length)
                $results.Id | Should -Be (, "BBI-094" * $fileNames.Length)
                $results.PartNumber | Should -Be (6, 7, 5)
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
