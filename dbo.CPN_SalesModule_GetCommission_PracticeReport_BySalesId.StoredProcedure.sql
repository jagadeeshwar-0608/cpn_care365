USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetCommission_PracticeReport_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <29-03-2017>
-- Description:	<Get sales prescriber reports>
-- CPN_SalesModule_GetCommission_PracticeReport_BySalesId '7ff877cf-687f-44c8-ad8e-b7122d488fdc','2017-04-01','2017-04-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_GetCommission_PracticeReport_BySalesId]
	@salesId uniqueidentifier ,
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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
	--drop table #temp
	--drop table #temp2
	 
select distinct phy.initials,
min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder
into #temp
from patientOrders po 
inner join practices prac on prac.practiceId= po.practiceId
inner join physicians phy on phy.physicianId= po.physicianId
inner join recordRelations rr on rr.practiceId = po.practiceId
where  po.isactive = 1  and rr.isactive = 1 and rr.salesrepId = @salesId
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
group by initials
select distinct phy.initials,o.orderId,convert(int,isnull(orderWound,0)) as wounds
into #wounds
 from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join physicians phy on phy.physicianId = po.physicianid
inner join recordRelations rr on rr.practiceId = po.practiceId
where convert(date,o.createddate) >= @fdate and rr.isactive = 1 and rr.salesrepId = @salesId
and convert(date,o.createddate) <= @tDate and po.isactive = 1
group by phy.initials,o.orderId, o.orderWound
select distinct initials, sum(wounds) as orderWounds into #woundsdata
from #wounds group by initials
select distinct phy.initials,o.orderId,phy.physicianId,productDescription,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,po.ProductPrice)),2),0) as revenue
into #revenue
 from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join practices prac on prac.practiceid = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianid
inner join recordrelations rr on rr.practiceId = po.practiceId
inner join producttables pt on pt.productId = po.itemId
where rr.isactive = 1 and rr.salesrepid = @salesId and  convert(date,o.createddate) >= @fdate 
and convert(date,o.createddate) <= @tDate and 
--pt.categoryname like 'Primary' and
po.isactive = 1
select physicianId, sum(Commission) as Commission , sum(revenue) as revenue into #revenueData from #revenue
group by physicianId
select distinct prac.legalname as practiceName, phy.initials as PhysicianName,s.initial as salesrepname,
 count(distinct po.orderId) as orders, po.practiceId,
phy.physicianId,t.lastorder,
case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
when t.lastorder > 30 then 'Never Active' else 'Active' end as [status],
convert(decimal(18,2),r.Commission) as Commission,
convert(float,r.revenue) as revenue,
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
and rr.isactive = 1 and po.isactive = 1 and phy.isactive = 1 and s.salesrepinfoId = @salesId
group by prac.legalname,phy.initials,s.initial,phy.physicianid,t.lastOrder,w.orderwounds,r.Commission,r.revenue, po.practiceId
END
GO
