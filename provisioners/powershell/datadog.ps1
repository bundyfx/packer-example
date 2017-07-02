<#
.Synopsis
   Allows running processes and capturing output.
.DESCRIPTION
   Allows running processes and capturing output.
.EXAMPLE
   Start-ProcessWithCapture -FilePath 'git' -ArgumentList 'pull' -WorkingDirectory $Path -ErrorAction Stop
#>
function Start-ProcessWithCapture
{
    [CmdletBinding()]
    Param
    (
        # File Path of the Process to Execute
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,

        # Argument List for Process
        [Parameter(Mandatory=$true)]
        [string]
        $ArgumentList,

        # Argument List for Process
        [Parameter(Mandatory=$false)]
        [string]
        $WorkingDirectory
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo

    if ($PSBoundParameters.ContainsKey('WorkingDirectory'))
    {
        $pinfo.WorkingDirectory = $WorkingDirectory
    }

    $pinfo.FileName = $FilePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()

    $output = @{}
    $output.stdout = $stdout
    $output.stderr = $stderr
    $output.exitcode = $p.ExitCode

    return $output
}

New-Item -Path "C:\Temp" -ItemType Directory -Force

Write-Output "Downloading DataDog Agent"
Invoke-WebRequest -UseBasicParsing -Uri "https://s3.amazonaws.com/ddagent-windows-stable/ddagent-cli.msi" -OutFile "C:\Temp\ddagent-cli.msi"

Write-Output "Install the DataDog Agent"

$out = Start-ProcessWithCapture -FilePath msiexec -ArgumentList "/qn /i C:\Temp\ddagent-cli.msi"

Write-Output "Wait for DataDog serivce to start"
Start-Sleep -Seconds 15

Write-Output "Stop the DataDog Service"
Stop-Service -Name DatadogAgent -Force

Write-Output "Disable the DataDog Service from autostarting"
Set-Service -Name DatadogAgent -StartupType Disabled

Write-Output "Clean up temporary folder"
Remove-Item -Path "C:\Temp" -Recurse -Force

Write-Output "DataDog Install stdout: $($out.stdout)"
Write-Output "DataDog Install stderr: $($out.stderr)"
Write-Output "DataDog Install exitcode: $($out.exitcode)"
