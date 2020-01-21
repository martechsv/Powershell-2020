<# 
This script activates Windows on a workstation using the OEM Product Key
Run this script on the target machine
In the event of an error, the OEM product key is saved to Desktop\LicenseKey.txt
Author: Marshall Amey 
#>

$computer = Get-Content env:ComputerName
$service = Get-wmiObject -query "select * from SoftwareLicensingService" -ComputerName $computer
$key = $service.OA3xOriginalProductKey

try {
    $service.InstallProductKey($key)
    $service.RefreshLicenseStatus()
}
catch {
    Write-Host "An error occurred. Key saved to desktop. Please activate manually. "
    Write-Host $_
    Write-Output $key | Out-File $HOME\Desktop\LicenseKey.txt
}


