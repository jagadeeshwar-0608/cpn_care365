USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_DashboardRevenueData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <15-08-2016>
-- Description:	<Get dashboard order>
-- [dbo].[CPN_PracticeModule_DashboardRevenueData_ByPracticeId] '1e165131-54cf-403f-b8e8-28d353a60178'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_DashboardRevenueData_ByPracticeId]

	@practiceId uniqueidentifier
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select (select isnull(round(convert(float,sum(productPrice),2),2),0)  from patientOrders
 where convert(date,createdDate)  = getdate() AND patientOrders.PracticeId=@practiceId)  as Today,

(select isnull(round(convert(float,sum(productPrice),2),2),0)   from patientOrders 
where convert(date,createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0)) 
 and convert(date,createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6)) AND patientOrders.PracticeId=@practiceId) as ThisWeek,

(select isnull(round(convert(float,sum(productPrice),2),2),0)   from patientOrders 
where convert(date,createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
 and convert(date,createdDate) <= convert(date, getdate()) AND patientOrders.PracticeId=@practiceId) as ThisMonth,

(select isnull(round(convert(float,sum(productPrice),2),2),0)   from patientOrders
 where convert(date,createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
   and convert(date,createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))
    AND patientOrders.PracticeId=@practiceId) as LastMonth,

(select isnull(round(convert(float,sum(productPrice),2),2),0)   from patientOrders
 where convert(date,createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  
 and convert(date,createdDate) <= convert(date, getdate()) AND patientOrders.PracticeId=@practiceId) as ThisYear

   
END


GO
