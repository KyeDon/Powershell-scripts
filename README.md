# Powershell-scripts
## Failed logins 5 minute
#### Sends out an email alert if the maximum failed logins is exceeded within a timeframe
Picks up failed logins within a set amount of time defined by the $date variable. Default is 5 minutes.
This should be paired with a task scheduler task that runs the script per the same interval as $date i.e. 5 minutes. <br/>
At the top of the script are variables that need modifying, these must be changed for the script to work.
![image](https://user-images.githubusercontent.com/47357003/80148793-78c16c80-85ad-11ea-984d-82396497b96c.png) <br/>
The threshold for the amount of failures that trigger an alert can be changed by modifying the $ge variable. <br/>
When setting up the action select start a program and type "powershell". The arguments should be "-executionpolicy bypass -windowstyle hidden C:\PathToFile\failed_logins_5minute.ps1"

## Daily audit report
#### Sends out an email daily showing failed logins and successful logins in the past 24 hours.
There are 2 scripts here, one gives a full daily report of successful/failed logins in the same style as<br/>
the 5 minute failed logins. The other gives a small summery of successful/failed logins in the from of<br/>
<user>:Successful logins \<number\> Failed logins \<number\><br/>
This is now fully functional however I need to finish up the documentation (its pretty simple though)
