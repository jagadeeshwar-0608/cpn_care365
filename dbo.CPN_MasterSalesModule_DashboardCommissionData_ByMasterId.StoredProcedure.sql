USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_DashboardCommissionData_ByMasterId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <2016-12-05>
-- Description:	<Sales rep dashboard commission>
-- CPN_MasterSalesModule_DashboardCommissionData_ByMasterId '33f0e6fc-557d-487c-9750-0edc0e779363'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_DashboardCommissionData_ByMasterId]
	@mastersalesId uniqueIdentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
select distinct convert(date,po.createdDate) as createdDate, po.orderId, pt.productDescription,isnull(round(convert(float, (po.productQuntity * po.ProductPrice)), 2),0) as Revenue
   into #commissiondata
   from patientOrders po 
   inner join productTables pt on pt.productid = po.itemId
   inner join recordrelations rr on rr.practiceId  = po.practiceid
   INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid
   where po.isactive = 1 and rr.isactive = 1
   and pt.categoryname = 'Primary' and mr.[UserId]=@mastersalesId AND mr.IsActive=1
select (
select isnull(sum(Revenue),0) from #commissionData c
where c.createdDate = convert(date,getdate()) ) as Today,
(select isnull(sum(Revenue),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  
AND convert(date,c.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,
(select isnull(sum(Revenue),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisMonth,
(select isnull(sum(Revenue),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  
AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisYear
END
GO
