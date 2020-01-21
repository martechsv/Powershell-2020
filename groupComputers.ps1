$mediaComputers = Get-ADComputer -Filter 'Name -like "MSG-MEDIA*"' | Sort-Object | Select-Object -Property Name

$engComputers = Get-ADComputer -Filter 'Name -like "MSG-ENG*"' | Sort-Object | Select-Object -Property Name

$stdComputers = Get-ADComputer -Filter 'Name -like "MSG-STD*"' | Sort-Object | Select-Object -Property Name

$oldComputers =  Get-ADComputer -Filter 'Name -notlike "MSG*" -and Name -notlike "ODRN*"' | Sort-Object | Select-Object -Property Name

$renderNodes = Get-ADComputer -Filter 'Name -like "ODRN*"' | Sort-Object | Select-Object -Property Name

Write-Output "MEDIA COMPUTERS"
$mediaComputers
Write-Output "`nENGINEERING COMPUTERS"
$engComputers
Write-Output "`nSTANDARD COMPUTERS"
$stdComputers
Write-Output "`nOLD COMPUTERS"
$oldComputers
Write-Output "`nRENDER NODES"
$renderNodes