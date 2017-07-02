New-Item -Path "C:\Temp" -ItemType Directory -Force

Write-Output "Downloading dotnetcore"
Invoke-WebRequest -UseBasicParsing -Uri "https://go.microsoft.com/fwlink/?linkid=837808" -OutFile "C:\Temp\dotnetcore.exe"

$CurrentLocation = "c:\temp"
$exe = "dotnetcore.exe"
Start-Process -FilePath $CurrentLocation\$exe -ArgumentList "/install /quiet" -wait

Write-Output "Clean up temporary folder"
Remove-Item -Path "C:\Temp" -Recurse -Force
