declare @year int = 2019


select
	year(l.date_occu) yr, 
	l.inci_id case_id, 
	c.chrgcnt charge_seq,
	rtrim(c.chrgdesc) charge, 
	--(select inci_id from CADReporting.dbo.inmain x where x.case_id = l.inci_id and x.case_id != '' and x.agency = 'EPD' for json path) inci_id,
	PSJReporting.EugCrimeAnalyst.local_date_string(PSJReporting.EugCrimeAnalyst.fix_datetime(l.date_occu, l.hour_occu)) occur_dt,
	rtrim(c.ucr_code) ucr_code,
	upper(u.ucr_categ) ucr_cat,
	rtrim(u.ucr_group) ucr_group,
	rtrim(replace(u.ucr_desc, u.ucr_group + ' - ', '')) ucr_desc,
	rtrim(l.reportedas) reported_as,
	(select rtrim(descriptn) from RMSReporting.dbo.systab2 x where x.code_agcy = l.csstatus and x.code_key = 'CASS') case_status,
	rtrim(l.csstatus) csstatus, 
	(select case when x.descriptn = 'NO BIAS' then null else x.descriptn end from RMSReporting.dbo.systab2 x where c.hatebias = x.code_agcy and x.code_key = 'MOTI') bias,
	isnull( (
		select sex, rtrim(name_type) type
		from RMSReporting.dbo.lwnames x
		where x.lwmainid = l.lwmainid
		and replace((',' + replace(x.vic_crime, ' ', ',') + ','), ',,', ',') like '%,' +  cast(c.chrgcnt as varchar(100)) + ',%'
		and name_id != 0
		and name_type != 'B'
		for json path
	), '[]') vic_lst,
	rtrim(l.tract) beat,
	rtrim(n.name) neighborhood,
	l.geox / 100.0 geox,
	l.geoy / 100.0 geoy

from RMSReporting.dbo.lwmain l
inner join RMSReporting.dbo.lwchrg c 
on l.lwmainid = c.lwmainid
left join PSJReporting.EugCrimeAnalyst.rms_ucr_convert u
on c.ucr_code = u.ucr_code
left join PSJReporting.CLCC.geom_neighbor n
on geometry::Point(l.geox / 100.0, l.geoy / 100.0, 2914).STWithin(n.geom) = 1
where year(l.date_occu) = @year
and agency = 'EPD'
and l.offense not like 'VOIDED%'





