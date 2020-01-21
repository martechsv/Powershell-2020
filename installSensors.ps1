Write-Output "Installing Tenable Nessus Agent"
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\nessus\NessusAgent-7.4.3-x64.msi NESSUS_GROUPS=Workstations NESSUS_SERVER=cloud.tenable.com NESSUS_KEY=8f5a88c93059845448076e1a41b582bbebc3652b5559872de725ad60c42efe47 /L log.txt /qn'
\\bfd\msg\it\deploy\scripts\linkTenable.bat
Write-Output "Installing Carbon Black Response"
\\bfd\msg\it\installers\carbon\CarbonBlackClientSetup.exe /S | Out-Null

Write-Output "Installing Carbon Black Defense"
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\carbon\installer_vista_win7_win8-64-3.4.0.1070.msi COMPANY_CODE=XKQYSGGEWZE7VC!DZN2 /qn'


Write-Output "DONE"
Read-Host