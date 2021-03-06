USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesPrescriberReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <12-09-2016> 
-- Description:	<Get sales prescriber reports>
-- CPN_GetSalesPrescriberReportByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetSalesPrescriberReportByPracticeId]

	@practiceId uniqueidentifier,
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
where prac.practiceId = @practiceId and po.isactive = 1
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
group by initials

select phy.initials, count(distinct pbo.orderId) as medicare 
into #medicare
from payorbyorders pbo
inner join patientOrders po on po.orderId  = pbo.orderId
inner join physicians phy on phy.physicianid = po.physicianId
inner join payors p on p.payorId = pbo.primarypayorId
where po.practiceId = @practiceId  and po.isactive =  1
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
group by phy.initials

select phy.initials,count(distinct pbo.orderId) as commercial 
into #commercial
from payorbyorders pbo
inner join patientOrders po on po.orderId  = pbo.orderId
inner join physicians phy on phy.physicianId = po.physicianId
inner join payors p on p.payorId = pbo.primarypayorId
where po.practiceId = @practiceId  and po.isactive =  1
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
group by phy.initials


select phy.initials, sum(po.productQuntity *  convert(float, pt.medicareFreeschedule)) as revenue
into #feeschedule
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianid = po.physicianId
where po.isactive = 1
and po.practiceId = @practiceId
group by phy.initials



select prac.legalname as practiceName, phy.initials as PhysicianName,s.initial as salesrepname,
 count(distinct po.orderId) as orders,
phy.physicianId,t.lastorder,
case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
when t.lastorder > 30 then 'Never Active' else 'Active' end as [status],
f.revenue as revenue,
isnull(m.medicare,0) as medicare, isnull(c.commercial,0) as commercial
from practices prac
inner join patientOrders po on po.practiceId = prac.practiceid
inner join physicians phy on phy.physicianId = po.physicianId
inner join recordRelations rr on rr.practiceId = po.practiceId
inner join productTables pt on pt.productId = po.itemId
inner join salesRepInfoes s on s.salesrepInfoId = rr.SalesRepId
inner join #temp t on t.initials = phy.initials
left join #medicare m on m.initials  = phy.initials
left join #commercial c on c.initials = phy.initials
left join #feeschedule f on f.initials = phy.initials
where prac.practiceId = @practiceId
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and rr.isactive = 1 and po.isactive = 1
group by prac.legalname,phy.initials,s.initial,phy.physicianid,t.lastOrder,m.medicare, c.commercial,f.revenue


END


GO
