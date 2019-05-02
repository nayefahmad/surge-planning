--for LGH Holiday Surge Planning


--Census
select
FacilityLongName,
NursingUnitCode,
CensusDate
from adtcmart.adtc.vwcensusfact
where facilitylongname = 'Lions Gate Hospital'
and censusdate between '2018-03-29' and '2018-04-03'



--ED Visits
select
StartDate, count(ETLAuditID) as '#'
from EDMart.dbo.vwEDVisitIdentifiedRegional
where FacilityShortName = 'LGH'
and StartDate between '2018-03-29' and '2018-04-03'
group by StartDate
order by 1


--Admits and Transfers
SELECT [ToFacilityLongName]
	, [TransferDate]
	, [ToNursingUnitCode]
	--, COUNT(*) AS num_cases 
FROM [ADTCMart].[ADTC].[vwTransferFact] 
WHERE [ToFacilityLongName]= 'Lions Gate Hospital' 
	AND [TransferDate] BETWEEN '2018-03-29' and '2018-04-03' 
--GROUP BY [ToFacilityLongName], [TransferDate], [ToNursingUnitCode]


union all

SELECT [AdmissionFacilityLongName]
	, [AdjustedAdmissionDate]
	, [AdmissionNursingUnitCode]
FROM [ADTCMart].[ADTC].[vwAdmissionDischargeFact]
WHERE [AdmissionFacilityLongName] = 'Lions Gate Hospital'
AND [AdjustedAdmissionDate] BETWEEN '2018-03-29' and '2018-04-03' 

