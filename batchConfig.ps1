Write-Output "Retrieving list of domain computers"
$allComputers = Get-ADComputer -Filter * | Sort-Object | Select-Object -Property Name

Write-Output "Clearing folder: \\bfd\msg\it\deployment\scripts\mof"
Get-ChildItem -Path \\bfd\msg\it\deployment\scripts\mof -Include *.* -File -Recurse | foreach { $_.Delete()}

foreach ($computer in $allComputers) {
    Write-Output "Creating .mof for $($computer.name)"
    & .\applyConfig.ps1 -computername $computer.name
}

$cred = Get-Credential OBSCURA\marshall.amey
$s = New-PSSession -ComputerName OD-BASTING -Credential $cred
Invoke-Command -Session $s -ScriptBlock { New-PSDrive -Name "S" -PSProvider "FileSystem" -Root "\\bfd\msg\it\deploy\scripts" -Persist -Credential $Using:cred}
Invoke-Command -Session $s -ScriptBlock { S:\applyConfig.ps1 }