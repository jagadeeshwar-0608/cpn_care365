USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetDashboardPracticePerformanceData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <21-10-2016>

-- Description:	<Get dashboard provider performance data>

-- CPN_GetDashboardPracticePerformanceData

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetDashboardPracticePerformanceData]

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;


select distinct prac.[LegalName] practiceName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #revenue
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1 
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())


select distinct prac.[LegalName] practiceName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #monthRevenue
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1 
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())

select distinct prac.[LegalName] practiceName,
po.orderId,
po.productQuntity * po.productPrice as rev
into #todayRevenue
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1 
and convert(date, po.createdDate) = convert(date, getdate())


select practiceName, sum(rev) as tRev 
into #tRev
from #todayrevenue 
group by practiceName

select practiceName, sum(rev) as mRev 
into #mRev
from #monthrevenue 
group by practiceName


select practiceName, sum(rev) as yRev 
into #yRev
from #revenue 
group by practiceName



select distinct prac.[LegalName] practiceName,
isnull(count(distinct orderId),0) as orders 
into #today
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1
and convert(date, po.createdDate) = convert(date, getdate())
group by prac.[LegalName]

select distinct prac.[LegalName] practiceName,
isnull(count(distinct orderId),0) as orders 
into #month
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())
group by prac.[LegalName]


select distinct prac.[LegalName] practiceName,
isnull(count(distinct orderId),0) as orders 
into #year
from patientOrders po 
INNER JOIN Practices prac on prac.PracticeId=po.PracticeId
where po.isactive = 1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())
group by prac.[LegalName]





select top 6 r.practiceName, isnull(td.orders,0) as today 
,y.orders  as ytd, isnull(m.orders,0) as [month], isnull( sum(tr.tRev),0) as todayRevenue, isnull(sum(mr.mRev),0) as monthRevenue,
isnull(sum(r.yRev),0) as ytdRevenue from 
#yRev r 
left join #today td on
r.practiceName = td.practiceName
left join #month m
on m.practiceName = r.practiceName
left join #year y on 
y.practiceName = r.practiceName
left join #tRev tr 
on tr.practiceName = r.practiceName
left join #mRev mr
on mr.practiceName = r.practiceName
group by r.practiceName, td.Orders,m.orders, y.orders 
order by ytdRevenue desc, today desc, ytd desc

END



GO
