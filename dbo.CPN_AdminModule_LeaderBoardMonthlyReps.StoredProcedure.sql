USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_LeaderBoardMonthlyReps]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <29-03-2017>
-- Description:	<Get admin leader board reps>
-- CPN_AdminModule_LeaderBoardMonthlyReps
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_LeaderBoardMonthlyReps]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
DECLARE @SDate  DATE,
        @EDate    DATE

declare @totalOrders int

SELECT   @SDate = CONVERT(DATE,dateadd(dd,-(day(getdate())-1),getdate())) 
       SELECT  @EDate = CONVERT(DATE, getdate())
	--select distinct po.orderId, pt.productDescription,rr.salesrepid,
	--isnull(round(convert(float,convert(float,po.productQuntity) * convert(float, po.productPrice)),2),0) as revenue
 --  into #revenue
 --  from patientOrders po 
 --  inner join productTables pt on pt.productid = po.itemId
 --  inner join recordrelations rr on rr.practiceId  = po.practiceid
 --  where po.isactive = 1 and rr.isactive = 1
 --  and convert(date, po.CreatedDate) >= @SDate and convert(date, po.CreatedDate) <= @EDate
 --  group by rr.salesrepid, po.orderId, pt.productDescription, po.productQuntity, po.productPrice
 --  select round(sum(revenue), 2) as revenue, salesrepid into #repRevenue from #revenue
 --  group by salesrepid

 
	select count(distinct po.orderId) as orders, rr.SalesRepId into #orderReps
	from patientOrders po
	INNER JOIN RecordRelations rr on  rr.practiceId=po.practiceId 
	WHERE po.IsActive=1 AND rr.IsActive=1
	and convert(date, po.CreatedDate) >= @SDate and convert(date, po.CreatedDate) <= @EDate
	group by rr.SalesRepId
	order by orders desc

	select @totalOrders = sum(orders) from #orderReps

	select top 5 row_number() over(order by orders desc) as rank,  
	isnull(orders, 0) as orders, @totalOrders as TotalOrders
	--, convert(float, isnull(revenue, 0)) as revenue
	, sr.Initial as SalesRepName
	from salesRepInfoes sr
	inner JOIN #orderReps rr on  sr.salesRepInfoId = rr.SalesRepId
	--LEFT JOIN #repRevenue rep on  sr.salesRepInfoId = rep.SalesRepId

END

GO
