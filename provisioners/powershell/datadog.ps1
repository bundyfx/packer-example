New-Item -Path "C:\Temp" -ItemType Directory -Force

Write-Output "Downloading DataDog Agent"
Invoke-WebRequest -UseBasicParsing -Uri "https://s3.amazonaws.com/ddagent-windows-stable/ddagent-cli.msi" -OutFile "C:\Temp\ddagent-cli.msi"

Write-Output "Install the DataDog Agent"
$file = gci "C:\Temp\ddagent-cli.msi"

$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow

Write-Output "Stop the DataDog Service"
Stop-Service -Name DatadogAgent -Force

Write-Output "Disable the DataDog Service from autostarting"
Set-Service -Name DatadogAgent -StartupType Disabled

Write-Output "Clean up temporary folder"
Remove-Item -Path "C:\Temp" -Recurse -Force

