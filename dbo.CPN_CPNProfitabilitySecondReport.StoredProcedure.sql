USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_CPNProfitabilitySecondReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <18-09-2016>
-- Description:	<Get CPN Profitablity Second Report>
-- CPN_CPNProfitabilitySecondReport 'Mar','2017','2017-03-01','2017-03-31'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_CPNProfitabilitySecondReport]
	-- Add the parameters for the stored procedure here
	@monthName nvarchar(20),
	@year int,
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
	
	--select dbo.getMonthId('Mar')

declare @monthId int
set @monthId = dbo.getMonthId(@monthName)
    -- Insert statements for procedure here
select convert(date,po.createdDate) as orderDate,
count(distinct po.orderId) as orders, 
sum(po.productQuntity * po.productPrice) as Revenue,
round(sum(po.productQuntity * convert(float,isnull(pt.cpncogs,0))),2) as costofgoods
into #orderData
from patientOrders po 
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId
where convert(date, po.createdDate) >= @fDate 
and convert(date,po.createddate) <= @tDate
and datepart(mm,po.createdDate)= @monthId and datepart(yy,po.createdDate) = @year
and po.isactive = 1 
group by convert(date,po.createdDate)
select convert(date,po.createdDate) as orderDate, 
isnull(sum(po.freightAmt),0) as shipcost
into #shipping
from orders po
where convert(date, po.createdDate) >= @fDate 
and convert(date,po.createddate) <= @tDate
and datepart(mm,po.createdDate)= @monthId and datepart(yy,po.createdDate) = @year
and po.isactive = 1 
 group by convert(date,po.createdDate)
select convert(date,po.createdDate) as orderDate,
 convert(float, isnull(sum(po.productQuntity * pt.CommissionMoSupply/30),0)) as commission
 into #commission
from patientOrders po
inner join productTables pt 
on pt.productId = po.itemId and pt.categoryname like 'Primary'
where convert(date, po.createdDate) >= @fDate 
and convert(date,po.createddate) <= @tDate
and datepart(mm,po.createdDate)= @monthId and datepart(yy,po.createdDate) = @year
and po.isactive = 1 
group by convert(date,po.createdDate)
select o.orderDate, o.orders ,o.revenue,o.costofgoods,
s.shipcost as shipping, c.commission
from #orderData o
inner join #shipping s on s.orderDate = o.orderDate
inner join #commission c on c.orderdate = o.orderDate
END
GO
