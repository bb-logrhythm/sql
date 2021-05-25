
-- Log Source: Trend By Minute For Top 5 Log Sources
SELECT
	ms.[Name] as 'LogSourceName'
	,smsc.[MsgSourceID]
	,b.[Name] as 'Mediator'
	,[StatDate] as 'DateTimeUtc'
	,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
	,[CountLogs]
	,[CountLogs]/60 as 'RateLogs'
	,[CountProcessedLogs]
	,[CountProcessedLogs]/60 as 'RateProcessedLogs'
	,[CountIdentifiedLogs]
	,[CountIdentifiedLogs]/60 as 'RateIdentifiedLogs'
	,[CountArchivedLogs]
	,[CountArchivedLogs]/60 as 'RateArchivedLogs'
	,[CountOnlineLogs]
	,[CountOnlineLogs]/60 as 'RateOnlineLogs'
	,[CountEvents]
	,[CountEvents]/60 as 'RateEvents'
	,[CountLogMart]
	,[CountLogMart]/60 as 'RateLogMart'
FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
	LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
	LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on smsc.[MediatorID] = b.[MediatorID]
	INNER JOIN ( 
		SELECT TOP 5  -- To run this query against a larger dataset, increase this number
			smsch.[MsgSourceID]
			,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'MPS_TopSources'
		FROM
			[LogRhythm_LogMart].[dbo].[StatsMsgSourceCounts] smsch
		WHERE
			[StatDate] BETWEEN (SELECT MIN(CAST(DATEADD(hour, DATEDIFF(hour, 0, (DATEADD(HH,-7,smsc.[StatDate]))), 0) as smalldatetime)) FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc) AND DATEADD(HH,-1,GETUTCDATE())
		GROUP BY
			smsch.[MsgSourceID]
		ORDER BY
			MPS_TopSources DESC
		) peak ON smsc.[MsgSourceID] = peak.[MsgSourceID]
-- ORDER BY 
-- 	'LogSourceName' ASC
-- 	,[StatDate] DESC
;
