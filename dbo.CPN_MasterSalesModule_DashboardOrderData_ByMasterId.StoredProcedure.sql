USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_DashboardOrderData_ByMasterId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <03-04-2017>
-- Description:	<Get dashboard order>
-- CPN_MasterSalesModule_DashboardOrderData_ByMasterId '33f0e6fc-557d-487c-9750-0edc0e779363'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_DashboardOrderData_ByMasterId]
	@mastersalesId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
select (select convert(float,count(distinct po.orderId))  from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid 
WHERE mr.[UserId]=@mastersalesId AND mr.IsActive=1 AND po.IsActive=1
AND convert(date,po.createdDate)  = convert(date,getdate()))  as Today,
(select convert(float,count(distinct po.orderId))   from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid 
WHERE mr.[UserId]=@mastersalesId AND mr.IsActive=1 AND po.IsActive=1
AND convert(date,po.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  
AND convert(date,po.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,
(select convert(float,count(distinct po.orderId))   from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid 
WHERE mr.[UserId]=@mastersalesId AND mr.IsActive=1 AND po.IsActive=1
AND convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
AND convert(date,po.createdDate) <= convert(date, getdate())) as ThisMonth,
(select convert(float,count(distinct po.orderId))   from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid 
WHERE mr.[UserId]=@mastersalesId AND mr.IsActive=1 AND po.IsActive=1
AND convert(date,po.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
AND convert(date,po.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))) as LastMonth,
(select convert(float,count(distinct po.orderId))   from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid 
WHERE mr.[UserId]=@mastersalesId AND mr.IsActive=1 AND po.IsActive=1
AND convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  
AND convert(date,po.createdDate) <= convert(date, getdate())) as ThisYear
END
GO
