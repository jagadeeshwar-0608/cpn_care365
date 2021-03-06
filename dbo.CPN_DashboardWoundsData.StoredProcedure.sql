USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_DashboardWoundsData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <16-08-2016>

-- Description:	<Get dashboard wounds>

-- =============================================

CREATE PROCEDURE [dbo].[CPN_DashboardWoundsData]

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



	select 
(select isnull(sum(wounds) ,0)
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where convert(date, o.createdDate) = convert(date,getdate()) and po.isactive = 1 ) a) as Today,

(select isnull(sum(wounds) ,0)
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where convert(date,o.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  and
convert(date,o.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6)) 
and po.isactive = 1 ) a) as ThisWeek,

(select isnull(sum(wounds) ,0)
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where convert(date,o.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
 and convert(date,o.createdDate) <= convert(date, getdate()) 
and po.isactive = 1 ) a) as ThisMonth,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where convert(date,o.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
 and convert(date,o.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)) 
and po.isactive = 1 ) a) as LastMonth,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where convert(date,o.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
 and convert(date,o.createdDate) <= convert(date, getdate()) 
and po.isactive = 1 ) a) as ThisYear,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.isactive = 1 ) a) as TotalWounds






   

END


GO
