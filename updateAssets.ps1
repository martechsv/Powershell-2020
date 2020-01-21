$count = 0
$list  = @()

$allComputers =  Get-ADComputer -Filter * | Sort-Object
$allComputers | ForEach-Object {
    $comp = Get-ADComputer -Identity $_.Name -Properties IPv4Address
    $list += [pscustomobject]@{      
        Name = $($comp.Name)
        IPv4Address = $($comp.IPv4Address)
        DistinguishedName = $($comp.DistinguishedName)
        DNSHostName = $($comp.DNSHostName)
    }
    $count = $count+1
    

} 
$list | Export-CSV -Path \\bfd\msg\it\deploy\allDCComputers.csv -NoTypeInformation
Write-Output "There are $count computers in the domain" 
