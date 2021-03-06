USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_DashboardWoundsData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <16-08-2016>
-- Description:	<Get dashboard wounds>
-- [dbo].[CPN_PracticeModule_DashboardWoundsData_ByPracticeId] 'B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_PracticeModule_DashboardWoundsData_ByPracticeId]

	@practiceId uniqueidentifier

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
where  po.practiceId = @practiceId  and
convert(date, o.createdDate) = convert(date,getdate()) and po.isactive = 1 ) a) as Today,

(select isnull(sum(wounds) ,0)
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.practiceId = @practiceId  and convert(date,o.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  and
convert(date,o.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6)) 
and po.isactive = 1 ) a) as ThisWeek,

(select isnull(sum(wounds) ,0)
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.practiceId = @practiceId  and convert(date,o.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
 and convert(date,o.createdDate) <= convert(date, getdate()) 
and po.isactive = 1 ) a) as ThisMonth,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.practiceId = @practiceId  and convert(date,o.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
 and convert(date,o.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)) 
and po.isactive = 1 ) a) as LastMonth,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.practiceId = @practiceId  and convert(date,o.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
 and convert(date,o.createdDate) <= convert(date, getdate()) 
and po.isactive = 1 ) a) as ThisYear,

(select isnull(sum(wounds) ,0) 
from (select distinct o.orderId, convert(float,o.orderWound) as wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
where po.practiceId = @practiceId  and po.isactive = 1 ) a) as TotalWounds




	/*
select (select isnull(round(convert(float,sum(convert(float,ord.orderWound)),2),2),0)  from Orders ord

INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

where convert(date,ord.createdDate)  = convert(date,getdate()) AND patorder.PracticeId=@practiceId)  as Today,



(select isnull(round(convert(float,sum(convert(float,ord.orderWound)),2),2),0)   from Orders ord

INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

 where convert(date,ord.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  and

 convert(date,ord.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6)) AND patorder.PracticeId=@practiceId) as ThisWeek,



(select isnull(round(convert(float,sum(convert(float,ord.orderWound)),2),2),0)   from Orders ord

INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

 where convert(date,ord.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 

 and convert(date,ord.createdDate) <= convert(date, getdate()) AND patorder.PracticeId=@practiceId) as ThisMonth,



(select isnull(round(convert(float,sum(convert(float,ord.orderWound)),2),2),0)   from Orders ord

INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

 where convert(date,ord.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))

 and convert(date,ord.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)) AND patorder.PracticeId=@practiceId) as LastMonth,



(select isnull(round(convert(float,sum(convert(float,ord.orderWound)),2),2),0)   from Orders ord

INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

 where convert(date,ord.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 

 and convert(date,ord.createdDate) <= convert(date, getdate()) AND patorder.PracticeId=@practiceId) as ThisYear,



 (select isnull(round(convert(float, sum(convert(float,ord.orderWound)),2),2),0))  as TotalWounds from Orders

 ord INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId

 AND patorder.PracticeId=@practiceId

 */




END



GO
