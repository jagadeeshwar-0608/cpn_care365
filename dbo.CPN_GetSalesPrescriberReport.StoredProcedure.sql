USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesPrescriberReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <12-09-2016>
-- Description:	<Get sales prescriber reports>
-- CPN_GetSalesPrescriberReport '2017-01-01','2017-01-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetSalesPrescriberReport]
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
min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder
into #temp
from patientOrders po 
inner join practices prac on prac.practiceId= po.practiceId
inner join physicians phy on phy.physicianId= po.physicianId
where  po.isactive = 1 
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
group by initials

select distinct phy.initials,o.orderId,convert(int,isnull(orderWound,0)) as wounds
into #wounds
 from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join physicians phy on phy.physicianId = po.physicianid
where convert(date,o.createddate) >= @fdate 
and convert(date,o.createddate) <= @tDate and po.isactive = 1
group by phy.initials,o.orderId, o.orderWound

select distinct initials, sum(wounds) as orderWounds into #woundsdata
from #wounds group by initials



select distinct phy.initials,o.orderId,phy.physicianId,
po.productQuntity * productPrice as revenue
into #revenue
 from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join practices prac on prac.practiceid = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianid
where  convert(date,o.createddate) >= @fdate 
and convert(date,o.createddate) <= @tDate and
po.isactive = 1


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

GO
