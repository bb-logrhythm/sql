$username = sa
$password = Read-Host "Enter the password for the sa account"

Write-Host "MediatorID, Mediator, DateTimeUtc, DateTimeMst, CountLogs, RateLogs, CountProcessedLogs, RateProcessedLogs, CountIdentifiedLogs, RateIdentifiedLogs, CountArchivedLogs, RateArchivedLogs, CountOnlineLogs, RateOnlineLogs, CountEvents, RateEvents, CountLogMart, RateLogMart" | Export-Csv -Path ".\output\trend_mediatorByHour.csv" -NoTypeInformation
Invoke-Sqlcmd -username $username -password $password -InputFile ".\sql\dr_trend_mediatorByHr.sql" | Export-Csv -Path ".\output\trend_mediatorByHour.csv" -NoTypeInformation