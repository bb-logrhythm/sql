-- ==========================
-- Deployment Review Queries
-- ==========================

-- Alarm Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Alarms: By Day
SELECT
  CONVERT(DATE,(DATEADD(HH,-7,a.[AlarmDate]))) as 'Date'
  ,COUNT(a.[AlarmID]) as 'Count_Alarms'
FROM
  [LogRhythm_Alarms].[dbo].[Alarm] a
  LEFT OUTER JOIN [LogRhythm_Alarms].[dbo].[AlarmToMARCMsg] b ON a.AlarmID = b.AlarmID
  LEFT OUTER JOIN [LogRhythm_Events].[dbo].[Msg] c on b.[MARCMsgID] = c.[MsgID]
WHERE a.[AlarmDate] > DATEADD(DD,-7,GETDATE())
GROUP BY CONVERT(DATE,(DATEADD(HH,-7,a.[AlarmDate])))
ORDER BY 'Date' ASC
;
