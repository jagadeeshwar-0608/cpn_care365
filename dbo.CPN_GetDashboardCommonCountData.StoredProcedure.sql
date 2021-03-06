USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetDashboardCommonCountData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-21-2016>
-- Description:	<Get dashboard number count data>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetDashboardCommonCountData]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   create table  #temp(orders int ,patients int,practices int,products int,physicians int,revenue float, salesRep int ,
    orderShipped int , orderPending int , orderDelivered int, ordersBillable int)
insert into #temp (orders,patients,practices,products,physicians,revenue,salesRep,orderShipped,orderPending,orderDelivered,ordersBillable)

select (select count(distinct orderId) from patientOrders WHERE IsActive=1) a ,
(select count(patientId) from patientInfoes WHERE IsActive=1) as b,

(select count(distinct prac.practiceId) from practices prac
inner join recordRelations rel on rel.practiceId = prac.practiceId
--inner join salesRepinfoes sale on sale.salesrepinfoid =rel.salesrepid
inner join physicians phy on phy.physicianId = rel.physicianId
where prac.isactive = 1 and rel.isactive = 1 and phy.isactive = 1) as c ,

(select count(productId) from productTables WHERE IsActive=1) as d,

(select count(distinct phy.PhysicianId) from practices prac
inner join recordRelations rel on rel.practiceId = prac.practiceId
--inner join salesRepinfoes sale on sale.salesrepinfoid =rel.salesrepid
inner join physicians phy on phy.physicianId = rel.physicianId
where prac.isactive = 1 and rel.isactive = 1 and phy.isactive = 1) as e,

(select sum(productQuntity * productPrice) from patientOrders WHERE IsActive=1) as f,
(select COUNT(salesRepInfoId) from salesRepInfoes WHERE IsActive=1) as g,

(select count(distinct po.orderId) from patientOrders po
inner join orders o on o.orderId = po.orderId
  WHERE po.IsActive=1 AND shipstatus='Shipped') as h,
(select count(distinct po.orderId) from patientOrders po
 inner join orders o on o.orderId = po.orderId
 WHERE po.IsActive=1 AND (shipstatus ='Processing' or shipstatus is null)) as i,
(select count(distinct po.orderId) from patientOrders po
inner join orders o on o.orderId = po.orderId
 WHERE po.IsActive=1 AND shipstatus='Delivered') as j,
 (select count(distinct po.orderId) from patientOrders po
 inner join orders o on o.orderid = po.orderid
 where po.isactive = 1 and shipstatus ='Delivered'
 and orderBillDate is null) as k
  
  
select * from #temp

END


GO
