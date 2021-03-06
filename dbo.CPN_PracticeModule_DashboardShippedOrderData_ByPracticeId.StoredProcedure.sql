USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_DashboardShippedOrderData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <16-08-2016>
-- Description:	<Get dashboard shipped order>
-- [dbo].[CPN_PracticeModule_DashboardShippedOrderData_ByPracticeId] 'b6e76840-6424-4a84-82d1-f1d3f35fed0d'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_DashboardShippedOrderData_ByPracticeId]
	
		@practiceId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--- ToDay Value
select (select  ISNULL(sum(convert(float,prod.MedicareFreeSchedule) * convert(float,patorder.[ProductQuntity])),0)
--convert(float,count(ord.orderId)) 
 from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
INNER JOIN [dbo].[ProductTables] prod ON prod.ProductId=patorder.ItemId
where convert(date,ord.createdDate)  = convert(date,getdate())
--and ord.shipstatus = 'shipped' 
AND patorder.PracticeId=@practiceId AND patorder.IsActive=1 AND ord.IsActive=1)  as Today,

	--- This Week Value
(select 
--CAST(ISNULL(sum(patorder.productQuntity * patorder.productPrice), 0.00 ) AS FLOAT)
ISNULL(sum(convert(float,prod.MedicareFreeSchedule) * convert(float,patorder.[ProductQuntity])),0)
from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
INNER JOIN [dbo].[ProductTables] prod ON prod.ProductId=patorder.ItemId
where  
--ord.shipstatus = 'shipped' AND 
convert(date,ord.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))
AND convert(date,ord.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6)) 
AND patorder.PracticeId=@practiceId AND patorder.IsActive=1 AND ord.IsActive=1) as ThisWeek,

(select 
--CAST(ISNULL(sum(patorder.productQuntity * patorder.productPrice), 0.00 ) AS FLOAT)
ISNULL(sum(convert(float,prod.MedicareFreeSchedule) * convert(float,patorder.[ProductQuntity])),0)
from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
INNER JOIN [dbo].[ProductTables] prod ON prod.ProductId=patorder.ItemId

where 
--ord.shipstatus = 'shipped' and 
 convert(date,ord.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
AND convert(date,ord.createdDate) <= convert(date, getdate()) AND patorder.PracticeId=@practiceId
AND patorder.IsActive=1 AND ord.IsActive=1) as ThisMonth,

(select 
--CAST(ISNULL(sum(patorder.productQuntity * patorder.productPrice), 0.00 ) AS FLOAT)
ISNULL(sum(convert(float,prod.MedicareFreeSchedule) * convert(float,patorder.[ProductQuntity])),0)
from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
INNER JOIN [dbo].[ProductTables] prod ON prod.ProductId=patorder.ItemId

where 
--ord.shipstatus = 'shipped' and 

convert(date,ord.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)) 
AND convert(date,ord.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))
AND patorder.PracticeId=@practiceId AND patorder.IsActive=1 AND ord.IsActive=1) as LastMonth,

--------------------------------------------------------- ThisYear ----------------------------------
(select 
--CAST(ISNULL(sum(patorder.productQuntity * patorder.productPrice), 0.00 ) AS FLOAT)
ISNULL(sum(convert(float,prod.MedicareFreeSchedule) * convert(float,patorder.[ProductQuntity])),0)
from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
INNER JOIN [dbo].[ProductTables] prod ON prod.ProductId=patorder.ItemId

where 

--ord.shipstatus = 'shipped' and 

convert(date,ord.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
AND convert(date,ord.createdDate) <= convert(date, getdate()) AND patorder.PracticeId=@practiceId 
AND patorder.IsActive=1 AND ord.IsActive=1) as ThisYear
  
END

-- [dbo].[CPN_PracticeModule_DashboardShippedOrderData_ByPracticeId] '1E165131-54CF-403F-B8E8-28D353A60178'

GO
