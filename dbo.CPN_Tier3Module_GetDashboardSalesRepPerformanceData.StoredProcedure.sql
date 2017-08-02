USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Tier3Module_GetDashboardSalesRepPerformanceData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <18-04-2017>
-- Description:	<Get tier 3 dashboard sales rep performance data>
-- CPN_Tier3Module_GetDashboardSalesRepPerformanceData
-- =============================================
CREATE PROCEDURE [dbo].[CPN_Tier3Module_GetDashboardSalesRepPerformanceData]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select distinct sale.initial, po.orderId,
po.productQuntity * po.productPrice as rev, ui.LastName + ' ' + ui.FirstName as managerName
into #revenue
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
left join masteruserrelation mr on rr.SalesRepId = mr.SalesRepId
left join userInfo ui on mr. UserId = ui.AspNetUserId
where po.isactive = 1 and rr.isactive=1 --and mr.isactive = 1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())

select distinct initial, managerName into #manager from #revenue

select distinct sale.initial, po.orderId,
po.productQuntity * po.productPrice as rev
into #todayrevenue
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
where po.isactive = 1 and rr.isactive=1
and convert(date, po.createdDate) = convert(date, getdate())
select distinct sale.initial, po.orderId,
po.productQuntity * po.productPrice as rev
into #monthrevenue
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
where po.isactive = 1 and rr.isactive=1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())
select distinct sale.initial, isnull(count(distinct orderId),0) as orders 
--, po.productQuntity * po.productPrice as todayRev 
into #month
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
where po.isactive = 1 and rr.isactive=1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
and convert(date,po.createdDate) <= convert(date, getdate())
group by sale.Initial
select distinct sale.initial, isnull(count(distinct orderId),0) as orders 
--, po.productQuntity * po.productPrice as todayRev 
into #today
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
where po.isactive = 1 and rr.isactive=1
and convert(date, po.createdDate) = convert(date, getdate())
group by sale.initial --,po.productQuntity , po.productPrice
select distinct sale.initial, count(distinct orderId) as orders
--, po.productQuntity * po.productPrice as yearRev 
into #year
from patientOrders po 
inner join recordRelations rr 
on rr.practiceId = po.practiceId
inner join salesrepinfoes sale
on sale.salesRepInfoId = rr.salesRepId
where po.isactive = 1 and rr.isactive=1
and convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
and convert(date,po.createdDate) <= convert(date, getdate())
group by sale.initial --,po.productQuntity , po.productPrice
select initial, sum(rev) as monthRev
into #mRev
 from #monthRevenue
 group  by initial
 select initial, sum(rev) as todayRev
 into #tRev
 from #todayRevenue
 group by initial
 select initial, sum(rev) as yearRev
 into #yRev
 from #revenue
 group by initial
select top 6 r.initial, isnull(td.orders,0) as today --, sum(td.todayRev) 
,y.orders  as ytd, isnull(m.orders,0) as [month], isnull( sum(tr.todayRev),0) as todayRevenue, isnull(sum(mr.monthRev),0) as monthRevenue,
isnull(sum(r.yearRev),0) as ytdRevenue into #final
from #yRev r 
left join #today td on
r.initial = td.initial
left join #month m
on m.initial = r.initial
left join #year y on 
y.initial = r.initial
left join #tRev tr 
on tr.initial = r.initial
left join #mRev mr
on mr.initial = r.initial
group by r.initial, td.Orders,m.orders, --td.todayRev,
y.orders --,y.yearRev
order by ytdRevenue desc, today desc, ytd desc

select f.initial, f.today, f.ytd, f.[month], f.todayRevenue, f.monthRevenue, f.ytdRevenue, m.managerName  from 
#final f
inner join #manager m on f.initial = m.initial
order by ytdRevenue desc, today desc, ytd desc
END
-- CPN_GetDashboardSalesRepPerformanceData
GO
