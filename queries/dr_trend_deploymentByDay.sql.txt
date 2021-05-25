-- ==========================
-- Deployment Review Queries
-- ==========================

-- Trend Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Deployment: Trend By Day
SELECT
	CAST(DATEADD(HH,-7,[StatDate]) as date) as 'DateMst'
	,AVG([CountLogs])/3600 as 'RateLogs'
	,AVG([CountProcessedLogs])/3600 as 'RateProcessedLogs'
	,AVG([CountIdentitfiedLogs])/3600 as 'RateIdentifiedLogs'
	,AVG([CountArchivedLogs])/3600 as 'RateArchivedLogs'
	,AVG([CountOnlineLogs])/3600 as 'RateOnlineLogs'
	,AVG([CountEvents])/3600 as 'RateEvents'
FROM [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour] a
WHERE [StatDate] > DATEADD(DD,-30,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
GROUP BY CAST(DATEADD(HH,-7,[StatDate]) as date)
ORDER BY DateMst DESC
;