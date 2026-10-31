# Starts Genesis Community, checks what is installed, or adds shortcuts.
#   powershell -ExecutionPolicy Bypass -File Genesis.ps1
#   powershell -ExecutionPolicy Bypass -File Genesis.ps1 -Check
#   powershell -ExecutionPolicy Bypass -File Genesis.ps1 -InstallShortcut
#   powershell -ExecutionPolicy Bypass -File Genesis.ps1 -RemoveShortcut
param([switch]$Check, [switch]$InstallShortcut, [switch]$RemoveShortcut, [string]$Project = "")
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$App = Join-Path $Here "Genesis.exe"
$Shortcuts = @(
	(Join-Path ([Environment]::GetFolderPath("Programs")) "Genesis Community.lnk"),
	(Join-Path ([Environment]::GetFolderPath("Desktop")) "Genesis Community.lnk"))

if (-not (Test-Path $App)) { Write-Error "Genesis.exe is not beside this script ($Here)."; exit 1 }

if ($Check) {
	Write-Output "Genesis Community, $Here"
	foreach ($t in "ffmpeg", "blender", "pdftoppm") {
		$c = Get-Command $t -ErrorAction SilentlyContinue
		if ($c) { Write-Output ("  {0}: {1}" -f $t, $c.Source) } else { Write-Output ("  {0}: not found (optional)" -f $t) }
	}
	$gpu = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1).Name
	Write-Output "  GPU: $gpu"
	exit 0
}
if ($InstallShortcut) {
	$shell = New-Object -ComObject WScript.Shell
	foreach ($s in $Shortcuts) {
		$l = $shell.CreateShortcut($s)
		$l.TargetPath = $App
		$l.WorkingDirectory = $Here
		$l.IconLocation = "$App,0"
		$l.Description = "Architectural and event visualisation"
		$l.Save()
	}
	Write-Output "Added Genesis Community to the Start menu and the desktop."
	exit 0
}
if ($RemoveShortcut) {
	foreach ($s in $Shortcuts) { Remove-Item $s -ErrorAction SilentlyContinue }
	Write-Output "Removed."
	exit 0
}
if ($Project -ne "") { Start-Process -FilePath $App -ArgumentList "`"$Project`"" -WorkingDirectory $Here }
else { Start-Process -FilePath $App -WorkingDirectory $Here }
