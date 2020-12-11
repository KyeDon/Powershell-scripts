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