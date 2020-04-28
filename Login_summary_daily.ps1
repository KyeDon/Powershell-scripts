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
$S_minus = $S_count -1 #Used for accessing array later
$F_minus = $F_count -1 #Used for accessing array later

#Success loop
$i = 0
while ($i -lt $S_count)
{
    [array]$S_table += $Success[$i] | Format-Table -AutoSize | Out-String
    $i += 1
}

#Failure loop
$i = 0
while ($i -lt $F_count)
{
    [array]$F_table += $Failure[$i] | Format-Table -AutoSize | Out-String
    $i += 1
}

##Send out email report
$Subject = "Daily audit report on $hostname"
$Body = ""
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.Body = "Daily login audit for past day on $hostname - `n"

#Write failure body
$SMTPMessage.Body += "Failed logins in past 24 hours `n"
$F_number = 0
foreach ( $F_obj in $F_table)
{
    if ($F_number -le $F_minus) {
        $SMTPMessage.Body += $F_table[$F_number]
        $SMTPMessage.Body += ($failure[$F_number].Message -split '\n')[12]
        $F_number += 1
    }
}

#Write success body
$SMTPMessage.Body += "Successful logins in past 24 hours `n"
$S_number = 0
foreach ( $S_obj in $S_table)
{
    if ($S_number -le $S_minus) {
        $SMTPMessage.Body += $S_table[$S_number]
        $SMTPMessage.Body += ($success[$S_number].Message -split '\n')[18]
        $S_number += 1
    }
}

$SMTPMessage.Body += "`n Navigate to security tab in event viewer for full details."
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPW);
$SMTPClient.Send($SMTPMessage)
