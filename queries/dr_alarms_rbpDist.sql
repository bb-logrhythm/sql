-- ==========================
-- Deployment Review Queries
-- ==========================

-- Alarm Queries
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Alarms: RBP Distribution
SELECT
  abc.[RBP_Score] as 'RBP_Range'
  ,COUNT([AlarmID]) as 'Count_Alarms'       
FROM (
  SELECT 
    a.[AlarmID]
    ,CASE
      WHEN c.[Priority] BETWEEN 0 AND 20 THEN '0-20'
      WHEN c.[Priority] BETWEEN 21 AND 40 THEN '21-40'
      WHEN c.[Priority] BETWEEN 41 AND 60 THEN '41-60'
      WHEN c.[Priority] BETWEEN 61 AND 80 THEN '61-80'
      WHEN c.[Priority] BETWEEN 81 AND 100 THEN '81-100'
      WHEN c.[Priority] > 100 THEN '>100'
      END as RBP_Score
  FROM 
    [LogRhythm_Alarms].[dbo].[Alarm] a
    LEFT OUTER JOIN [LogRhythm_Alarms].[dbo].[AlarmToMARCMsg] b ON a.AlarmID = b.AlarmID
    LEFT OUTER JOIN [LogRhythm_Events].[dbo].[Msg] c on b.[MARCMsgID] = c.[MsgID]
  WHERE a.[AlarmDate] > DATEADD(DD,-7,GETDATE())
  ) abc
WHERE abc.[RBP_Score] IS NOT NULL
GROUP BY abc.[RBP_Score]
ORDER BY abc.[RBP_Score] ASC
;
