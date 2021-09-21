<#
Written by Kye Donaldson 2021-09-21
Version: 1.0
Updates all task scheduler tasks that run as the specified user.
This script is designed to run interactively as you will need to pass your credentials to Get-Credential securely/manually.

Credit to this Reddit post for saving me working out the task scheduler logic!
https://www.reddit.com/r/PowerShell/comments/9zkkc0/comment/ea9wyze/?utm_source=share&utm_medium=web2x&context=3
#>

$Credentials = Get-Credential
$Username = $Credentials.UserName
$Password = $Credentials.Password


$Tasks = schtasks.exe /query /s localhost /V /FO CSV | ConvertFrom-CSV | Where-Object { $_."Run As User" -eq "$Username"}
foreach ($Task in $Tasks) { Set-ScheduledTask -TaskName $Task.TaskName -User $Username -Password $Password