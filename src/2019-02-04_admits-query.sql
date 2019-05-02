

SELECT AdmissionFacilityLongName
	, AdjustedAdmissionDate
	, AdmissionNursingUnitCode
	, AdmissionNursingUnitDesc
	, count(*) 

FROM [ADTCMart].[ADTC].[vwAdmissionDischargeFact]
WHERE [AdmissionFacilityLongName]= 'Lions Gate Hospital' 
	AND AdjustedAdmissionDate BETWEEN '2018-02-09' and '2018-02-13' 

group by [AdmissionFacilityLongName]
	, AdjustedAdmissionDate
	, [AdmissionNursingUnitCode]
	, [AdmissionNursingUnitDesc]

ORDER BY AdjustedAdmissionDate
	, [AdmissionNursingUnitCode]
	, [AdmissionNursingUnitDesc];
