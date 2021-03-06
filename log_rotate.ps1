# *********************************************
#          (c) Cyberdan IT Consultants
# *********************************************
#
# filename:     log_rotate.ps1
#
# author/s:             Kye Donaldson
#
# description:  Rotates logs by passing the full path into relevant function.
#               cp_rotate (copy) function is used for logfiles that are always open and can't be rotated normally.
#               This copys the log, then uses the clear-content cmdlet to clear it down.
#               Normal rotate function simply renames the logfile which is then automatically recreated.
#               Log files that haven't been modified in 90 days are cleared down.
#
# dependencies: None
#
# ****************************************************
# Version       Date                    Comment
# *****************************************************
# 1.0           11-DEC-2020             Tested and working
# 1.1           03-MAR-2021             Fixed bug with cp_rotate by replacing $args[0] with $file
# *****************************************************
Function rotate(){
    Write-Host $args[0]
    $file = $args[0]
    $dir = Split-Path -Parent $file
    $date = get-date -uformat "_%d-%m-%Y_%H-%M-%S"
    $newfile = "$file" + "$date" + ".ROTATE"
    Move-Item "$file" "$newfile"
    Get-ChildItem -Path $dir -Filter *.ROTATE | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-90))} | Remove-Item
}

Function cp_rotate(){
    $file = $args[0]
    $dir = Split-Path -Parent $file
    $date = get-date -uformat "%d-%m-%Y_%H-%M-%S"
    $newfile = $file + $date + ".CP_ROTATE"
    Copy-Item "$file" "$newfile"
    Clear-Content $file
    Get-ChildItem -Path $dir -Filter *.CP_ROTATE | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-90))} | Remove-Item
}

# example of rotate function
rotate 'C:\oracle\admin\WFMSPROD\diag\rdbms\wfmsprodpri\wfmsprod\trace\alert_wfmsprod.log'

# example of cp_rotate function
# Usually you would have to stop listener logging while you delete/rotate the file but not with this function.
cp_rotate 'C:\app\administrator\diag\tnslsnr\BR-wmslive\listener\trace\listener.log'