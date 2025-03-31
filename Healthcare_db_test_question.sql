use Healthcare_DB

select * from He 

select * from dimDate
--How many rows of data are in the FactTable that include a Gross Charge greater than $100?

Select Count(*) as 'CountofRows' from FactTable
where FactTable.GrossCharge >100

--How many unique patients exist is the Healthcare_DB?
select count(distinct dimPatientPK) as 'uniquePatient' from dimPatient

--How many CptCodes are in each CptGrouping?
select cptGrouping, count(CptCode) as 'count_of_cptcode' from dimCptCode group by CptGrouping 

--How many physicians have submitted a Medicare insurance claim?

select 
count(distinct ProviderNpi) as 'count_OF_providers' from FactTable 
inner join dimPhysician 
on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
inner join dimPayer
on dimPayer.dimPayerPK=FactTable.dimPayerPK
where PayerName = 'Medicare'

--Calculate the Gross Collection Rate (GCR) for each
--	LocationName - See Below 
--	GCR = Payments divided GrossCharge
--	Which LocationName has the highest GCR?

select LocationName,format (-sum(Payment)/sum(GrossCharge),'P1') as 'GCR' from FactTable
inner join dimLocation
on dimLocation.dimLocationPK = FactTable.dimLocationPK
	GROUP BY LocationName
	order by LocationName desc

--How many CptCodes have more than 100 units?

select distinct CptCode from dimCptCode
inner join FactTable
on dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
group by CptCode having sum(CPTUnits)>100 


--Find the physician specialty that has received the highest
--amount of payments. Then show the payments by month for 
--this group of physicians.

select  dimDate.Month,FactTable.Payment,ProviderSpecialty from dimPhysician
inner join FactTable on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
inner join dimDate on dimDate.dimDatePostPK = FactTable.dimDatePostPK
order by FactTable.Payment desc

--How many CptUnits by DiagnosisCodeGroup are assigned to 
--	a "J code" Diagnosis (these are diagnosis codes with 
--	the letter J in the code)?
select DiagnosisCodeGroup,sum(CPTUnits) as 'cptunit' from FactTable
inner join dimDiagnosisCode on dimDiagnosisCode.dimDiagnosisCodePK =FactTable.dimDiagnosisCodePK
where DiagnosisCode like 'j%'
group by DiagnosisCodeGroup
order by 2 desc 

--You've been asked to put together a report that details 
--Patient demographics. The report should group patients
--into three buckets- Under 18, between 18-65, & over 65
--Please include the following columns:
--First and Last name in the same column--
--Email	
--Patient Age
--City and State in the same column
select	CONCAT(FirstName,' ',LastName) as 'PatientNname',Email,PatientAge,
case when PatientAge <18 then 'under 18'
when PatientAge between '18' and '65' then 'between 18-65'
when PatientAge>65 then 'over65'
else Null End as 'Agedemographic',
CONCAT(City,' ',State) as 'CityState'
from dimPatient

--How many dollars have been written off (adjustments) due
--to credentialing (AdjustmentReason)? Which location has the 
--highest number of credentialing adjustments? How many 
--physicians at this location have been impacted by 
--credentialing adjustments? What does this mean?
select distinct AdjustmentReason from dimTransaction

select LocationName,sum(-Adjustment) as 'dollar_write Off',
count(dimPhysician.dimPhysicianPK) as 'PhysicianCount'
from FactTable
inner join dimTransaction on dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
inner join dimLocation on dimLocation.dimLocationPK = FactTable.dimLocationPK
inner join dimPhysician on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
where AdjustmentReason = 'Credentialing'
group by LocationName

--What is the average patientage by gender for patients
--seen at Big Heart Community Hospital with a Diagnosis
--that included Type 2 diabetes? And how many Patients
--are included in that average?
select * from dimPatient
select * from dimDiagnosisCode
