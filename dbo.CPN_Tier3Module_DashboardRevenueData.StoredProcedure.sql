USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Tier3Module_DashboardRevenueData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <2017-04-15>
-- Description:	<Tier 3 dashboard revenue>
-- CPN_Tier3Module_DashboardRevenueData
-- =============================================
CREATE PROCEDURE [dbo].[CPN_Tier3Module_DashboardRevenueData]
	
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
   where po.isactive = 1
select (
select isnull(sum(Revenue),0) from #commissionData c
where c.createdDate = convert(date,getdate()) ) as Today,
(select isnull(sum(Revenue),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  
AND convert(date,c.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,
(select isnull(sum(Revenue),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisMonth,
(select isnull(round(sum(Revenue), 2),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  
AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisYear
END
GO
