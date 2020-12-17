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
# 1.0           11-DEC-2020             Development started
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
    $dir = Split-Path -Parent $args[0]
    $date = get-date -uformat "%d-%m-%Y_%H-%M-%S"
    $newfile = $file + $date + ".CP_ROTATE"
    Copy-Item "$args[0]" "$newfile"
    Clear-Content $args[0]
    Get-ChildItem -Path $dir -Filter *.CP_ROTATE | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-90))} | Remove-Item
}
