USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetDashboardRecentOrdersData_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <21-10-2016>
-- Description:	<Get dashboard recent orders data>
-- CPN_SalesModule_GetDashboardRecentOrdersData_BySalesId '7FF877CF-687F-44C8-AD8E-B7122D488FDC'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_GetDashboardRecentOrdersData_BySalesId] 
@salesRepId uniqueidentifier	
AS
BEGIN
	SET NOCOUNT ON;
select  po.orderId, po.productQuntity * po.productPrice as revenue, o.orderNumber
into #revenueData 
from patientOrders po
inner join recordRelations rr on rr.practiceid= po.practiceid
inner join orders o on o.orderId = po.orderid
where rr.isactive = 1 and po.isactive =1 and
rr.SalesRepId = @salesRepId
group by po.orderId, po.productQuntity, po.productPrice, o.orderNumber
select orderId,sum(revenue) as revenue, orderNumber 
into #revData
from #revenueData
group by orderId,orderNumber
SELECT top 5 convert(date,po.createdDate) as createdDate,o.ordernumber, phy.initials as PhysicianName, round(convert(float,Revenue), 2) as Revenue, round(convert(float, (revenue * 0.11)), 2) as Commission
from patientOrders po
inner join physicians phy on phy.physicianId = po.physicianId
inner join recordRelations rr on rr.practiceid= po.practiceid
inner join orders o on o.orderId = po.orderid
inner join #revData rd on rd.orderId = po.orderid
where rr.isactive = 1 and po.isactive =1 and
rr.SalesRepId = @salesRepId
group by convert(date,po.createdDate), po.orderid, phy.initials,o.orderNumber,rd.revenue
order by createdDate desc, ordernumber desc
END
-- CPN_SalesModule_GetDashboardRecentOrdersData_BySalesId '7FF877CF-687F-44C8-AD8E-B7122D488FDC'
GO
