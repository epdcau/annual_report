declare @year int = 2014


select 
	year(calltime) yr, 
	PSJReporting.EugCrimeAnalyst.local_date_string(i.calltime) calltime,
	--calltime,
	i.inci_id, case when i.parent_id = '' then i.inci_id else i.parent_id end parent_id, 
	case when i.case_id = '' then null else i.case_id end case_id,
	case when rtrim(callsource) = 'SELF' then 1 else 0 end is_self,
	case when rtrim(city) = 'EUG' then 1 else 0 end is_eug,
	case when callsource = '' then null else rtrim(i.callsource) end callsource, 
	rtrim(i.nature) nature, rtrim(i.closecode) closecode, 
	(select top 1 x.descriptn from CADReporting.dbo.systab1 x where x.code_agcy = rtrim(ltrim(i.closecode)) and x.code_key in ('UDIS', 'CANC')) closed_as,
	datediff(second, calltime, firstdtm) secs_to_disp,
	datediff(second, calltime, firstarrv) secs_to_arrv,
	datediff(second, calltime, timeclose) secs_to_close,
	case when firstdtm is not null then 1 else 0 end disp,
	case when firstarrv is not null then 1 else 0 end arrv,
	geox, geoy, rtrim(geolwbt) beat,
	rtrim(n.name) neighborhood,
	(select x.inci_id, x.agency, x.calltime, x.nature, x.callsource from CADReporting.dbo.inmain x where inci_id = i.parent_id and i.parent_id != '' for json path, without_array_wrapper) parent_call,
	case when primeunit = '' then null else '_' + rtrim(primeunit) end primeunit,
	(select count(distinct unitcode) from CADReporting.dbo.incilog x where x.inci_id = i.inci_id and x.transtype = 'D') units_dispd,
	(select count(distinct unitcode) from CADReporting.dbo.incilog x where x.inci_id = i.inci_id and x.transtype = 'C') units_arrived

from CADReporting.dbo.inmain i
left join PSJReporting.CLCC.geom_neighbor n
on geometry::Point(i.geox, i.geoy, 2914).STWithin(n.geom) = 1
where year(calltime) = @year
and rtrim(agency) = 'EPD'
and rtrim(service) = 'LAW'
and closecode not in ('DUP', 'TEST', 'EERR')
and nature not like '%TEST%'
--and callsource not like 'SELF'
--and city like 'EUG'


