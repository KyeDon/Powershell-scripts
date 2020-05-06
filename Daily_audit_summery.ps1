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

foreach ( $S_obj in $success)
{
    if ($Si -le $S_minus) {
        $SMTPMessage.Body += $success[$i].properties[5].value
        $type = $success[$i].properties[8].value
        $SMTPMessage.Body += " Logon type is $type"
        $i += 1
    }
}