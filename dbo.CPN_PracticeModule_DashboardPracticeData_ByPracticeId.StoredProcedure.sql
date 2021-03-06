USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_DashboardPracticeData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <16-08-2016>
-- Description:	<Get dashboard PRACTICE>
-- [dbo].[CPN_PracticeModule_DashboardPracticeData_ByPracticeId] 'e1954389-9f35-4f2d-a3a3-f7e3ece315ba'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_DashboardPracticeData_ByPracticeId]
	
	@practiceId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
select distinct orderId, pract.createdDate into #po
from practices pract
INNER JOIN patientOrders patorder on pract.practiceId=patorder.practiceId
where patorder.PracticeId=@practiceId
AND patorder.IsActive=1 and pract.IsActive = 1


select (select ISNULL(convert(float,sum(o.[PrimaryPaidAmount])),0)  
from #po pract
INNER JOIN orders o on o.OrderId=pract.OrderId
where convert(date,pract.createdDate)  = convert(date,getdate()))  as Today,
(select ISNULL(convert(float,sum(o.[PrimaryPaidAmount])),0)  
from #po pract
INNER JOIN orders o on o.OrderId=pract.OrderId -- added on 01/17/17
where convert(date,pract.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  
AND convert(date,pract.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,
(select ISNULL(convert(float,sum(o.[PrimaryPaidAmount])),0)  
from #po pract
INNER JOIN orders o on o.OrderId=pract.OrderId -- added on 01/17/17
where convert(date,pract.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))  
AND convert(date,pract.createdDate) <= convert(date, getdate()) ) as ThisMonth,
(select ISNULL(convert(float,sum(o.[PrimaryPaidAmount])),0)  
from #po pract
INNER JOIN orders o on o.OrderId=pract.OrderId -- added on 01/17/17
where convert(date,pract.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
AND convert(date,pract.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))) as LastMonth,
(select ISNULL(convert(float,sum(o.[PrimaryPaidAmount])),0)  
from #po pract
INNER JOIN orders o on o.OrderId=pract.OrderId -- added on 01/17/17
where convert(date,pract.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
AND convert(date,pract.createdDate) <= convert(date, getdate())) as ThisYear
END
GO
