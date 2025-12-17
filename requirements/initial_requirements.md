** Data sources in-scope **

The majority of our data will be in ProSolution, which is fairly well designed and normalised and there are standard unique identifiers for students, courses, classes, teachers etc. The potential issues are then when we join to the external data sources, e.g. ALPs and 6 Dimensions. Those are on course level rather than student level, and there is an "official" id for each course from the DfE, but there are edge cases and exceptions. 
Regarding data quality issues, the results data from our MIS system should be accurate. We import final results from the exam boards and they are thoroughly checked. The issues are more likely to be around student classification, e.g. has the student been correctly flagged for Free Meals, or bursary etc.

** Guidance on likely target data model **

I think generally our data structures are pretty straightforward, particularly for the MVP. I've attached an example SQL query which we use to show course level results. My understanding is that for Looker we would want this unaggregated and then do the aggregation on the dashboards, but it gives you an example of the sort of thing we are looking at. There aren't very many tables that make up this data set, the only slightly more complex one is "StudentExtendedData" which is actually a view which I created to keep track of things we track regularly, e.g. AccessPlus which is actually a combination of several fields from a few different tables. But that would be easy enough to recreate in BigQuery, and a good example of a set of terms that would need to be defined in LookerLM.


```sql
select o.AcademicYearID, o.Code, o.Name, o.QualID,
count(*) as Cohort,

SUM( sed.ED) as ED,
SUM(sed.SEN) as 'SEN+AA',
SUM(sed.PPorFCM) as PPorFCM,

SUM(CASE WHEN sd.sex like 'M' THEN 1 ELSE 0 END) as 'Male',
SUM(CASE WHEN sd.sex like 'F' THEN 1 ELSE 0 END) as 'Female'

,sum(case when e.grade = 'A*' then 1 else 0 end) as [A*]
,sum(case when e.grade = 'A' then 1 else 0 end) as [A]
,sum(case when e.grade = 'B' then 1 else 0 end) as [B]
,sum(case when e.grade = 'C' then 1 else 0 end) as [C]
,sum(case when e.grade = 'D' and o.OfferingTypeID in (1, 2, 4, 8, 9) then 1 else 0 end) as [D]
,sum(case when e.grade = 'E' then 1 else 0 end) as [E]
,sum(case when e.grade = 'U' then 1 else 0 end) as [U]
--,sum(case when e.grade in ('X', '') or e.grade is null then 1 else 0 end) as [X]
,sum(case when e.grade in  ('A*','A') then 1 else 0 end) as [A*-A]
,sum(case when e.grade in  ('A*','A','B') then 1 else 0 end) as [A*-B]
,sum(case when e.grade in  ('A*','A','B','C') then 1 else 0 end) as [A*-C]
,sum(case when e.grade in  ('A*','A','B','C','D','E') then 1 else 0 end) as [A*-E]

,SUM(case when a.AverageGcse = 0 or a.AverageGcse is null then 1 else 0 end) as 'n/a'
,SUM(case when a.AverageGcse > 0 and a.AverageGcse < 4.77 then 1  else 0 end) as low
,SUM(case when a.AverageGcse between 4.77 and 6.09 then 1 else 0 end) as mid
,SUM(case when a.AverageGcse > 6.09 then 1 else 0 end) as high

,CAST(ROUND(AVG( CASE WHEN a.AverageGcse <> 0 THEN a.AverageGcse ELSE NULL END),2) as Decimal(8,2)) as AvGCSECohort

from ProSolution.dbo.offering as o inner join
	 ProSolution.dbo.Enrolment as e on o.OfferingID = e.OfferingID inner join
	 ProSolution.dbo.StudentDetail as sd on e.StudentDetailID = sd.StudentDetailID inner join
	 MISApplications.dbo.StudentExtendedData as sed on sd.StudentDetailID = sed.StudentDetailID left outer join
	 focus.dbo.AverageGcse as a on sd.StudentID = a.StudentID inner join
	 ProSolution.dbo.CourseHeader as ch on o.CourseHeaderID = ch.CourseHeaderID 

where  e.CompletionStatusID in (1,2)
	and o.QualID is not null
	and o.QualID not like 'enrich'
	and o.qualid not like 'zwr%'
	and o.qualid not like '%tutor%'

	and o.studyyear = o.duration

	--and o.name like '%fine%'

	and sd.AcademicYearID in ('23/24','24/25')
	and o.OfferingTypeID in (1,2)

	--and e.grade not like '' and e.grade not like 'X' and e.grade is not null

	and o.CourseHeaderID  in -- to only get courses we still run
	(
	select o.CourseHeaderID
		from prosolution.dbo.offering as o


		where o.AcademicYearID = '23/24'
	)

group by ch.Code, o.AcademicYearID, o.code, o.name, o.qualid
order by ch.code, o.QualID, o.AcademicYearID
```

