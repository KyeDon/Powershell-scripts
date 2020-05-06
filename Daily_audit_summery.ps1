[datetime]$Date = (get-date).AddDays(-1)

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
    if ($i -le $S_minus) {
        [array]$username += $success[$i].properties[5].value
        $i += 1
    }
}
