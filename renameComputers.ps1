$comps = @{
    'MSG-MEDIA-ST01'='OD-HONEYCOMB'
    'MSG-MEDIA-ST02'='OD-OVERLOCK'
    'MSG-MEDIA-ST03'='OD-RUNNING'
    'MSG-MEDIA-ST04'='OD-DOUBLEACTION'
    'MSG-MEDIA-ST05'='OD-BACKTACK'
    'MSG-MEDIA-ST06'='OD-BASTING'
    'MSG-MEDIA-ST07'='OD-BUTTONHOLE'
    'MSG-MEDIA-ST08'='OD-FEATHER'
    'MSG-MEDIA-ST09'='OD-DARNING'
    'MSG-MEDIA-ST10'='OD-ZIGZAG'
    'MSG-MEDIA-ST11'='OD-SAILMAKER'
    'MSG-MEDIA-ST12'='OD-SHELLTUCK'
    'MSG-MEDIA-ST13'='OD-TOPSTITCH'
    'MSG-MEDIA-ST14'='OD-STOATING'
    'MSG-MEDIA-ST15'='OD-TWINNEEDLE'
    'MSG-MEDIA-ST16'='OD-WHIPSTITCH'
    'MSG-MEDIA-ST17'='OD-BLINDHEM'
    'MSG-MEDIA-ST18'='OD-OVERCAST'
}

# CREATE SECURE CREDENTIALS
$encrypted = Get-Content $HOME\Desktop\EncryptedPassword.txt | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PsCredential("OBSCURA\marshall.amey", $encrypted)

# RENAME ALL STITCHING COMPUTERS
foreach($oldName in $comps.Keys) { 
    $newName = $comps[$oldName]
    if ( [bool](Test-WSMan -ComputerName $oldName -ErrorAction SilentlyContinue) ) {
        Write-Output "$oldName to $newName"

        try {
            Invoke-Command -ComputerName $oldName -Credential $creds -ScriptBlock { 
                Rename-Computer -NewName $args[0] -DomainCredential $args[1] -Force -PassThru 
            } -ArgumentList $newName, $creds
        }
        catch {
            Write-Output "Could not invoke command to $oldName"
            Add-Content $HOME\Desktop\RenameErrors.txt "Could not invoke command to $oldName"
        }
        
    } else {
        Write-Output "Could not connect to $oldName"
        Add-Content $HOME\Desktop\RenameErrors.txt "Could not connect to $oldName"
    }
}