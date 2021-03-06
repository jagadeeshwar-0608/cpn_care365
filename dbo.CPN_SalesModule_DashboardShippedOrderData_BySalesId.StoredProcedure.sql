USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_DashboardShippedOrderData_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <16-08-2016>
-- Description:	<Get dashboard shipped order>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_DashboardShippedOrderData_BySalesId]

	@salesRepId uniqueidentifier
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT (SELECT convert(FLOAT,count(o.orderId)) FROM Orders o
INNER JOIN patientOrders po ON po.orderId=o.orderId
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId WHERE rr.SalesRepId= @salesRepId
AND convert(DATE,o.createdDate)  = getdate() and o.shipstatus = 'shipped')  as Today,

(select convert(float,count(o.orderId))   from Orders o
INNER JOIN patientOrders po ON po.orderId=o.orderId
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId WHERE rr.SalesRepId= @salesRepId
AND  o.shipstatus = 'shipped' and convert(date,o.createdDate)  >=  
convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  and 
convert(date,o.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,

(select convert(float,count(o.orderId))   from Orders o
INNER JOIN patientOrders po ON po.orderId=o.orderId
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId WHERE rr.SalesRepId= @salesRepId
AND o.shipstatus = 'shipped' and  convert(date,o.createdDate)  >=  
convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))  and 
convert(date,o.createdDate) <= convert(date, getdate())) as ThisMonth,

(select convert(float,count(o.orderId))   from Orders o
INNER JOIN patientOrders po ON po.orderId=o.orderId
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId WHERE rr.SalesRepId= @salesRepId
AND o.shipstatus = 'shipped' and convert(date,o.createdDate)  >= 
convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  and 
convert(date,o.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))) as LastMonth,

(select convert(float,count(o.orderId))   from Orders o
INNER JOIN patientOrders po ON po.orderId=o.orderId
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId WHERE rr.SalesRepId= @salesRepId
AND o.shipstatus = 'shipped' and convert(date,o.createdDate)  >=  
convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  and 
convert(date,o.createdDate) <= convert(date, getdate())) as ThisYear
   
END


GO
