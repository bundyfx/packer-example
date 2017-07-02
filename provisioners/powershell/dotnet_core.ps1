
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

Write-Output "Downloading dotnetcore"
Invoke-WebRequest -UseBasicParsing -Uri "https://go.microsoft.com/fwlink/?linkid=837808" -OutFile "C:\Temp\dotnetcore.exe"

Write-Output "Install dotnetcore"

$out = Start-ProcessWithCapture -FilePath C:\Temp\dotnetcore.exe -ArgumentList "/install /quiet"

Write-Output "Clean up temporary folder"
Remove-Item -Path "C:\Temp" -Recurse -Force

Write-Output "dotnetcore stdout: $($out.stdout)"
Write-Output "dotnetcore stderr: $($out.stderr)"
Write-Output "dotnetcore exitcode: $($out.exitcode)"
