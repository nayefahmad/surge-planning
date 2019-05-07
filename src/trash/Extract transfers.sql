SELECT [ToFacilityLongName]
	, [TransferDate]
	, [ToNursingUnitCode]
	--, COUNT(*) AS num_cases 
FROM [ADTCMart].[ADTC].[vwTransferFact] 
WHERE [ToFacilityLongName]= 'Lions Gate Hospital' 
	AND [TransferDate] BETWEEN '2017-11-09' and '2017-11-15' 
--GROUP BY [ToFacilityLongName], [TransferDate], [ToNursingUnitCode]


union all

SELECT [AdmissionFacilityLongName]
	, [AdjustedAdmissionDate]
	, [AdmissionNursingUnitCode]
FROM [ADTCMart].[ADTC].[vwAdmissionDischargeFact]
WHERE [AdmissionFacilityLongName] = 'Lions Gate Hospital'
AND [AdjustedAdmissionDate] BETWEEN '2017-11-09' and '2017-11-15' 
