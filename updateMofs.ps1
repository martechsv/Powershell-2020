$allComputers =  Get-ADComputer -Filter * | Sort-Object
foreach ($comp in $allComputers) {
    \\bfd\msg\it\deploy\scripts\configureDSC.ps1 -computerName $comp['Name']
} 