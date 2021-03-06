USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_LeaderBoardReps]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <29-03-2017>
-- Description:	<Get sales leader board reps>
-- CPN_SalesModule_LeaderBoardReps
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_LeaderBoardReps]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
select distinct po.orderId, pt.productDescription,rr.salesrepid,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float, po.productPrice)),2),0) as revenue
   into #revenue
   from patientOrders po 
   inner join productTables pt on pt.productid = po.itemId
   inner join recordrelations rr on rr.practiceId  = po.practiceid
   where po.isactive = 1 and rr.isactive = 1
   group by rr.salesrepid, po.orderId, pt.productDescription, po.productQuntity, po.productPrice
   select round(sum(revenue), 2) as revenue, salesrepid into #repRevenue from #revenue
   group by salesrepid
select count(distinct po.orderId) as orders, rr.SalesRepId into #orderReps
from patientOrders po
INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
WHERE po.IsActive=1 AND rr.IsActive=1
group by rr.SalesRepId
select row_number() over(order by revenue desc) as rank,  
isnull(orders, 0) as orders, convert(float, isnull(revenue, 0)) as revenue, sr.Initial as SalesRepName
from salesRepInfoes sr
LEFT JOIN #orderReps rr on  sr.salesRepInfoId = rr.SalesRepId
LEFT JOIN #repRevenue rep on  sr.salesRepInfoId = rep.SalesRepId
where IsLeaderBoardMember = 1
END
GO
