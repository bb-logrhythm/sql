
-- Collector: Trend By Hour
SELECT 
	a.[SystemMonitorID] 
	,c.[Name] as 'SystemMonitor'
	,[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,[CountLogs]
	,[CountLogs]/3600 as 'RateLogs'
	,[CountProcessedLogs]
	,[CountProcessedLogs]/3600 as 'RateProcessedLogs'
	,[CountOnlineLogs]
	,[CountOnlineLogs]/3660 as 'RateOnlineLogs'
FROM [LogRhythm_LogMart].[dbo].[StatsSystemMonitorCountsHour] a
	LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.[MediatorID] = b.[MediatorID]
	JOIN [LogRhythmEMDB].[dbo].[SystemMonitor] c on a.[SystemMonitorID] = c.[SystemMonitorID]
	INNER JOIN ( -- To run this query against a larger dataset, comment out this entire INNER JOIN and uncomment the WHERE clause below
			SELECT TOP 1
				CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'PeakDay'
				,SUM(CAST([CountProcessedLogs] AS BIGINT))/(3600*24) as 'MPS_PeakDay'
			FROM
				[LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
			WHERE
				[StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
			GROUP BY
				CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
			ORDER BY
				MPS_PeakDay DESC
			) peak ON CONVERT(DATE,(DATEADD(HH,-7,a.[StatDate])))  = peak.[PeakDay]
-- WHERE [StatDate] > DATEADD(DD,-7,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
;