-- ==========================
-- Deployment Review Queries
-- ==========================

-- Metrics Summary
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT -- Deployment: MPS
  GETDATE() as 'Runtime'
  ,'Deployment' as 'Component'
  ,'Total' as 'ComponentName'
  ,'MPS' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[Rate] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[Rate] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM
  (SELECT TOP 1 -- Deployment: MPS: Peak Minute
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,([CountProcessedLogs]/60) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) m
JOIN
  (SELECT TOP 1 -- Deployment: MPS: Peak Hour
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,([CountProcessedLogs]/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) h ON m.[Deployment] = h.[Deployment]
JOIN
  (SELECT TOP 1 -- Deployment: MPS: Peak Day
    '001' as 'Deployment'
    ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
    ,SUM(CAST([CountProcessedLogs] AS BIGINT))/(3600*24) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  ORDER BY Rate DESC
  ) d ON m.[Deployment] = d.[Deployment]
JOIN
  (SELECT -- Deployment: MPS:  Average
    '001' as 'Deployment'
    ,AVG(CAST([CountProcessedLogs] AS BIGINT))/3600 as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) w ON m.[Deployment] = w.[Deployment]

UNION ALL

SELECT -- Deployment: Events
  GETDATE() as 'Runtime'
  ,'PlatformManager' as 'Component'
  ,'Total' as 'ComponentName'
  ,'Events' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[Rate] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[Rate] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM
  (SELECT TOP 1 -- Deployment: Events: Peak Minute
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,(([CountEvents]+[CountEventsAIEngine])/60) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) m
JOIN
  (SELECT TOP 1 -- Deployment: Events: Peak Hour
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,(([CountEvents]+[CountEventsAIEngine])/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) h ON m.[Deployment] = h.[Deployment]
JOIN
  (SELECT TOP 1 -- Deployment: Events: Peak Day
    '001' as 'Deployment'
    ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
    ,SUM(CAST([CountEvents] AS BIGINT)+CAST([CountEventsAIEngine] AS BIGINT))/(3600*24) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  ORDER BY Rate DESC
  ) d ON m.[Deployment] = d.[Deployment]
JOIN
  (SELECT -- Deployment: Events: Average
    '001' as 'Deployment'
    ,AVG(CAST([CountEvents] AS BIGINT)+CAST([CountEventsAIEngine] AS BIGINT))/3600 as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) w ON m.[Deployment] = w.[Deployment]

UNION ALL

SELECT -- Deployment: LogMart
  GETDATE() as 'Runtime'
  ,'PlatformManager' as 'Component'
  ,'Total' as 'ComponentName'
  ,'LogMart' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[Rate] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[Rate] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM
  (SELECT TOP 1 -- Deployment: LogMart: Peak Minute
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,([CountLogMart]/60) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) m
JOIN
  (SELECT TOP 1 -- Deployment: LogMart: Peak Hour
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,([CountLogMart]/3600) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) h ON m.[Deployment] = h.[Deployment]
JOIN
  (SELECT TOP 1 -- Deployment: LogMart: Peak Day
    '001' as 'Deployment'
    ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
    ,SUM(CAST([CountLogMart] AS BIGINT))/(3600*24) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  ORDER BY Rate DESC
  ) d ON m.[Deployment] = d.[Deployment]
JOIN
  (SELECT -- Deployment: LogMart: Average
    '001' as 'Deployment'
    ,AVG(CAST([CountLogMart] AS BIGINT))/3600 as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ) w ON m.[Deployment] = w.[Deployment]

UNION ALL

SELECT -- Deployment: Alarms
  GETDATE() as 'Runtime'
  ,'PlatformManager' as 'Component'
  ,'Total' as 'ComponentName'
  ,'Alarms' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[Rate] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[Rate] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM
  (SELECT TOP 1 -- Deployment: Alarms: Peak Minute
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,[CountAlarms] as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsMinute]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) m
JOIN
  (SELECT TOP 1 -- Deployment: Alarms: Peak Hour
    '001' as 'Deployment'
    ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
    ,[CountAlarms] as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  ORDER BY Rate DESC
  ) h ON m.[Deployment] = h.[Deployment]
JOIN
  (SELECT TOP 1 -- Deployment: Alarms: Peak Day
    '001' as 'Deployment'
    ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
    ,SUM(CAST([CountAlarms] AS BIGINT)) as 'Rate'
  FROM
    [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
  ORDER BY Rate DESC
  ) d ON m.[Deployment] = d.[Deployment]
JOIN
  (SELECT
    a.[Deployment]
    ,AVG(a.[Rate]) as 'Rate'
  FROM (
    SELECT -- Deployment: Alarms: Average
      '001' as 'Deployment'
      ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
      ,SUM(CAST([CountAlarms] AS BIGINT)) as 'Rate'
    FROM
      [LogRhythm_LogMart].[dbo].[StatsDeploymentCountsHour]
    WHERE
      [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
    ) a
  GROUP BY
    a.[Deployment]
  ) w ON m.[Deployment] = w.[Deployment]

UNION ALL

SELECT -- Mediator: MPS
  GETDATE() as 'Runtime'
  ,'Mediator' as 'Component'
  ,h.[Mediator] as 'ComponentName'
  ,'MPS' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[RateProcessedLogs] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[RateProcessedLogs] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM 
  (SELECT -- Mediator: Peak Minute
    mm.[MediatorID]
    ,mm.[Mediator]
    ,z.[DateTimeMst]
    ,mm.[RateProcessedLogs]/60 as 'RateProcessedLogs'
  FROM
  (SELECT
    mmm.[MediatorID]
    ,mmm.[Mediator]
    ,MAX(mmm.[RateProcessedLogs]) as 'RateProcessedLogs'
  FROM
    (SELECT 
      b.[MediatorID]
      ,b.[Name] as 'Mediator'
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM([CountProcessedLogs]) as 'RateProcessedLogs'
    FROM
      [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
      LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on smsc.[MediatorID] = b.[MediatorID]
    WHERE [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      b.[MediatorID]
      ,b.[Name]
      ,DATEADD(HH,-7,[StatDate])
    ) mmm
  GROUP BY
    mmm.[MediatorID]
    ,mmm.[Mediator]
    ) mm 
    LEFT JOIN
    (SELECT 
      b.[MediatorID]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM([CountProcessedLogs]) as 'RateProcessedLogs'
    FROM
      [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
      LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on smsc.[MediatorID] = b.[MediatorID]
    WHERE [StatDate] BETWEEN DATEADD(DD,-7,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      b.[MediatorID]
      ,DATEADD(HH,-7,[StatDate])
    ) z ON mm.[MediatorID] = z.[MediatorID] AND mm.[RateProcessedLogs] = z.[RateProcessedLogs]
  ) m 
JOIN
  (SELECT -- Mediator: Peak Hour
    mm.[MediatorID]
    ,mm.[Mediator]
    ,z.[DateTimeMst]
    ,mm.[RateProcessedLogs]
  FROM 
    (SELECT 
      a.[MediatorID]
      ,b.[Name] as 'Mediator'
      ,MAX([CountProcessedLogs])/3600 as 'RateProcessedLogs'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.MediatorID = b.MediatorID
    WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      a.[MediatorID]
      ,b.[Name] 
    ) mm 
    LEFT JOIN
    (SELECT 
      a.[MediatorID]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,MAX([CountProcessedLogs])/3600 as 'RateProcessedLogs'
      FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
      GROUP BY
      a.[MediatorID]
      ,DATEADD(HH,-7,[StatDate])
    ) z ON mm.[MediatorID] = z.[MediatorID] AND mm.[RateProcessedLogs] = z.[RateProcessedLogs]
  ) h ON m.[MediatorID] = h.[MediatorID]
JOIN 
  (SELECT -- Mediator: MPS: Peak Day
    mm.[MediatorID]
    ,mm.[Mediator]
    ,z.[DateTimeMst]
    ,mm.[Rate]/(3600*24) as 'Rate'
  FROM   
    (SELECT
      mmm.[MediatorID]
      ,mmm.[Mediator] as 'Mediator'
      ,MAX(mmm.[Rate]) as 'Rate'
    FROM 
      (SELECT
      a.[MediatorID]
      ,b.[Name] as 'Mediator'
      ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
      ,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.MediatorID = b.MediatorID
    WHERE
      [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      a.[MediatorID]
      ,b.[Name]
      ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate])))
     ) mmm
    GROUP BY
      mmm.[MediatorID]
      ,mmm.[Mediator]
    ) mm 
    LEFT JOIN
    (SELECT 
      a.[MediatorID]
      ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) as 'DateTimeMst'
      ,SUM(CAST([CountProcessedLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.MediatorID = b.MediatorID
    WHERE
      [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      a.[MediatorID]
      ,CONVERT(DATE,(DATEADD(HH,-7,[StatDate]))) 
    ) z ON mm.[MediatorID] = z.[MediatorID] AND mm.[Rate] = z.[Rate]
  ) d ON m.[MediatorID] = d.[MediatorID]
JOIN
  (SELECT -- Mediator: MPS: Average
    a.[MediatorID]
    ,b.[Name] as 'Mediator'
    ,AVG(CAST([CountProcessedLogs] AS BIGINT))/3600 as 'Rate'
  FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
    LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] b on a.MediatorID = b.MediatorID
  WHERE
    [StatDate] BETWEEN DATEADD(DD,-15,GETUTCDATE()) AND DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    a.[MediatorID]
    ,b.[Name] 
  ) w ON m.[MediatorID] = w.[MediatorID]

UNION ALL

SELECT -- Cluster: MPS
  GETDATE() as 'Runtime'
  ,'Cluster' as 'Component'
  ,h.[ClusterName] as 'ComponentName'
  ,'MPS' as 'Metric'
  ,m.[DateTimeMst] as 'PeakMinute'
  ,m.[Rate] as 'PeakMinuteRate'
  ,h.[DateTimeMst] as 'PeakHour'
  ,h.[Rate] as 'PeakHourRate'
  ,d.[DateTimeMst] as 'PeakDay'
  ,d.[Rate] as 'PeakDayRate'
  ,w.[Rate] as 'AvgRate'
FROM 
  (SELECT -- Cluster: MPS: Peak Minute
    mm.[ClusterID]
    ,mm.[ClusterName]
    ,z.[DateTimeMst]
    ,mm.[Rate]/60 as 'Rate'
  FROM
    (SELECT
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ,MAX(mmm.[Rate]) as 'Rate'
    FROM
    (SELECT
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM
      [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
      LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on smsc.[MediatorID] = dp.[MediatorID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-7,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,DATEADD(HH,-7,[StatDate])
    ) mmm
  GROUP BY
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ) mm 
    LEFT JOIN
    (SELECT
      dp.[ClusterID]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM
      [LogRhythm_LogMart].[dbo].[StatsMsgSourceCountsMinute] smsc
      LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSource] ms ON smsc.[MsgSourceID] = ms.[MsgSourceID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on smsc.[MediatorID] = dp.[MediatorID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-7,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,DATEADD(HH,-7,[StatDate])
    ) z ON mm.[ClusterID] = z.[ClusterID] AND mm.[Rate] = z.[Rate]
  ) m 
  JOIN
  (SELECT -- Cluster: MPS: Peak Hour
    mm.[ClusterID]
    ,mm.[ClusterName]
    ,z.[DateTimeMst]
    ,mm.[Rate]/3600 as 'Rate'
  FROM
    (SELECT
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ,MAX(mmm.[Rate]) as 'Rate'
    FROM
    (SELECT
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on a.MediatorID = dp.MediatorID
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,DATEADD(HH,-7,[StatDate])
    ) mmm
  GROUP BY
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ) mm
    LEFT JOIN
    (SELECT
      dp.[ClusterID]
      ,DATEADD(HH,-7,[StatDate]) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on a.MediatorID = dp.MediatorID
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,DATEADD(HH,-7,[StatDate])
    ) z ON mm.[ClusterID] = z.[ClusterID] AND mm.[Rate] = z.[Rate]
  ) h ON h.[ClusterID] = m.[ClusterID]
  JOIN 
  (SELECT -- Cluster: MPS: Peak Day
    mm.[ClusterID]
    ,mm.[ClusterName]
    ,z.[DateTimeMst]
    ,mm.[Rate]/86400 as 'Rate'
  FROM
    (SELECT
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ,MAX([Rate]) as 'Rate'
  FROM
    (SELECT
      dp.[ClusterID]
      ,dx.[ClusterName] 
      ,CONVERT(DATE,DATEADD(HH,-7,[StatDate])) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on a.MediatorID = dp.MediatorID
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,dx.[ClusterName]
      ,CONVERT(DATE,DATEADD(HH,-7,[StatDate]))
    ) mmm
  GROUP BY
    mmm.[ClusterID]
    ,mmm.[ClusterName]
    ) mm
    LEFT JOIN
    (SELECT
      dp.[ClusterID]
      ,CONVERT(DATE,DATEADD(HH,-7,[StatDate])) as 'DateTimeMst'
      ,SUM(CAST([CountOnlineLogs] AS BIGINT)) as 'Rate'
    FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
      LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on a.MediatorID = dp.MediatorID
      LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
    WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
    GROUP BY
      dp.[ClusterID]
      ,CONVERT(DATE,DATEADD(HH,-7,[StatDate]))
    ) z ON mm.[ClusterID] = z.[ClusterID] AND mm.[Rate] = z.[Rate]
  ) d ON m.[ClusterID] = d.[ClusterID]
  JOIN
  (SELECT -- Cluster: MPS: Average
    dp.[ClusterID]
    ,dx.[ClusterName]
    ,AVG(CAST([CountOnlineLogs] AS BIGINT))/3600 as 'Rate'
  FROM [LogRhythm_LogMart].[dbo].[StatsMediatorCountsHour] a
    LEFT JOIN [LogRhythmEMDB].[dbo].[Mediator] dp on a.MediatorID = dp.MediatorID
    LEFT JOIN [LogRhythmEMDB].[dbo].[NGPCluster] dx on dp.[ClusterID] = dx.[ClusterID]
  WHERE [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
  GROUP BY
    dp.[ClusterID]
    ,dx.[ClusterName]
  ) w ON m.[ClusterID] = w.[ClusterID]
-- ORDER BY 'Component' ASC, 'ComponentName' ASC
;
