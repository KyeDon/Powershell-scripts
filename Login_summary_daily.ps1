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
[datetime]$Date = (get-date).AddDays(-1) #Change -1 for a different interval.
$hostname = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Enable auditing on login in local computer policy (assumes no AD)
$CurrentAudit = (auditpol /get /subcategory:"Logon")[4]
if( -not $CurrentAudit.Contains("Failure") -and -not $CurrentAudit.contains("Success")) {
    auditpol /set /subcategory:"Logon" /failure:enable
    auditpol /set /subcategory:"Logon" /success:enable
}

##Failures
#Get event viewer events 4625=failure
$Failure = get-eventlog -logname security -instanceid 4625 -after $Date
$F_count = ($failure | measure).count
$F_minus = $F_count -1 #Used for accessing array later

#Failure loop
$i = 0
while ($i -lt $F_count)
{
    [array]$F_table += $Failure[$i] | Format-Table -AutoSize | Out-String
    $i += 1
}

##Success
#Get event viewer events with XML query
$Query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4624)] and EventData[Data[@Name='TargetDomainName']!='Font Driver Host'] and EventData[Data[@Name='TargetDomainName']!='Window Manager'] and EventData[Data[@Name='TargetDomainName']!='NT AUTHORITY']]</Select>
  </Query>
</QueryList>
"@

$Filtered = Get-WinEvent -FilterXml $Query
$Success = $filtered | Where-Object { $_.timecreated -gt $Date }
$S_count = ($Success | measure).count
$S_minus = $S_count -1 #Used for accessing array later

#Success loop
$i = 0
while ($i -lt $S_count)
{
    [array]$S_table += $Success[$i] | Format-Table -AutoSize | Out-String
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
$i = 0
foreach ( $S_obj in $S_table)
{
    if ($Si -le $S_minus) {
        $SMTPMessage.Body += $S_table[$i]
        $SMTPMessage.Body += $success[$i].properties[5].value
        $type = $success[$i].properties[8].value
        $SMTPMessage.Body += "Logon type is $type"
        $i += 1
    }
}

$SMTPMessage.Body += "`n Navigate to security tab in event viewer for full details."
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPW);
$SMTPClient.Send($SMTPMessage)
