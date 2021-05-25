-- ==========================
-- Deployment Review Queries
-- ==========================

-- Metrics Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- System Monitor Agents
SELECT
      -- sms.[SystemMonitorID]
      sm.[Name] as 'SystemMonitor'
      ,CASE 
            WHEN sm.[SystemMonitorType] = 1 THEN 'Windows' 
            WHEN sm.[SystemMonitorType] = 2 THEN 'Linux' 
            WHEN sm.[SystemMonitorType] = 3 THEN 'Solaris' 
            WHEN sm.[SystemMonitorType] = 4 THEN 'AIX' 
            WHEN sm.[SystemMonitorType] = 5 THEN 'HP-UX' 
            ELSE 'Unknown' 
            END AS 'LicenseType'
      ,h.[Name] as 'Host'
      ,h.[OSVersion] as 'HostOS'
      ,CASE WHEN sm.[RecordStatus] = 1 THEN 'Active' ELSE 'Retired' END AS 'Status'
      ,CASE 
            WHEN lic.[LicenseType] = 4 THEN 'Pro' 
            WHEN lic.[LicenseType] = 9 THEN 'Lite'
            ELSE 'Unlicensed' 
            END AS 'LicenseType'
      ,sms.[LastHeartbeat]
      ,sms.[Version]
      ,sms.[LastMediator]
      ,lswin.[CountLogSourcesWindows]
      ,lsall.[CountLogSourcesTotal]
      ,ratehour.[MaxProcessedRateHour]
      ,ratehour.[AvgProcessedRateHour]
      ,ratemin.[MaxProcessedRateMin]
      ,ratemin.[AvgProcessedRateMin]
      ,CASE WHEN sm.[SyslogServer] = 1 THEN 'enabled' ELSE 'disabled' END AS 'SyslogStatus'
      ,CASE WHEN sm.[NetflowServer] = 1 THEN 'enabled' ELSE 'disabled' END AS 'NetflowStatus'
      ,CASE WHEN sm.[SFlowServerEnabled] = 1 THEN 'enabled' ELSE 'disabled' END AS 'SFlowStatus'
      ,CASE WHEN sm.[SNMPTrapReceiver] = 1 THEN 'enabled' ELSE 'disabled' END AS 'SnmpStatus'
      ,CASE WHEN sm.[FileMonitor] = 1 THEN 'enabled' ELSE 'disabled' END AS 'FimStatus'
      ,CASE WHEN sm.[RIMEnabled] = 1 THEN 'enabled' ELSE 'disabled' END AS 'RimStatus'
      ,CASE WHEN sm.[DataDefender] = 1 THEN 'enabled' ELSE 'disabled' END AS 'DataDefenderStatus'
      ,CASE WHEN sm.[ProcessMonitor] = 1 THEN 'enabled' ELSE 'disabled' END AS 'ProcMonStatus'
      ,CASE WHEN sm.[NetworkConnectionMonitor] = 1 THEN 'enabled' ELSE 'disabled' END AS 'NetConMonStatus'
      ,CASE WHEN sm.[UnidirectionalAgentEnabled] = 1 THEN 'enabled' ELSE 'disabled' END AS 'OneWayDiodeStatus'
      ,CASE WHEN sm.[IsLoadBalanced] = 1 THEN 'enabled' ELSE 'disabled' END AS 'LoadBalanceStatus'
FROM [LogRhythmEMDB].[dbo].[SystemMonitorStatus] sms
      LEFT JOIN [LogRhythmEMDB].[dbo].[SystemMonitor] sm ON sms.[SystemMonitorID] = sm.[SystemMonitorID]
      LEFT JOIN [LogRhythmEMDB].[dbo].[Host] h ON sm.[HostID] = h.[HostID]
      LEFT JOIN (
            SELECT 
                  [LicenseID]
                  ,[MasterLicenseID]
                  ,[LicenseType]
                  ,[ComponentID]
            FROM [LogRhythmEMDB].[dbo].[SCLicense]
            WHERE (LicenseType = 4 OR LicenseType = 9) AND ComponentID > 0
            ) lic ON sms.[SystemMonitorID] = lic.[ComponentID]
      LEFT JOIN (
            SELECT
                  [SystemMonitorID]
                  ,COUNT(DISTINCT [MsgSourceID]) as 'CountLogSourcesWindows'
            FROM [LogRhythmEMDB].[dbo].[MsgSource] ms
                  LEFT JOIN [LogRhythmEMDB].[dbo].[MsgSourceType] mst ON ms.[MsgSourceTypeID] = mst.[MsgSourceTypeID]
            WHERE 
                  mst.[Name] LIKE 'MS%EVENT%'
                  AND ms.[RecordStatus] = 1
                  AND ms.[MsgSourceID] > 0
            GROUP BY
                  [SystemMonitorID]
            ) lswin ON sms.[SystemMonitorID] = lswin.[SystemMonitorID]
      LEFT JOIN (
            SELECT
                  [SystemMonitorID]
                  ,COUNT(DISTINCT [MsgSourceID]) as 'CountLogSourcesTotal'
            FROM [LogRhythmEMDB].[dbo].[MsgSource] ms
            WHERE 
                  ms.[RecordStatus] = 1
                  AND ms.[MsgSourceID] > 0
            GROUP BY
                  [SystemMonitorID]
            ) lsall ON sms.[SystemMonitorID] = lsall.[SystemMonitorID]
      LEFT JOIN (
            SELECT 
                  a.[SystemMonitorID]
                  ,(MAX([CountProcessedLogs])/3600) as MaxProcessedRateHour
                  ,(AVG(CAST([CountProcessedLogs] as BIGINT))/3600) as AvgProcessedRateHour
            FROM 
                  [LogRhythm_LogMart].[dbo].[StatsSystemMonitorCountsHour] a
            WHERE 
                  [StatDate] > DATEADD(DD,-15,GETUTCDATE()) AND [StatDate] <= DATEADD(HH,-1,GETUTCDATE())
            GROUP BY 
                  a.[SystemMonitorID]
            ) ratehour ON sms.[SystemMonitorID] = ratehour.[SystemMonitorID]
      LEFT JOIN (
            SELECT 
                  a.[SystemMonitorID]
                  ,(MAX([CountProcessedLogs])/60) as MaxProcessedRateMin
                  ,(AVG(CAST([CountProcessedLogs] as BIGINT))/60) as AvgProcessedRateMin
            FROM 
                  [LogRhythm_LogMart].[dbo].[StatsSystemMonitorCountsMinute] a
            GROUP BY 
                  a.[SystemMonitorID]
            ) ratemin ON sms.[SystemMonitorID] = ratemin.[SystemMonitorID]
WHERE 
      sms.[SystemMonitorID] > 0
;
