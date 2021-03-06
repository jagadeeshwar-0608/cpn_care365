USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_CPNProfitabilityFirstReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <18-09-2016>
-- Description:	<Get CPN Profitablity First Report>
-- CPN_CPNProfitabilityFirstReport '2017-03-01','2017-03-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_CPNProfitabilityFirstReport]
	-- Add the parameters for the stored procedure here
	@fromDate nvarchar(20)= null,
	@toDate nvarchar(20)  = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @fDate date
	declare @tDate date
	if @fromDate = 'null'
	begin
	set @fDate = '1900-01-01'
	end
	else
	begin
	set @fDate = @fromDate
	end
	if @toDate = 'null'
	begin
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end
    -- Insert statements for procedure here
select datepart(mm,po.createdDate) as monthId,
	 datepart(yy,po.createdDate) as [Year],
	substring( datename(mm,po.createdDate),1,3) as MonthName,
	sum(convert(float,isnull(po.[orderwound],0))) totalWounds
into #orderWoundsData
from orders po 
where convert(date, po.createdDate) >= @fDate 
and convert(date,po.createddate) <= @tDate and po.isactive = 1
group by datepart(mm,po.createdDate),
	 datepart(yy,po.createdDate) ,
	substring( datename(mm,po.createdDate),1,3)
select	datepart(mm,po.createdDate) as monthId,
		datepart(yy,po.createdDate) as [Year],
		substring( datename(mm,po.createdDate),1,3) as MonthName,
		count(distinct po.orderId) as orders, 
		sum(po.productQuntity * po.productPrice) as Revenue,
		round(sum(po.productQuntity * convert(float,isnull(pt.cpncogs,0))),2) as costofgoods
		into #orderData
		from patientOrders po 
		inner join orders o on o.orderId = po.orderId
		inner join productTables pt on pt.productId = po.itemId
		where convert(date, po.createdDate) >= @fDate 
		and convert(date,po.createddate) <= @tDate and po.isactive = 1
		and o.isactive = 1 
		group by datepart(mm,po.createdDate),
		datepart(yy,po.createdDate) ,
		substring( datename(mm,po.createdDate),1,3)
select datepart(mm,po.createdDate) as monthId,
	   datepart(yy,po.createdDate) as [Year],
	   substring( datename(mm,po.createdDate),1,3) as MonthName, 
		isnull(sum(po.freightAmt),0) as shipcost
		into #shipping
		from orders po
		where convert(date, po.createdDate) >= @fDate 
		and convert(date,po.createddate) <= @tDate and po.isactive = 1
		group by datepart(mm,po.createdDate),
		datepart(yy,po.createdDate) ,
		substring( datename(mm,po.createdDate),1,3)
--select  datepart(mm,po.createdDate) as monthId,
--		datepart(yy,po.createdDate) as [Year],
--		substring( datename(mm,po.createdDate),1,3) as MonthName,
--		convert(float, isnull((sum(po.productQuntity * po.productPrice) * 0.15),0)) as commission
--		into #commission
--		from patientOrders po
--		inner join productTables pt 
--		on pt.productId = po.itemId and pt.categoryname like 'Primary'
--		where convert(date, po.createdDate) >= @fDate 
--		and convert(date,po.createddate) <= @tDate and po.isactive = 1 and pt.isactive=1
--		group by datepart(mm,po.createdDate),
--	 datepart(yy,po.createdDate) ,
--	substring( datename(mm,po.createdDate),1,3)
select o.monthId, o.[Year],o.[monthname], o.orders,o.revenue,o.costofgoods,
s.shipcost as shipping, w.totalWounds, convert(float, isnull((o.revenue * 0.15),0)) as commission
from #orderData o
inner join #shipping s on s.monthId = o.monthId
--inner join #commission c on c.monthId = o.monthId
INNER JOIN #orderWoundsData w on w.monthId = o.monthId
END
-- CPN_CPNProfitabilityFirstReport '2017-01-01','2017-01-30'
GO
