
-- Parent Entity: Average by Day
SELECT
	ent.[Name] as 'EntityName'
	,combo.[DateMst] as 'DateMst'
	,SUM(CAST(combo.[CountProcessedLogs] AS BIGINT))/86400 as 'RateProcessedLogs'
FROM
	(SELECT -- child
		e.[ParentEntityID] as 'EntityID'
		,CONVERT(DATE,DATEADD(HH,-7,[StatDate])) as 'DateMst'
		,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'CountProcessedLogs'
	FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
		LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
		LEFT JOIN [LogRhythmEMDB].[dbo].[Host] h on ms.[HostID] = h.[HostID]
		LEFT JOIN [LogRhythmEMDB].[dbo].[Entity] e on h.[EntityID] = e.[EntityID]
	WHERE e.[ParentEntityID] IS NOT NULL
	GROUP BY
		e.[ParentEntityID]
		,CONVERT(DATE,DATEADD(HH,-7,[StatDate]))
	UNION ALL
	SELECT -- parent
		e.[EntityID] as 'EntityID'
		,CONVERT(DATE,DATEADD(HH,-7,[StatDate])) as 'DateMst'
		,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'CountProcessedLogs'
	FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
		LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
		LEFT JOIN [LogRhythmEMDB].[dbo].[Host] h on ms.[HostID] = h.[HostID]
		LEFT JOIN [LogRhythmEMDB].[dbo].[Entity] e on h.[EntityID] = e.[EntityID]
	WHERE e.[ParentEntityID] IS NULL
	GROUP BY
		e.[EntityID]
		,CONVERT(DATE,DATEADD(HH,-7,[StatDate]))
	) combo LEFT JOIN [LogRhythmEMDB].[dbo].[Entity] ent on combo.[EntityID] = ent.[EntityID]
GROUP BY
	ent.[Name] 
	,combo.[DateMst]
ORDER BY
	'EntityName' ASC
;
