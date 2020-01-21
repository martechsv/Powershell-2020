<# Set and encrypt credentials to file using default method #>

$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content $HOME\Desktop\EncryptedPassword.txt