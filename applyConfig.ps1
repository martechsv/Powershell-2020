# \\bfd\msg\it\deploy\scripts\applyConfig.ps1
# Created 12/19/2019
# Author: Marshall Amey

#Run As Administrator
PARAM (
    [string]$computerName = $env:computername
    #[PSCredential]$Credential
)
Enable-PSRemoting -Force
# Install the required modules onto the target machine
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
Install-Module -Name ComputerManagementDsc -Force 
Install-Module -Name xWindowsUpdate -Force 
Install-Module -Name xBitlocker -Force 

Import-Module -Name ComputerManagementDsc 
Import-Module -Name xWindowsUpdate 
Import-Module -Name xBitlocker 

# Create the configuration .mof files for the target machine
. \\bfd\msg\it\deploy\scripts\configureDSC.ps1

# Apply the settings to the target machine
Set-DscLocalConfigurationManager -Path \\bfd\msg\it\deploy\scripts\mof\ -ComputerName $computerName -Verbose 
Start-DscConfiguration -Wait -Path \\bfd\msg\it\deploy\scripts\mof\ -ComputerName $computerName -Force -Verbose 

# Verify settings
timeout /t 5
Get-DscLocalConfigurationManager
Test-DscConfiguration -Detailed
pause