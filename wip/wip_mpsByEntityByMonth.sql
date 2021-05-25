
-- MPS by Entity by Month

DECLARE @Start_Date AS DATE = '2020-06-01 00:00:00'
DECLARE @End_Date AS DATE = '2020-07-01 00:00:00'
SELECT        
    e.[FullName] AS 'EntityName'
    -- , h.[Name] AS 'HostName'
    -- , ms.Name AS 'LogSourceName'
    , SUM(CAST([CountProcessedLogs] AS BIGINT))/(86400*(DATEDIFF(day,@Start_Date, @End_Date)))
FROM  
    [LogRhythm_LogMart].[dbo].[StatsMsgSourceCounts] smsc
    LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
    LEFT JOIN [LogRhythmEMDB].[dbo].[Host] h on ms.[HostID] = h.[HostID]
    LEFT JOIN [LogRhythmEMDB].[dbo].[Entity] e on h.[EntityID] = e.[EntityID]
WHERE 
    smsc.[StatDate] >= @Start_Date 
    AND smsc.[StatDate] < @End_Date
GROUP BY  e.[FullName]
ORDER BY 'EntityName' ASC