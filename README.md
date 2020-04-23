# Powershell-scripts
## Check failed logins
#### Sends out an email alert if the maximum failed logins is exceeded within a timeframe
Picks up failed logins within a set amount of time defined by the $date variable. Default is 5 minutes.
This should be paired with a task scheduler task that runs the script per the same interval as $date i.e. 5 minutes.
![image](https://user-images.githubusercontent.com/47357003/80148793-78c16c80-85ad-11ea-984d-82396497b96c.png) <br/>
The threshold for the amount of failures that trigger an alert can be changed by modifying the $ge variable
