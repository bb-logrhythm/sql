
-- Collector: Trend By Minute
SELECT 
	a.[SystemMonitorID] 
	,c.[Name] as 'SystemMonitor'
	,[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,[CountLogs]
	,[CountLogs]/60 as 'RateLogs'
	,[CountProcessedLogs]
	,[CountProcessedLogs]/60 as 'RateProcessedLogs'
	,[CountOnlineLogs]
	,[CountOnlineLogs]/60 as 'RateOnlineLogs'
FROM [LogRhythm_LogMart].[dbo].[StatsSystemMonitorCountsMinute] a
	LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.[MediatorID] = b.[MediatorID]
	JOIN [LogRhythmEMDB].[dbo].[SystemMonitor] c on a.[SystemMonitorID] = c.[SystemMonitorID]
;
