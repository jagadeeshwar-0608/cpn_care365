USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_GetDashboardProductPerformanceData_ByMasterId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <2016-12-05>
-- Description:	<Get sales rep dashboard product performance data>
-- CPN_SalesModule_GetDashboardProductPerformanceData_BySalesId '2302d261-2b52-4191-b413-493e113259f9'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_GetDashboardProductPerformanceData_ByMasterId]
	-- Add the parameters for the stored procedure here
	@mastersalesId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select distinct po.orderId,pt.productDescription,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission
into #commData
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join recordRelations rr on rr.practiceid = po.practiceid
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid
where 
po.isactive = 1 and rr.isactive = 1 and mr.[UserId]=@mastersalesId AND mr.IsActive=1
and pt.categoryname  = 'Primary'


select productDescription, ISNULL(sum(commission),0) as commission
into #commissionData
from #commData
group by productDescription


select top 5  pt.productDescription,count(distinct po.orderid) as orders
,ISNULL(c.Commission,0) Commission
 from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join recordRelations rr on rr.practiceId = po.practiceId
INNER JOIN [dbo].[MasterUserRelation] mr ON mr.[SalesRepId]=rr.salesrepid
left join #commissionData c on  c.productDescription = pt.productDescription
where mr.[UserId]=@mastersalesId AND mr.IsActive=1 and pt.categoryName = 'Primary' and pt.isactive = 1 and po.isactive = 1
group by pt.productDescription, c.commission
order by orders desc, c.commission desc

  


END


GO
