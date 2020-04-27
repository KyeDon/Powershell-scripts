<#
Audit successful/failed logins in last day and send an email report daily.
This script will enable auditing for login success/failures if they are disabled.
This means that the first time it runs it may not find anything even if
there were logins previously.
This script is intended to be paired with a task scheduler task to run
inline with the $date variable. Full documentation can be found on my Github.
Written by Kye Donaldson for Cyberdan Ltd 26/04/2020
Github - https://github.com/KyeDon
#>

##Main variables - These are the only variables that may need changing
$EmailTo = "Example@Example.co.uk" #Change this
$EmailFrom = "smtpconnect@Example.co.uk" #Change this
$EmailPW = "password1" #Change this
$SMTPServer = "smtp.office365.com" #May need to change this
$SMTPPort = 587 #May need to change this

#Changing these variables is optional
[datetime]$date = (get-date).AddDays(-1) #Change -1 for a different interval.
$hostname = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Enable auditing on login in local computer policy
$CurrentAudit = (auditpol /get /subcategory:"Logon")[4]
if( -not $CurrentAudit.Contains("Failure") -and -not $CurrentAudit.contains("Success")) {
    auditpol /set /subcategory:"Logon" /failure:enable
    auditpol /set /subcategory:"Logon" /success:enable
}

#Get event viewer events 4624=success 4625=failure
$Success = get-eventlog -logname security -instanceid 4624 -after $date
$Failure = get-eventlog -logname security -instanceid 4625 -after $date
$S_count = ($Success | measure).count
$F_count = ($failure | measure).count
