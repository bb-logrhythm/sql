
-- Mediator: Trend By Minute
SELECT
	b.[MediatorID]
	,b.[Name] as 'Mediator'
	,[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,SUM([CountLogs]) as 'CountLogs'
	,SUM([CountLogs])/60 as 'RateLogs'
	,SUM([CountProcessedLogs]) as 'CountProcessedLogs'
	,SUM([CountProcessedLogs])/60 as 'RateProcessedLogs'
	,SUM([CountIdentifiedLogs]) as 'CountIdentifiedLogs'
	,SUM([CountIdentifiedLogs])/60 as 'RateIdentifiedLogs'
	,SUM([CountArchivedLogs]) as 'CountArchivedLogs'
	,SUM([CountArchivedLogs])/60 as 'RateArchivedLogs'
	,SUM([CountOnlineLogs]) as 'CountOnlineLogs'
	,SUM([CountOnlineLogs])/60 as 'RateOnlineLogs'
	,SUM([CountEvents]) as 'CountEvents'
	,SUM([CountEvents])/60 as 'RateEvents'
	,SUM([CountLogMart]) as 'CountLogMart'
	,SUM([CountLogMart])/60 as 'RateLogMart'
FROM
	[LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
	LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
	LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on smsc.[MediatorID] = b.[MediatorID]
	INNER JOIN (   -- To run this query against a larger dataset, comment out this entire INNER JOIN 
		SELECT TOP 1
			(DATEADD(HH,-7,[StatDate])) as 'PeakHour'
			,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'MPS_PeakHour'
		FROM
			[LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
		WHERE
			[StatDate] BETWEEN (SELECT MIN(CAST(DATEADD(hour, DATEDIFF(hour, 0, (DATEADD(HH,-7,smsc.[StatDate]))), 0) as smalldatetime)) FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc) AND DATEADD(HH,-1,GETUTCDATE())
		GROUP BY
			(DATEADD(HH,-7,[StatDate]))
		ORDER BY
			MPS_PeakHour DESC
		) peak ON CAST(DATEADD(hour, DATEDIFF(hour, 0, (DATEADD(HH,-7,smsc.[StatDate]))), 0) as smalldatetime) = peak.[PeakHour]
GROUP BY 
	b.[MediatorID]
	,b.[Name] 
	,[StatDate]
	,DATEADD(HH,-7,[StatDate])
	,DATEPART(DD,DATEADD(HH,-7,[StatDate]))
	,DATEPART(HH,DATEADD(HH,-7,[StatDate]))
ORDER BY 
	[MediatorID] ASC
	,[StatDate] DESC
;