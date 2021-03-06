USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_DashboardCommissionData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <15-08-2016>
-- Description:	<Get dashboard order>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_DashboardCommissionData]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 select (
select isnull(sum(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2)),0) as Commission
   from patientOrders po 
   inner join productTables pt on pt.productid = po.itemId
   where po.isactive = 1 and convert(date,po.createdDate)  = convert(date,getdate())
   and pt.categoryname like 'Primary')  as Today,


(select isnull(sum(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2)),0) as Commission
   from patientOrders po
   inner join productTables pt on pt.productId = po.itemId
   where po.isactive = 1 and pt.categoryname like 'Primary' and  
   convert(date,po.createdDate)  >=  convert(date,dateadd(week, datediff(week, 0, getdate()), 0))
    and convert(date,po.createdDate) <= convert(date, dateadd(week, datediff(week, 0, getdate()), 6))) as ThisWeek,


(select isnull(sum(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2)),0) as Commission
   from patientOrders po
   inner join productTables pt on pt.productid = po.itemId
    where  po.isactive = 1 and pt.categoryname like 'Primary' and  
	convert(date,po.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))  and convert(date,po.createdDate) <= convert(date, getdate())) as ThisMonth,
	
(select isnull(sum(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2)),0) as Commission 
  from patientOrders po
  inner join productTables pt on pt.productid = po.itemid
   where  po.isactive = 1 and pt.categoryname like 'Primary' 
   and convert(date,po.createdDate)  >=  convert(date,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
   and convert(date,po.createdDate) <= convert(date, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))) as LastMonth,

(select isnull(sum(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2)),0) as Commission
 from patientOrders po 
 inner join producttables pt on pt.productid = po.itemId
 where po.isactive = 1 and pt.categoryname like 'Primary' and
 convert(date,po.createdDate)  >=  convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0)) 
  and convert(date,po.createdDate) <= convert(date, getdate())) as ThisYear

   
END


GO
