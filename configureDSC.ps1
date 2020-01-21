<#
\\bfd\msg\it\deploy\scripts\applyConfig.ps1
Created 12/19/2019
Author: Marshall Amey

## Run As Administrator

This script configures the LCM and DSC settings for a machine.

CURRENT LCM CONFIGURATION:
The machine is checked every 30 minutes. Changes made by a user 
that drift from desired configuration state are auto-corrected.

CURRENT DSC CONFIGURATION:
-Disable Local Administrator account
-Set environment variables
-Join obscura domain
-Disable Windows firewall when domain joined
-Enable Network Discovery and File sharing
-Set Execution Policy to RemoteSigned
-Enable Remote Symlinks
-Install Powershell 7
-Create desktop shortcut to MSG Console
-Create Start menu link to MSG console
-Enable bitLocker
-Enable Powershell remoting
-Add Domain Admins to Local Administrators

TODO: Turn off hibernation for artist machines
This script only updates the .mof file used to apply the current settings.
Only run this script if these settings need to be changed.
#>

PARAM (
    [string]$computerName = $env:computername
    #[PSCredential]$Credential
)

[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node $computerName
    {
        Settings
        {
            RefreshMode = 'Push'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 30
        }
    }
}


configuration MSG_Config 
{
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module xBitlocker
    #Import-DscResource -Module xWindowsUpdate

    Node $computerName 
    {
        #1 Disable local administrator account
        User Administrator 
        {
            Ensure = "Present" 
            UserName = "Administrator"
            Disabled = $True
        } 
	
	    #2 Setup MSG_SOFT_ROOT
        Script SetEnvironmentVariables
        {
            GetScript = {
                @{ Result = [System.Environment]::GetEnvironmentVariable('MSG_SOFT_ROOT', [System.EnvironmentVariableTarget]::Machine) }
            }
            SetScript = {
		        [System.Environment]::SetEnvironmentVariable('MSG_SOFT_ROOT', '\\silo\msgsoft', [System.EnvironmentVariableTarget]::Machine)
            }
            TestScript = {
                $VariableSet = [System.Environment]::GetEnvironmentVariable('MSG_SOFT_ROOT', [System.EnvironmentVariableTarget]::Machine) -eq '\\silo\msgsoft'
                $VariableSet -eq $True
            }
        }

	#3 Join Domain
        Script JoinDomain
        {
            GetScript = {
                @{ Result = (Get-CimInstance Win32_ComputerSystem).Domain } 
            }
            SetScript = {
		        Add-Computer -DomainName obscura.od.dom
            }
            TestScript = {
                $DomainJoined = (Get-CimInstance Win32_ComputerSystem).Domain -eq 'obscura.od.dom'
                $DomainJoined -eq $True
            }
        }


        #4 Firewall and Sharing Settings
        Script DisableFirewall 
        {
            GetScript = {
                @{
                    Result = (Get-NetFirewallProfile -Name Domain).enabled -eq 'False' `
                    -and (Get-NetFirewallProfile -Name Public,Private).enabled -eq 'True' `
                    -and (Get-NetFirewallRule -AssociatedNetFirewallProfile "Get-NetFirewallProfile -Name Domain" -DisplayGroup "Network Discovery").enabled.contains('True') `
                    -and (Get-NetFirewallRule -AssociatedNetFirewallProfile Domain -DisplayGroup "File And Printer Sharing").enabled.contains('True')
                }
            }
            SetScript = {
		        Set-NetFirewallProfile -Profile Public,Private -Enabled True -Verbose;
                Set-NetFirewallProfile -Profile Domain -Enabled False -Verbose;
		        Get-NetFirewallRule -DisplayGroup 'Network Discovery'|Set-NetFirewallRule -Profile 'Domain' -Enabled true -PassThru|select Name,DisplayName,Enabled,Profile|ft -a;
		        Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing'|Set-NetFirewallRule -Profile 'Domain' -Enabled true -PassThru|select Name,DisplayName,Enabled,Profile|ft -a
            }
            TestScript = {
                $FirewallDisabled = (Get-NetFirewallProfile -Name Domain).enabled -eq 'False' `
                -and (Get-NetFirewallProfile -Name Public,Private).enabled -eq 'True' `
                -and !(Get-NetFirewallRule -DisplayGroup 'Network Discovery').enabled.contains('False') `
                -and !(Get-NetFirewallRule -DisplayGroup 'File And Printer Sharing').enabled.contains('False')
                $FirewallDisabled -eq $True
            }
        }


	#5 Set Execution Policy
        Script SetExecutionPolicy
        {  
            GetScript = {
                @{ Result = (Get-ExecutionPolicy) }
            }
            SetScript = {
		        Set-ExecutionPolicy RemoteSigned -Force
            }
            TestScript = {
                $PolicySet = (Get-ExecutionPolicy) -eq 'RemoteSigned'
                $PolicySet -eq $True
            }
        }


        #6 Enable remote symbolic links
        Script EnableSymlinks
        {  
            GetScript = {
                @{
                    $symlinks = fsutil behavior query SymLinkEvaluation
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = -not($symlinks[2].contains('disabled')) -and -not($symlinks[3].contains('disabled'))
                }
            }
            SetScript = {
                fsutil behavior set SymLinkEvaluation R2L:1 R2R:1
            }
            TestScript = {
                $symlinks = fsutil behavior query SymLinkEvaluation
                $SymLinksEnabled = -not($symlinks[2].contains('disabled')) -and -not($symlinks[3].contains('disabled'))
                $SymLinksEnabled -eq $True
            }
        }


    #11 Enable PSRemoting
    Script EnablePSRemoting 
    {
        GetScript = {
            @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Result = [bool](Test-WSMan -ComputerName $computerName -ErrorAction SilentlyContinue)
            }
        }
        SetScript = {
            Enable-PSRemoting
        }
        TestScript = {
            $Enabled = [bool](Test-WSMan -ComputerName $computerName -ErrorAction SilentlyContinue)
            $Enabled -eq $True
        }
    }
    



        #10 Enable Bitlocker
	    #TODO: Add all drives
        Script EnableBitlocker 
        {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = (get-tpm).tpmPresent -eq $false -or 'FullyDecrypted' -notin (Get-BitLockerVolume -MountPoint C).VolumeStatus
                }
            }
            SetScript = {
                $BLV = Get-BitLockerVolume -MountPoint C
                if ($BLV.KeyProtector[0].KeyProtectorId) {
                    Remove-BitLockerKeyProtector -MountPoint C -keyProtectorID $BLV.KeyProtector[0].KeyProtectorId
                }
                Enable-BitLocker -MountPoint C -EncryptionMethod XtsAes256 -TpmProtector -UsedSpaceOnly
            }
            TestScript = {
                $Encrypted = (get-tpm).tpmPresent -eq $false -or 'FullyDecrypted' -notin (Get-BitLockerVolume -MountPoint C).VolumeStatus
                $Encrypted -eq $True
            }
        }


	


	#12 Add Domain admins as Local Admins
        Script AddDomainAdmins
        {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = (Get-LocalGroupMember -Group Administrators).name -contains 'OBSCURA\Domain Admins'
                }
            }
            SetScript = {
		        Add-LocalGroupMember -Group Administrators -Member 'OBSCURA\Domain Admins'
            }
            TestScript = {
                $AdminsAdded = (Get-LocalGroupMember -Group Administrators).name -contains 'OBSCURA\Domain Admins'
                $AdminsAdded -eq $True
            }
        }

    
    #7 Install PowerShell 7
        Script PowerShell7
        {  
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = (Get-CimInstance Win32_Product).name.contains('PowerShell 7-preview-x64')
                }
            }
            SetScript = {
                try {
                    $url = "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0-preview.6/PowerShell-7.0.0-preview.6-win-x64.msi"
                    $msi = "$env:TEMP\$(split-path $url -Leaf)"
                    $client = New-Object System.Net.WebClient
                    $client.DownloadFile($url, $msi)
                    Start-Process -FilePath msiexec.exe -Wait -ArgumentList "/i $msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1"
                }
                catch {
                    Start-Sleep -s 3
                }
            }
            TestScript = {
                $PowerShellInstalled = (Get-CimInstance Win32_Product).name.contains('PowerShell 7-preview-x64')
                $PowerShellInstalled -eq $True
            }
        }

	#8 Add MSG Console shortcut to Start > MSG
        Script ConsoleStartMenu
        {  
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = Test-Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MSG\MSG Console.lnk'
                }
            }
            SetScript = {
                mkdir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MSG" -Force
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MSG\MSG Console.lnk")
                $Shortcut.TargetPath = "C:\Program Files\PowerShell\7-preview\pwsh.exe"
                # TODO: Next line will be - $Shortcut.Arguments = '-NoExit -WorkingDirectory ~ -File "$env:MSG_SOFT_ROOT\bin\msgsoft\Setup-MSGConsole.ps1"'
                $Shortcut.Arguments = '-NoExit -WorkingDirectory ~ -File "\\od-userassets\ODUsers\david.lenihan\2019\PowerShell\msgsoft\bin\Utilities\Initialize-MSGConsole.ps1"'
                $Shortcut.Save()
                # TODO: Can we put this in MSG_SOFT_ROOT\shortcuts and just copy .lnk?
            }
            TestScript = {
                $ShortcutCreated = Test-Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MSG\MSG Console.lnk'
                $ShortcutCreated -eq $True
            }
        }

	#9 Add MSG Console shortcut to public desktop
        Script ConsoleDesktop
        {  
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = Test-Path 'C:\Users\Public\Desktop\MSG Console.lnk'
                }
            }
            SetScript = {
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\MSG Console.lnk")
                $Shortcut.TargetPath = "C:\Program Files\PowerShell\7-preview\pwsh.exe"
                # TODO: Next line will be - $Shortcut.Arguments = '-NoExit -WorkingDirectory ~ -File "$env:MSG_SOFT_ROOT\bin\msgsoft\Setup-MSGConsole.ps1"'
                $Shortcut.Arguments = '-NoExit -WorkingDirectory ~ -File "\\od-userassets\ODUsers\david.lenihan\2019\PowerShell\msgsoft\bin\Utilities\Initialize-MSGConsole.ps1"'
                $Shortcut.Save()
                # TODO: Can we put this in MSG_SOFT_ROOT\shortcuts and just copy .lnk?
            }
            TestScript = {
                $ShortcutCreated = Test-Path 'C:\Users\Public\Desktop\MSG Console.lnk'
                $ShortcutCreated -eq $True
            }
        }


 
    
    #TODO: Add conditional configs
    # if     ( $compName -like "OD-*" )      { Perform stitching install }
    # elseif ( $compName -like "MSG-ENG*" )  { Perform software install }
    # elseif ( $compName -like "MSG-STD*")   { Perform standard install }
    # elseif ( $compName -like "ODRN*" )     { Perform render node install }
    # else   { "Cannot recognize computer name.  Make sure this machine has the proper naming convention" }
    #Write-Output 'TURNING OFF HIBERNATION'
    #powercfg.exe /hibernate off

            # Perform Security and Important Updates
            # xWindowsUpdateAgent MuSecurityImportant
            # {
            #     IsSingleInstance = 'Yes'
            #     UpdateNow        = $true
            #     Category         = @('Security','Important')
            #     Source           = 'MicrosoftUpdate'
            #     Notifications    = 'Disabled'
            # }

    }    

}

LCMConfig -OutputPath \\bfd\msg\it\deploy\scripts\mof
MSG_Config -OutputPath \\bfd\msg\it\deploy\scripts\mof