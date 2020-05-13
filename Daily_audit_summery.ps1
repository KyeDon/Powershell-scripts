<#
Audit successful/failed logins in last day and send out a small breakdown email.
This script will enable auditing for login success/failures if they are disabled.
This means that the first time it runs it may not find anything even if
there were logins previously.
This script doesn't have any AD integration, and the changing of local policys won't work if the computer is on a domain.
This script is intended to be paired with a task scheduler task to run
inline with the $date variable. Full documentation can be found on my Github.
Written by Kye Donaldson for Cyberdan Ltd 06/05/2020
Github - https://github.com/KyeDon
#>

##Main variables - These are the only variables that may need changing
$EmailTo = "Example@Example.co.uk" #Change this
$EmailFrom = "smtpconnect@Example.co.uk" #Change this
$EmailPW = "password1" #Change this
$SMTPServer = "smtp.office365.com" #May need to change this
$SMTPPort = 587 #May need to change this

#Changing these variables is optional
[datetime]$Date = (get-date).AddDays(-1) #Change -1 for a different interval.
$hostname = [System.Net.Dns]::GetHostByName($env:computerName).HostName

##Success
#Filters out Kerberos as it seems to generate 1000's of logins on domain environments.
#This query will also pull back multiple of the same login but logged as multiple different events.
#Typically 5 logins per 1 user = 1 actual login. This behaviour can be changed by filtering out
#specific login types however this may cause inconsistencys.
$Query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4624)] and EventData[Data[@Name='LogonProcessName']!='Kerberos'] and EventData[Data[@Name='TargetDomainName']!='Font Driver Host'] and EventData[Data[@Name='TargetDomainName']!='Window Manager'] and EventData[Data[@Name='TargetDomainName']!='NT AUTHORITY']]</Select>
  </Query>
</QueryList>
"@

$Filtered = Get-WinEvent -FilterXml $Query
$Success = $filtered | Where-Object { $_.timecreated -gt $Date }
$S_count = ($Success | measure).count
$S_minus = $S_count -1 #Used for accessing array later

#Success loop
$i = 0
foreach ($S_obj in $success)
{
    if ($i -le $S_minus) {
        [array]$S_username += $success[$i].properties[5].value
        $i += 1
    }
}
$S_grouped = $S_username | Group-Object -NoElement | Out-String

##Failures
[array]$Failure = get-eventlog -logname security -instanceid 4625 -after $Date
$F_count = ($failure | measure).count
$F_minus = $F_count -1 #Used for accessing array later

#Failure loop
$i = 0
foreach ( $obj in $Failure)
{
    if ($i -le $F_minus) {
        [array]$F_username += ($Failure[$i].Message -split '\n')[12] -replace '\s','' #replaces spaces with nothing.
        $i += 1
    }
}
$F_grouped = $F_username | Group-Object -NoElement | Out-String


##Send out email report
$Subject = "Daily audit summery on $hostname"
$Body = ""
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.Body = "Daily login audit on $hostname - `n"

#Write failure body
$SMTPMessage.Body += "Failed logins in past 24 hours `n"
if (!$failure) { $SMTPMessage.Body += "There are no failed logins `n" }
$SMTPMessage.Body += $F_grouped

#Write success body
$SMTPMessage.Body += "`nNumber of successful logins in past 24 hours`n"
$SMTPMessage.Body += $S_grouped

#Send out
$SMTPMessage.Body += "`nNavigate to security tab in event viewer for full details."
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPW);
$SMTPClient.Send($SMTPMessage)
