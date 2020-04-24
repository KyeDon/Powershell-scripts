<#
Check for failed logins in past 5 minutes and send an email if more than $ge.
This script will enable auditing for login failures if it is disabled.
This means that the first time it runs it may not find anything even if -
there were failed logins previously.
This script was intended to be paired with a task scheduler task to run
inline with the $date variable. Full documentation can be found on my Github.
Written by Kye Donaldson for Cyberdan Ltd 22/04/2020
Github - https://github.com/KyeDon
#>

##Main variables
$ge = 1 #Change this to the desired threshold for the amount of failures that trigger an alert.
$hostname = [System.Net.Dns]::GetHostByName($env:computerName).HostName
#Get date/time 5 minutes ago
[datetime]$date = (get-date).addminutes(-5) #Change -5 for a different interval.

#Enable auditing on login failure in local computer policy
$CurrentAudit = (auditpol /get /subcategory:"Logon")[4]
if( -not $CurrentAudit.Contains("Failure")){
    auditpol /set /subcategory:"Logon" /failure:enable
}

#Instanceid references the event ID in event viewer. 4625 is a failed login.
$eventlog = get-eventlog -logname security -instanceid 4625 -after $date
$count = $eventlog | measure
$counted = $count.count
$minus1 = $counted -1 #Because arrays start at 0 not 1

$i = 0
while ($i -lt $counted)
{
    [array]$table += $eventlog[$i] | Format-Table -AutoSize | Out-String
    $i += 1
}


if ($count.count -ge $ge) {
    echo "$ge or more failures sending email..."
    $EmailTo = "Example@Example.co.uk" #Change this
    $EmailFrom = "smtpconnect@Example.co.uk" #Change this
    $EmailPW = "password1" #Change this
    $Subject = "Failed logins on $hostname!!"
    $Body = ""
    $SMTPServer = "smtp.office365.com" #May need to change this
    $SMTPPort = 587
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPMessage.Body = "Failed logins in last 5 minutes on $hostname - `n"
    $number = 0
    foreach ( $obj in $table)
    {
        if ($number -le $minus1) {
            $SMTPMessage.Body += $table[$number]
            $SMTPMessage.Body += ($eventlog[$number].Message -split '\n')[12]
            $number += 1
        }
    }
    $SMTPMessage.Body += "`n Navigate to security tab in event viewer for full details."
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPW);
    $SMTPClient.Send($SMTPMessage)
}
else {
    echo "$counted failed attempts were found. Exiting"
    exit
}
