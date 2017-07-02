<powershell>
winrm quickconfig -q

winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'

$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

$connections | ForEach-Object {
    Write-Output $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory()
    $_.GetNetwork().SetCategory(1)
    Write-Output $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory()
}

Restart-Service -Name WinRM
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1' -UseBasicParsing -Outfile $env:TEMP\ConfigureRemotingForAnsible.ps1

. "$($env:TEMP)\ConfigureRemotingForAnsible.ps1" -CertValidityDays 3650
</powershell>
