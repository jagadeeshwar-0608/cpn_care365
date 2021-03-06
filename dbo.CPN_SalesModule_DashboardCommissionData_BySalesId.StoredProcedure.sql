USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_DashboardCommissionData_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <2016-12-05>

-- Description:	<Sales rep dashboard commission>

-- CPN_SalesModule_DashboardCommissionData_BySalesId '7FF877CF-687F-44C8-AD8E-B7122D488FDC'

-- =============================================


CREATE PROCEDURE [dbo].[CPN_SalesModule_DashboardCommissionData_BySalesId]

	@salesRepId uniqueIdentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from



	-- interfering with SELECT statements.

	SET NOCOUNT ON;

   -- Insert statements for procedure here

select distinct convert(date,po.createdDate) as createdDate, po.orderId, pt.productDescription,

isnull(round(convert(float,convert(float,po.productQuntity) * convert(float, po.productPrice)),2),0) as Commission

   into #commissiondata

   from patientOrders po 


   inner join productTables pt on pt.productid = po.itemId


   inner join recordrelations rr on rr.practiceId  = po.practiceid


   where po.isactive = 1 and rr.isactive = 1

    and rr.salesrepid = @salesRepId


select (

select isnull(sum(Commission),0) from #commissionData c

where c.createdDate = convert(date,getdate()) ) as Today,



(select isnull(sum(Commission),0) from #commissionData c
where convert(date,c.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))  

AND convert(date,c.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,

(select isnull(sum(Commission),0) from #commissionData c

where convert(date,c.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 

AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisMonth,

(select isnull(sum(Commission),0) from #commissionData c

where convert(date,c.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))  

AND convert(date,c.createdDate) <= convert(date, getdate())) as ThisYear

END
GO
