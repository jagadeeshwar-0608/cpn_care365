USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetDashboardProviderPerformanceData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <21-10-2016>

-- Description:	<Get dashboard provider performance data>

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetDashboardProviderPerformanceData]

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



select distinct phy.initials as physicianName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #revenue
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1 
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())


select distinct phy.initials as physicianName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #monthRevenue
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1 
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())

select distinct phy.initials as physicianName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #todayRevenue
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1 
and convert(date, po.createdDate) = convert(date, getdate())


select physicianName, sum(rev) as tRev 
into #tRev
from #todayrevenue 
group by physicianName

select physicianName, sum(rev) as mRev 
into #mRev
from #monthrevenue 
group by physicianName


select physicianName, sum(rev) as yRev 
into #yRev
from #revenue 
group by physicianName



select distinct phy.initials as physicianName,
isnull(count(distinct orderId),0) as orders 
into #today
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1
and convert(date, po.createdDate) = convert(date, getdate())
group by phy.initials

select distinct phy.initials as physicianName,
isnull(count(distinct orderId),0) as orders 
into #month
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())
group by phy.initials


select distinct phy.initials as physicianName,
isnull(count(distinct orderId),0) as orders 
into #year
from patientOrders po 
INNER JOIN physicians phy on phy.PhysicianId= po.PhysicianId
where po.isactive = 1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())
group by phy.initials





select top 6 r.physicianName, isnull(td.orders,0) as today 
,y.orders  as ytd, isnull(m.orders,0) as [month], isnull( sum(tr.tRev),0) as todayRevenue, isnull(sum(mr.mRev),0) as monthRevenue,
isnull(sum(r.yRev),0) as ytdRevenue from 
#yRev r 
left join #today td on
r.physicianName = td.physicianName
left join #month m
on m.physicianName = r.physicianName
left join #year y on 
y.physicianName = r.physicianName
left join #tRev tr 
on tr.physicianName = r.physicianName
left join #mRev mr
on mr.physicianName = r.physicianName
group by r.physicianName, td.Orders,m.orders, y.orders 
order by ytdRevenue desc, today desc, ytd desc


END



GO
