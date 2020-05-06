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
