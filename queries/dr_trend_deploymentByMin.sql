-- Deployment: Trend By Minute
SELECT
	[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,[CountLogs]
	,[CountLogs]/60 as 'RateLogs'
	,[CountProcessedLogs]
	,[CountProcessedLogs]/60 as 'RateProcessedLogs'
	,[CountIdentitfiedLogs]
	,[CountIdentitfiedLogs]/60 as 'RateIdentifiedLogs'
	,[CountArchivedLogs]
	,[CountArchivedLogs]/60 as 'RateArchivedLogs'
	,[CountOnlineLogs]
	,[CountOnlineLogs]/60 as 'RateOnlineLogs'
	,[CountEvents]
	,[CountEvents]/60 as 'RateEvents'
	,[CountLogMart]
	,[CountLogMart]/60 as 'RateLogMart'
	,[CountAlarms]
	,[CountAlarms]/60 as 'RateAlarms'
FROM [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute] a
ORDER BY [StatDate] DESC
;