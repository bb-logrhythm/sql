-- ===============================
-- Reporting Queries
-- ===============================

-- Count of Device Types
SELECT
   COUNT(1) as Count_DeviceTypes
   ,SUM(Count_Devices) as Total_Devices
FROM
   (SELECT
        [LogSourceType]
        ,COUNT([HostID]) as Count_Devices
   FROM
        (SELECT 
        a.[HostID]
                   ,b.[Name] as LogSourceType
        FROM 
               [LogRhythmEMDB].[dbo].[MsgSource] a
             LEFT OUTER JOIN [LogRhythmEMDB].[dbo].[MsgSourceType] b ON a.[MsgSourceTypeID] = b.[MsgSourceTypeID]
        WHERE a.[RecordStatus] = 1
        ) ab
   WHERE
        [LogSourceType] IS NOT NULL
        AND [LogSourceType] NOT LIKE 'LogRhythm%'
   GROUP BY
        [LogSourceType]
   ) abc
;

-- Count of Devices
SELECT
   [LogSourceType]
   ,COUNT([HostID]) as Count_Devices
FROM
   (SELECT 
                a.[HostID]
              ,b.[Name] as LogSourceType
   FROM 
          [LogRhythmEMDB].[dbo].[MsgSource] a
        LEFT OUTER JOIN [LogRhythmEMDB].[dbo].[MsgSourceType] b ON a.[MsgSourceTypeID] = b.[MsgSourceTypeID]
   WHERE a.[RecordStatus] = 1
   ) ab
WHERE
   [LogSourceType] IS NOT NULL
   AND [LogSourceType] NOT LIKE 'LogRhythm%'
GROUP BY
   [LogSourceType]
;
   
-- MPS by Day
SELECT 
    CONVERT(Date,DATEADD(HH,-7,[StatDate])) as 'Day'
   ,SUM([CountProcessedLogs])/(3600*24) as MPS
FROM
   [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
WHERE
   [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
GROUP BY
    CONVERT(Date,DATEADD(HH,-7,[StatDate]))
ORDER BY 
    CONVERT(Date,DATEADD(HH,-7,[StatDate])) DESC
;


-- ===============================
-- Capacity & Architecture Assessment Queries
-- ===============================

-- MPS & EPS Metrics
SELECT -- MPS Peak Minute
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,a.Rate
FROM 
  (SELECT TOP 1
    'MPS_PeakMinute' as 'Metric'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTime_MST'
    ,([CountProcessedLogs]/60) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) a              
UNION ALL
SELECT -- MPS Peak Hour
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,a.Rate
FROM 
  (SELECT TOP 1
    'MPS_PeakHour' as 'Metric'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTime_MST'
    ,([CountProcessedLogs]/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) a          
UNION ALL
SELECT -- MPS Peak Day
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,a.Rate
FROM 
  (SELECT TOP 1
    'MPS_PeakDay' as 'Metric'
    ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTime_MST'
    ,SUM(CAST([CountProcessedLogs] AS BIGINT))/(3600*24) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  ORDER BY Rate DESC
  ) a
UNION ALL
SELECT -- MPS Weekly Average
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,a.Rate
FROM 
  (SELECT
    'MPS_WeeklyAverage' as 'Metric'
    ,GETDATE() as 'DateTime_MST'
    ,AVG([CountProcessedLogs]/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) a
UNION ALL
SELECT -- % Events Weekly Average
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,(CAST([mEvents] AS FLOAT)/CAST([mLogs] AS FLOAT))*100 as 'Rate'
FROM 
  (SELECT
    '%_Events' as Metric
    ,GETDATE() as DateTime_MST
    ,SUM(CAST([CountEvents] AS BIGINT))/1000 as 'mEvents'
    ,SUM(CAST([CountLogs] AS BIGINT))/1000 as 'mLogs'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) a         
UNION ALL
SELECT -- Events Weekly Average
  GETDATE() as 'Runtime'
  ,a.Metric
  ,a.DateTime_MST
  ,a.Rate
FROM 
  (SELECT
    'EPS_WeeklyAverage' as 'Metric'
    ,GETDATE() as 'DateTime_MST'
    ,AVG(CAST([CountEvents] AS FLOAT)/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) a
;

-- Deployment Maximums
SELECT
	MaxRateProcessedLogsHour
	,MaxRateProcessedLogsMinute
	,MaxRateEventsHour
	,MaxRateEventsMinute
FROM
       (SELECT 
                'place' as holder
                ,(MAX([CountProcessedLogs])/3600) as MaxRateProcessedLogsHour
                ,(MAX([CountEvents])/3600) as MaxRateEventsHour
       FROM [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
          WHERE [StatDate] > DATEADD(DD,-8,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
       ) hourly
       JOIN
       (SELECT 
                'place' as holder
                ,(MAX([CountProcessedLogs])/60) as MaxRateProcessedLogsMinute
                ,(MAX([CountEvents])/60) as MaxRateEventsMinute
       FROM [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
          WHERE [StatDate] > DATEADD(DD,-8,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
       ) minutely
       ON hourly.holder = minutely.holder 
;
   
-- Deployment Overview
          SELECT 
     (MAX([CountProcessedLogs])/3600) as MaxProcessedRate
   ,(AVG(CAST([CountProcessedLogs] as BIGINT))/3600) as AvgProcessedRate
   ,(MAX([CountOnlineLogs])/3600) as MaxIndexedRate
   ,(AVG(CAST([CountOnlineLogs] as BIGINT))/3600) as AvgIndexedRate
   ,(MAX([CountEvents])/3600) as MaxEventsRate
   ,(AVG(CAST([CountEvents] as BIGINT))/3600) as AvgEventsRate
    FROM [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
    WHERE [StatDate] > DATEADD(DD,-7,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
;

-- Mediator Capacity (Assumes DX7400 series and DP7400 series)
SELECT 
     b.[Name] as Mediator
   ,(MAX([CountProcessedLogs])/3600) as MaxProcessedRate
   ,(AVG(CAST([CountProcessedLogs] as BIGINT))/3600) as AvgProcessedRate
   ,((MAX([CountProcessedLogs])/3600)/90) as MaxProcessedUtil
   ,((AVG(CAST([CountProcessedLogs] as BIGINT))/3600)/90) as AvgProcessedUtil
   ,(9000-(MAX([CountProcessedLogs])/3600)) as MaxProcessedCapacity -- Change the '9000' value if you're not assessing DP7400 series
   ,(9000-(AVG(CAST([CountProcessedLogs] as BIGINT))/3600)) as AvgProcessedCapacity -- Change the '9000' value if you're not assessing DP7400 series
   ,(MAX([CountOnlineLogs])/3600) as MaxIndexedRate
   ,(AVG(CAST([CountOnlineLogs] as BIGINT))/3600) as AvgIndexedRate
   ,((MAX([CountOnlineLogs])/3600)/60) as MaxIndexedUtil
   ,((AVG(CAST([CountOnlineLogs] as BIGINT))/3600)/60) as AvgIndexedUtil
   ,(6000-(MAX([CountOnlineLogs])/3600)) as MaxIndexedCapacity -- Change the '6000' value if you're not assessing DX7400 series
   ,(6000-(AVG(CAST([CountOnlineLogs] as BIGINT))/3600)) as AvgIndexedCapacity -- Change the '6000' value if you're not assessing DX7400 series
   ,(MAX([CountEvents])/3600) as MaxEventsRate
   ,(AVG(CAST([CountEvents] as BIGINT))/3600) as AvgEventsRate
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
          LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.[MediatorID] = b.[MediatorID]
    WHERE [StatDate] > DATEADD(DD,-7,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY 
  b.[Name]
    ORDER BY Mediator ASC
;

-- Log Source: Average by Day
SELECT
  ms.[Name] as 'LogSourceName'
  -- ,b.[Name] as 'Mediator'
  ,CONVERT(DATE,DATEADD(HH,-7,[StatDate])) as 'DateMst'
  ,AVG([CountLogs])
  ,AVG([CountLogs])/3600 as 'RateLogs'
  ,AVG([CountProcessedLogs])
  ,AVG([CountProcessedLogs])/3600 as 'RateProcessedLogs'
  ,AVG([CountIdentifiedLogs])
  ,AVG([CountIdentifiedLogs])/3600 as 'RateIdentifiedLogs'
  ,AVG([CountArchivedLogs])
  ,AVG([CountArchivedLogs])/3600 as 'RateArchivedLogs'
  ,AVG([CountOnlineLogs])
  ,AVG([CountOnlineLogs])/3600 as 'RateOnlineLogs'
  ,AVG([CountEvents])
  ,AVG([CountEvents])/3600 as 'RateEvents'
  ,AVG([CountLogMart])
  ,AVG([CountLogMart])/3600 as 'RateLogMart'
FROM [LogRhythm_LogMart].[dbo].[StatsMsgSourceCounts] smsc
  LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
  LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on smsc.[MediatorID] = b.[MediatorID]
  -- INNER JOIN ( -- To run this query against a larger dataset, comment out this entire INNER JOIN and uncomment the WHERE clause below
  --    SELECT TOP 1
  --      CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'PeakDay'
  --      ,SUM(CAST([CountProcessedLogs] AS BIGINT))/(3600*24) as 'MPS_PeakDay'
  --    FROM
  --      [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  --    WHERE
  --      [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  --    GROUP BY
  --      CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  --    ORDER BY
  --      MPS_PeakDay DESC
  --    ) peak ON CONVERT(DATE,(DATEADD(HH,-7,smsc.[StatDate])))  = peak.[PeakDay]
WHERE [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(DD,-1,GETUTCDATE())
GROUP BY
  ms.[Name]
  -- ,b.[Name]
  ,CONVERT(DATE,DATEADD(HH,-7,[StatDate]))
ORDER BY 
  'DateMst' ASC
  ,'LogSourceName' DESC
;

-- Licensed Volume
-- Highest Single Rolling 24h MPS Average Per Month
SELECT [Month] = DATEADD(MONTH, DATEDIFF(MONTH, 0, rolling.DateTimeCst), 0),
    [Max_MPS_RollingDayAvg] =  MAX(rolling.MPS_RollingDayAvg)
  FROM (SELECT [DateTimeCst] = DATEADD(HH,-6,b.StatDate),
    [MPS_RollingDayAvg] = (AVG(CAST(past.CountProcessedLogs AS BIGINT))/3600)
  FROM (SELECT a.StatDate,
    a.CountProcessedLogs
  FROM LogRhythm_LogMart.dbo.StatsDeploymentCountsHour a) past LEFT OUTER JOIN
    LogRhythm_LogMart.dbo.StatsDeploymentCountsHour b ON past.StatDate BETWEEN DATEADD(HH,-24,b.StatDate) AND b.StatDate
  WHERE b.StatDate > DATEADD(yyyy,-1,GETUTCDATE())
  GROUP BY DATEADD(HH,-6,b.StatDate)) rolling
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, rolling.[DateTimeCst]), 0)
ORDER BY [MONTH] DESC;
