<#
Must be ran as administrator on the target machine.  
This script enables remote management and sets DSC configurations
#>

Write-Output 'TURNING OFF WINDOWS FIREWALL WHEN DOMAIN JOINED'
Set-NetFirewallProfile -Profile Domain -Enabled False

Write-Output 'ENABLING REMOTE MANAGEMENT'
Enable-PSRemoting -Force

Write-Output 'TURNING OFF HIBERNATION'
powercfg.exe /hibernate off

Write-Output 'ENABLING REMOTE SYMLINKS'
fsutil behavior set SymLinkEvaluation R2R:1 R2L:1

Write-Output 'ENABLING BITLOCKER'
Enable-BitLocker -MountPoint C -EncryptionMethod XtsAes256 -TpmProtector -UsedSpaceOnly