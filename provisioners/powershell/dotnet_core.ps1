New-Item -Path "C:\Temp" -ItemType Directory -Force

Write-Output "Downloading dotnetcore"
Invoke-WebRequest -UseBasicParsing -Uri "https://go.microsoft.com/fwlink/?linkid=837808" -OutFile "C:\Temp\dotnetcore.exe"

Write-Output "Installing dotnetcore"
. C:\Temp\dotnetcore.exe -ArgumentList "/install /quiet"

Write-Output "Clean up temporary folder"
Remove-Item -Path "C:\Temp" -Recurse -Force
