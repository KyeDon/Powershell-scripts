# Powershell-scripts
## Check failed logins
#### Sends out an email alert if the maximum failed logins is exceeded within a timeframe
Picks up failed logins within a set amount of time defined by the $date variable. Default is 5 minutes.
This should be paired with a task scheduler task that runs the script per the same interval as $date i.e. 5 minutes.
