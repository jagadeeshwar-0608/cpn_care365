USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_AdminModule_GetMDCommissionReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <12-09-2016>
-- Description:	<Get sales prescriber reports>
-- CPNDevice_AdminModule_GetMDCommissionReport '2017-01-01','2017-01-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_AdminModule_GetMDCommissionReport]
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
AS
BEGIN
	
	SET NOCOUNT ON;
	declare @fDate date
	declare @tDate date
	if @fromDate = 'null'
	begin
	set @fDate = '1900-01-01'
	end
	else
	begin
	set @fDate = @fromDate
	end
	if @toDate = 'null'
	begin
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end
	
 
select distinct phy.initials,
min(datediff(d, convert(date,mo.createdDate),convert(date,getdate()))) as lastorder
into #temp
from MobileOrderDetail mob 
INNER JOIN MobileOrder mo on mob.MobileOrderId = mo.MobileOrderId
INNER JOIN practices prac on prac.practiceId= mo.practiceId
INNER JOIN physicians phy on phy.physicianId= mo.PrescriberId
where  mob.isactive = 1 and mo.isactive = 1
and convert(date,mo.createdDate) >= @fDate 
and convert(date,mo.createdDate) <= @tDate
group by initials

select distinct phy.initials,mo.MobileOrderId,convert(int,isnull(mob.Wounds,0)) as wounds
into #wounds
 from MobileOrder mo
inner join MobileOrderDetail mob on mob.MobileOrderId = mo.MobileOrderId
inner join physicians phy on phy.physicianId = mo.PrescriberId
where convert(date,mo.createddate) >= @fdate 
and convert(date,mo.createddate) <= @tDate and mo.isactive = 1
group by phy.initials,mo.MobileOrderId, mob.Wounds

select distinct initials, sum(wounds) as orderWounds into #woundsdata
from #wounds group by initials

select distinct phy.initials,mo.MobileOrderId,phy.physicianId,
mob.PrimaryProductQuantity * mob.PrimaryProductPrice as revenue
into #revenue
from MobileOrder mo
inner join MobileOrderDetail mob on mob.MobileOrderId = mo.MobileOrderId
inner join practices prac on prac.practiceid = mo.practiceId
inner join physicians phy on phy.physicianId = mo.PrescriberId
where  convert(date,mo.createddate) >= @fdate 
and convert(date,mo.createddate) <= @tDate and
mob.isactive = 1


select physicianId, sum(revenue) as revenue into #revenueData from #revenue
group by physicianId


select distinct prac.legalname as practiceName, phy.initials as PhysicianName,s.initial as salesrepname,
count(distinct po.orderId) as orders,
phy.physicianId,t.lastorder,
case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
when t.lastorder > 30 then 'Never Active' else 'Active' end as [status],
convert(float,r.revenue) as Revenue,
orderWounds

from practices prac
inner join patientOrders po on po.practiceId = prac.practiceid
inner join physicians phy on phy.physicianId = po.physicianId
inner join recordRelations rr on rr.practiceId = po.practiceId
inner join salesRepInfoes s on s.salesrepInfoId = rr.SalesRepId
left join #temp t on t.initials = phy.initials
left join #woundsdata w on w.initials = phy.initials
left join #revenueData r on r.physicianId = phy.physicianId
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and rr.isactive = 1 and po.isactive = 1 and phy.isactive = 1
group by prac.legalname,phy.initials,s.initial,phy.physicianid,t.lastOrder,w.orderwounds,r.revenue

END

--select sales.Initial SalesRep, prac.LegalName practiceName,phy.[Initials] physicianName,
-- CONVERT(DATE,mo.CreatedDate) orderDate,
-- InvoiceNumber, min(datediff(d, convert(date,mo.createdDate),convert(date,getdate()))) as lastorder
--, count(distinct mob.MobileOrderId) as orders
--,SUM(mob.[PrimaryProductQuantity] * pt.commissionMosupply)/30 AS commission
-- from MobileOrder mo
--INNER JOIN MobileOrderDetail mob on mob.MobileOrderId=mo.MobileOrderId
--INNER JOIN productTables pt on pt.[ProductId] = mob.PrimaryProductId
--INNER JOIN RecordRelations rr on rr.PracticeId =mo.PracticeId
--INNER JOIN Practices prac on prac.PracticeId=mo.PracticeId
--INNER JOIN salesRepInfoes sales on sales.salesRepInfoId =rr.SalesRepId 
--INNER JOIN Physicians phy on phy.[PhysicianId]=mo.[PrescriberId]
--WHERE mo.isactive=1
--GROUP BY sales.Initial , InvoiceNumber ,prac.LegalName ,mo.CreatedDate , phy.[Initials]
--ORDER BY mo.CreatedDate desc

GO
