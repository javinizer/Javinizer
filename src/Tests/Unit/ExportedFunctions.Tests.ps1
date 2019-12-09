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
Describe -Name $ModuleName -Fixture {

    $manifestContent = Test-ModuleManifest -Path $PathToManifest

    <# Context -Name 'Exported Commands' -Fixture {
        $manifestExported = ($manifestContent.ExportedFunctions).Keys
        $moduleExported = Get-Command -Module $ModuleName | Select-Object -ExpandProperty Name

        Context -Name 'Number of commands' -Fixture {
            It -Name 'Exports the same number of public funtions as what is listed in the Module Manifest' -Test {
                $manifestExported.Count | Should -BeExactly $moduleExported.Count
            }
        }

        Context -Name 'Explicitly exported commands' -Fixture {
            foreach ($command in $moduleExported) {
                It -Name "Includes the $command in the Module Manifest ExportedFunctions" -Test {
                    $manifestExported -contains $command | Should -BeTrue
                }
            }
        }
    } #>

    Context -Name 'Command Help' -Fixture {
        foreach ($command in $moduleExported) {
            Context -Name $command -Fixture {
                $help = Get-Help -Name $command -Full

                It -Name 'Includes a Synopsis' -Test {
                    $help.Synopsis | Should -Not -BeNullOrEmpty
                }

                It -Name 'Includes a Description' -Test {
                    $help.description.Text | Should -Not -BeNullOrEmpty
                }

                It -Name 'Includes at least one example' -Test {
                    $help.examples.Count | Should -BeGreaterOrEqual 1
                }
            }
        }
    }
}
