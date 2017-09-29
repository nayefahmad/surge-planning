SELECT [ToFacilityLongName]
	, [TransferDate]
	, [ToNursingUnitCode]
	--, COUNT(*) AS num_cases 
FROM [ADTCMart].[ADTC].[vwTransferFact] 
WHERE [ToFacilityLongName]= 'Lions Gate Hospital' 
	AND [TransferDate] BETWEEN '2016-10-07' and '2016-10-11' 
--GROUP BY [ToFacilityLongName], [TransferDate], [ToNursingUnitCode]
ORDER BY [TransferDate], [ToNursingUnitCode]
; 