-- Marsh - Log Source Details
-- --
-- List:
-- 	- Solaris
-- 	- Office 365
-- 	- Box
-- 	- Qualys
-- 	- Azure
-- 	- AWS

-- -- Log Source Type with Full Name
-- SELECT
-- 	[MsgSourceTypeID]
-- 	,[Name]
-- 	,[FullName]
-- 	,[Abbreviation]
-- 	,[ShortDesc]
-- FROM 
-- 	[LogRhythmEMDB].[dbo].[MsgSourceType] mst
-- ;

-- -- Mapping Log Source Type to Regex + Sort Order
-- SELECT 
-- 	[MsgSourceTypeID]
-- 	,[MPERuleRegexID]
-- 	,[SortOrder]
-- FROM
-- 	[LogRhythmEMDB].[dbo].[MPERuleToMsgSourceType] mpemst
-- ;

-- -- MPE Rule with Full Name
-- SELECT
-- 	mpe.[MPERuleID]
-- 	,mpe.[MPERuleRegexID]
-- 	,mpe.[CommonEventID]
-- 	,mpe.[Name]
-- 	,mpe.[FullName]
-- 	,mpe.[BaseRule]
-- 	,mpe.[ShortDesc]
-- 	,mpe.[LongDesc]
--   FROM 
--   	[LogRhythmEMDB].[dbo].[MPERule] mpe
-- ;

-- -- Common Event Details
-- SELECT
-- 	ce.[CommonEventID]
-- 	,ce.[MsgClassID]
-- 	,ce.[Name]
-- 	,ce.[ShortDesc]
-- 	,ce.[DefRiskRating]
-- FROM
-- 	[LogRhythmEMDB].[dbo].[CommonEvent] ce
-- ;

-- -- RegEx Details
-- SELECT
-- 	regex.[MPERuleRegexID]
-- 	,regex.[RegexTagged]
-- FROM
-- 	[LogRhythmEMDB].[dbo].[MPERuleRegex] regex
-- ;

-- Aggregated
SELECT
	mst.[FullName] as 'LogSourceType.FullName'
	,mst.[Abbreviation] as 'LogSourceType.Abbrev'
	,ce.[Name] as 'CommonEvent.Name'
	,mpe.[FullName] as 'Rule.FullName'
	,mpemst.[SortOrder] as 'Rule.SortOrder'
	,regex.[RegexTagged] as 'Rule.RegEx'
FROM 
	[LogRhythmEMDB].[dbo].[MsgSourceType] mst
	RIGHT JOIN [LogRhythmEMDB].[dbo].[MPERuleToMsgSourceType] mpemst ON mst.[MsgSourceTypeID] = mpemst.[MsgSourceTypeID]
	RIGHT JOIN [LogRhythmEMDB].[dbo].[MPERule] mpe ON mpemst.[MPERuleRegexID] = mpe.[MPERuleRegexID]
	LEFT JOIN [LogRhythmEMDB].[dbo].[CommonEvent] ce ON mpe.[CommonEventID] = ce.[CommonEventID]
	LEFT JOIN [LogRhythmEMDB].[dbo].[MPERuleRegex] regex ON mpemst.[MPERuleRegexID] = regex.[MPERuleRegexID]
WHERE
	UPPER(mst.[FullName]) LIKE UPPER('%AWS%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%AZURE%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%SOLARIS%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%API - BOX EVENT%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%QUALYS%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%365%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%SKYHIGH%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%SYMANTEC CSP%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%ZSCALER%')
	OR UPPER(mst.[FullName]) LIKE UPPER('%CISCO AMP%')
ORDER BY
	[LogSourceType.Abbrev] asc
	,[LogSourceType.FullName] asc
	,[Rule.SortOrder] asc
;