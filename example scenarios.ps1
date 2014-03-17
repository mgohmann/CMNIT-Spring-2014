

#################################################################################
#################################################################################
# A choose your own scenario presentation.
# With Matt Gohmann Deployment Analyst Netgain Technology Inc.
#################################################################################
#################################################################################





#################################################################################
# AD ATTRIBUTES: Find members of a department who live in a certain city.
#################################################################################
Import-Module activedirectory
Get-ADGroup "Customer Service Group" | Get-ADGroupMember | measure
$BostonCS = Get-ADGroup "Customer Service Group" | Get-ADGroupMember |
    ForEach-Object {Get-ADUser $_ -Properties * |
    where {$_.City -like "Boston"}| select Name }
$BostonCS | measure

#################################################################################
#BAD APP: Find and stop freezing processes.
#################################################################################
Get-Process
Get-Process | where {$_.WorkingSet -gt 20mb}
Get-Process | select ProcessName,Responding
& C:\MattsPresentation\BadApp.exe
Get-Process | select ProcessName,Responding
Get-Process | where {-not $_.Responding} | Stop-Process -Force

#################################################################################
#DRIVE FORMAT:Find drives where the disk partition is greater than 64k.
#################################################################################
# Filtering with PowerShell
Get-WmiObject Win32_Volume |
     where {$_.BlockSize -ge 65536}
# Filtering with WQL and PowerShell
Get-WmiObject -Query "SELECT BlockSize,Name FROM Win32_Volume" |
     Where {$_.BlockSize -ge 65536}
# Filtering with only WQL
Get-WmiObject -Query "SELECT BlockSize,Name FROM Win32_Volume WHERE BlockSize >='65536'"
# Now show the drives less than 64k
Get-WmiObject -Query "SELECT BlockSize,Name FROM Win32_Volume WHERE BlockSize <'65536'"

#################################################################################
#FILES: Spreadsheet files that were changed in the last 10 days.
#################################################################################
# Find just the XLSX files in a directory
Get-ChildItem -Filter "*.xlsx" -Path N:\Share\ITFiles -Recurse
# FInd all of them written to in the last 20 days.
Get-ChildItem -Filter "*.xlsx" -Path N:\Share\ITFiles -Recurse |
    where {$_.LastWriteTime -ge (get-date).AddDays(-20)}

#################################################################################
#HELP WITH HELP:Hey PowerShell Help, I want you to show me just the mandatory Parameters!
#################################################################################
Get-Help Stop-Service
Get-Help Stop-Service -Parameter *
Get-Help Stop-Service -Parameter * | where {$_.Required -like "true"}
Get-Help Stop-Service -Parameter * | where {$_.Required -like "true"  -and $_.pipelineInput -like "false"}

#################################################################################
# OLD LOGON SCRIPTS: Find users who have an old log on script they aren't supposed to have.
#################################################################################
Import-Module activedirectory
Get-ADUser -filter * -Properties * | where {$_.HomeDrive}| select name,HomeDrive
Get-ADUser -filter * -Properties * | where {$_.ScriptPath}| select name,ScriptPath

#################################################################################
#PAGE FILE: Figure out which drive holds your page file.
#################################################################################
Get-WmiObject -Class Win32_Volume
Get-WmiObject -Class Win32_Volume |
    where {$_.pagefilepresent} | select name
# Or example
Get-WmiObject -Class Win32_Volume | where {$_.pagefilepresent -or $_.Name -like "N:\"} | select name

#################################################################################
#REPLACE CONTENT: Find a certain string in a text file and replace it.
#################################################################################
Invoke-Item N:\Share\ITFiles\test.csv
Get-Content N:\Share\ITFiles\test.csv
Get-Content N:\Share\ITFiles\test.csv | Select-String -Pattern "local" | measure
Get-Content N:\Share\ITFiles\test.csv | ForEach-Object {$_.Replace("local","lab")} | Set-Content N:\Share\ITFiles\testModified.csv
Get-Content N:\Share\ITFiles\testModified.csv | Select-String -Pattern "local" | measure
Invoke-Item N:\Share\ITFiles\testModified.csv

#################################################################################
# SERVICES: What services are STOPPED that SHOULD be started!
#################################################################################
# Startout with services that arent running.
Get-Service | Where {$_.status -notlike "Running"}
# This should work right???
Get-Service | Where {$_.Status -notlike "Running" -and $_.StartupType -like "Automatic"}
# Darn, it doesnt. Let's Try WMI instead and then filter it with PowerShell
Get-WmiObject Win32_Service | Where {$_.StartMode -like "Auto" -and $_.State -notlike "Running"} | ft Name,StartMode,State,Status -auto
# Now lets use only WQL
Get-WmiObject -Query 'SELECT Name,StartMode,State FROM Win32_Service WHERE StartMode LIKE "Auto" AND NOT State LIKE "Running"' | ft Name,StartMode,State,Status -auto
# Why is STATUS missing?
Get-WmiObject -Query 'SELECT Name,StartMode,State FROM Win32_Service WHERE StartMode LIKE "Auto" AND NOT State LIKE "Running"' | ft Name,StartMode,State,Status -auto

#################################################################################
#SMART AD ADMIN:Find OUs that are not properly protected from deletion!
#################################################################################
# Import the AD Module
Import-Module activedirectory
# Find the OUs that arent protected
Get-ADOrganizationalUnit -filter * -Properties * | where {$_.ProtectedFromAccidentalDeletion -eq $false} | select DistinguishedName
# Protect them
Get-ADOrganizationalUnit -filter * -Properties * | where {$_.ProtectedFromAccidentalDeletion -eq $false} | Set-ADObject -ProtectedFromAccidentalDeletion $true
# Always validate your work!
Get-ADOrganizationalUnit -filter * -Properties * | where {$_.ProtectedFromAccidentalDeletion -eq $false} | select DistinguishedName

#################################################################################
#UPDATES: Figure out what Updates are on my system and look for a particular update.
#################################################################################
select-string -path "$env:windir\WindowsUpdate.log" -Pattern "successfully installed"
select-string -path "$env:windir\WindowsUpdate.log" -Pattern "successfully installed" | Measure-Object
select-string -path "$env:windir\WindowsUpdate.log" -Pattern "successfully installed" | Out-GridView
select-string -path "$env:windir\WindowsUpdate.log" -Pattern "successfully installed" | Select-String -Pattern ".Net"
select-string -path "$env:windir\WindowsUpdate.log" -Pattern "successfully installed" | where {$_ -like "*.Net*"}

#################################################################################
#VSS: Find Volumes that have the Volume Shadow Copy Service turned on or off.
#################################################################################
#Requires -runasadmin
Get-WmiObject Win32_ShadowCopy
(Get-WmiObject Win32_ShadowCopy).VolumeName
Get-WmiObject Win32_Volume
Get-WmiObject Win32_Volume | where {$_.DeviceID -like (Get-WmiObject Win32_ShadowCopy).VolumeName}
Get-WmiObject Win32_Volume | where {$_.DeviceID -like (Get-WmiObject Win32_ShadowCopy).VolumeName} | select Name


#################################################################################
#WMI FILTER FOR GPOs:How to write and test a Group Policy WMI filter with PowerShell
#################################################################################
Get-WmiObject Win32_OperatingSystem

Get-WmiObject Win32_OperatingSystem | where {$_.Version -like "6.3*"}

Get-WmiObject Win32_OperatingSystem | where {$_.Version -like "6.3*" -and $_.ProductType -eq 2}
Get-WmiObject -Query "SELECT Version,ProductType FROM Win32_OperatingSystem WHERE ProductType = 2"
Get-WmiObject -Query 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "6.%" AND ProductType = "2"' 

