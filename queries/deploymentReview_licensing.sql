-- ==========================
-- Deployment Review Queries
-- ==========================

-- Licensing Evaluation
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~

--script to find max 24 hour average Processed Logs for each month
--10/19/2017 JR

use LogRhythm_LogMart
go

--insert Processed Logs Count and next 24 hour Summary Processed Logs Count into temp table
create table #Counts (
    StatDate           datetime,
	[Month]            tinyint,
	[Year]             smallint,
	CountProcessedLogs bigint,
	Summary24Hour      bigint);

insert #Counts (
    StatDate,
	[Month],
	[Year],
    CountProcessedLogs,
	Summary24Hour)
select s.StatDate,
       [Month] = datepart(month,s.StatDate),
	   [Year] = datepart(year,s.StatDate),
	   s.CountProcessedLogs,
	   Summary24Hour = (select sum(cast(CountProcessedLogs as bigint))
	                    from dbo.StatsDeploymentCountsHour s2
						where s2.StatDate between s.StatDate and dateadd(hh,23,s.StatDate)  --sum for 24 hour period
						  and datepart(year,s.StatDate) = datepart(year,s2.StatDate)        --dont' go over a year boundary
						  and datepart(month,s.StatDate) = datepart(month,s2.StatDate))     --don't go over a month boundary
from dbo.StatsDeploymentCountsHour s
order by s.StatDate

--Find the maximum sum for each month/year
select [Month],
       [Year],
	   MaxLogCount = max(Summary24Hour)
into #MaxValues
from #Counts
group by [Month], [Year];

--Display Maximum Average Processed Logs for each Month and Year
select [Peak 24h TimeStamp] = c.StatDate,
       m.[Month],
       m.[Year],
	   --c.CountProcessedLogs,
	   [Max Average Processed Logs] = m.maxLogCount / 86400 --calculate MPS
from #Counts c inner join
     #MaxValues m on m.[Month] = c.[Month] and
	                 m.[Year] = c.[Year]
where m.MaxLogCount = c.Summary24Hour
order by c.StatDate desc

--drop temp tables
drop table #Counts
drop table #MaxValues

