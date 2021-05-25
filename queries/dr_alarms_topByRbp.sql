-- ==========================
-- Deployment Review Queries
-- ==========================

-- Alarm Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Alarms: Top by RBP
SELECT TOP 10
  abc.[Name] as 'Alarm_Name'
  ,abc.[RBP_Score] as 'RBP_Score'
  ,COUNT([AlarmID]) as 'Count_Alarms'       
FROM (
  SELECT
    a.[AlarmID]
    ,e.[Name]
    ,AVG(c.[Priority]) as 'RBP_Score'
  FROM 
    [LogRhythm_Alarms].[dbo].[Alarm] a
    LEFT OUTER JOIN [LogRhythm_Alarms].[dbo].[AlarmToMARCMsg] b ON a.AlarmID = b.AlarmID
    LEFT OUTER JOIN [LogRhythm_Events].[dbo].[Msg] c on b.[MARCMsgID] = c.[MsgID] AND a.AlarmID = b.AlarmID
    LEFT OUTER JOIN [LogRhythmEMDB].[dbo].[AIERule] d on a.[AlarmRuleID] = d.[AlarmRuleID]
    LEFT OUTER JOIN [LogRhythmEMDB].[dbo].[AlarmRule] e on a.[AlarmRuleID] = e.[AlarmRuleID]
  WHERE a.[AlarmDate] > DATEADD(DD,-7,GETDATE())
  GROUP BY 
    a.[AlarmID]
    ,e.[Name]
  ) abc
WHERE abc.[RBP_Score] IS NOT NULL
GROUP BY 
  abc.[Name]
  ,abc.[RBP_Score]
ORDER BY abc.[RBP_Score] DESC
;