PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""\\bfd\msg\it\deploy\scripts\applyConfig.ps1""' -Verb RunAs}"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""\\bfd\msg\it\deploy\scripts\installSoftware.ps1""' -Verb RunAs}"
pause
