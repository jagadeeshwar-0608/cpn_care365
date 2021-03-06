USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetCommissionPresciberReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <12-09-2016>

-- Description:	<Get sales prescriber reports>

-- CPN_GetCommissionPresciberReport 'null','null'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetCommissionPresciberReport]

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
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianId= po.physicianId
where  po.isactive = 1 and pt.categoryname like 'Primary' 
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
group by initials

--select phy.initials, count(distinct pbo.orderId) as medicare 
--into #medicare
--from payorbyorders pbo
--inner join patientOrders po on po.orderId  = pbo.orderId
--inner join productTables pt on pt.productId = po.itemId
--inner join physicians phy on phy.physicianid = po.physicianId
--inner join payors p on p.payorId = pbo.primarypayorId
--where  po.isactive =  1 and pt.categoryname like 'Primary' 
--and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
--and pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
--group by phy.initials

--select phy.initials,count(distinct pbo.orderId) as commercial 
--into #commercial
--from payorbyorders pbo
--inner join patientOrders po on po.orderId  = pbo.orderId
--inner join physicians phy on phy.physicianId = po.physicianId
--inner join productTables pt on pt.productId = po.itemId
--inner join payors p on p.payorId = pbo.primarypayorId 
--where po.isactive =  1 and pt.categoryname like 'Primary'
--and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
--and pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
--group by phy.initials

select phy.initials, sum(po.productQuntity * pt.commissionMosupply)/30 as commission
into #commission
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianId = po.physicianId
where po.isactive = 1 and pt.categoryname like 'Primary' and
convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate
group by initials



select distinct prac.legalname as practiceName, phy.initials as PhysicianName,s.initial as salesrepname,
 count(distinct po.orderId) as orders,
phy.physicianId,t.lastorder,
case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
when t.lastorder > 30 then 'Never Active' else 'Active' end as [status],
sum(po.productQuntity * convert(float,pt.medicareFreeSchedule)) as revenue,
convert(decimal(18,2),com.commission) as commission
--isnull(m.medicare,0) as medicare, isnull(c.commercial,0) as commercial
from practices prac
inner join patientOrders po on po.practiceId = prac.practiceid
inner join physicians phy on phy.physicianId = po.physicianId
inner join recordRelations rr on rr.practiceId = po.practiceId
inner join productTables pt on pt.productId = po.itemId
inner join salesRepInfoes s on s.salesrepInfoId = rr.SalesRepId
inner join #temp t on t.initials = phy.initials
--left join #medicare m on m.initials  = phy.initials
--left join #commercial c on c.initials = phy.initials
left join #commission com on com.initials  = phy.initials
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and rr.isactive = 1 and po.isactive = 1 and pt.categoryname like 'Primary'
group by prac.legalname,phy.initials,s.initial,phy.physicianid,t.lastOrder--,m.medicare, c.commercial
,com.commission

END


GO
