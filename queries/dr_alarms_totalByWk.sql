-- ==========================
-- Deployment Review Queries
-- ==========================

-- Alarm Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Alarms: Total By Week
SELECT
  COUNT(a.[AlarmID]) as 'Count_Alarms'
FROM
  [LogRhythm_Alarms].[dbo].[Alarm] a
  LEFT OUTER JOIN [LogRhythm_Alarms].[dbo].[AlarmToMARCMsg] b ON a.AlarmID = b.AlarmID
  LEFT OUTER JOIN [LogRhythm_Events].[dbo].[Msg] c on b.[MARCMsgID] = c.[MsgID]
WHERE a.[AlarmDate] > DATEADD(DD,-7,GETDATE())
;
