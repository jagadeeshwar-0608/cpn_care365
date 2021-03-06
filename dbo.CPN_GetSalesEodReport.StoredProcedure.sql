USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesEodReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <17-09-2016>
-- Description:	<Get Sales end of the day report>
-- CPN_GetSalesEodReport '2017-01-01','2017-01-30'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetSalesEodReport] 
	@fromDate nvarchar(20)= null,
	@toDate nvarchar(20) = null
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

		select datename(dw,o.createdDate) as [dayofweek], convert(date,o.createdDate) as createdDate
		,convert(int,o.orderWound) as orderWounds, count(distinct o.orderId) as Orders,
		sum(po.productQuntity * po.productPrice) as Revenue, o.orderNumber
		into #general
		from orders o 
		inner join patientOrders po on po.orderId = o.orderId
		where convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isActive = 1
		group by datename(dw, o.createdDate), convert(date,o.createdDate), o.orderWound,o.orderNumber


		select  a.[dayofweek], a.createdDate as OrderDate, isnull(a.wounds,0) as TotalWounds,
		isnull(a.orders,0) as GrossOrders, a.revenue, isnull(b.medicare,0) as MedicareOrders, isnull(c.ppohmo,0) as ppoOrders,
		isnull(d.shippedOrders,0) shippedOrders

		from 

		(select [dayofweek], createdDate, sum(orderWounds) as wounds, sum(orders) as orders, sum(Revenue) as revenue
		from #general
		group by [dayOfWeek], CreatedDate) a
		left join 

		(select convert(date,o.createdDate) as createdDate, count(distinct o.orderId) as medicare
		from orders o 
		inner join payorbyorders pbo on pbo.orderId = o.orderId
		where pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
		and convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		group by convert(date,o.createdDate)) b
		on b.createdDate = a.createdDate
		left join 

		(select convert(date,o.createdDate) as createdDate, count(distinct o.orderId) as ppohmo
		from orders o 
		inner join payorbyorders pbo on pbo.orderId = o.orderId
		where pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
		and convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		group by convert(date,o.createdDate))c
		on c.createdDate = a.createdDate

		left join 

		(select convert(date,o.createdDate) as createdDate,
		 count(distinct o.orderid) as shippedOrders
		from orders o
		inner join patientOrders po on po.orderId = o.orderId
		where 
		--o.shipStatus = 'Shipped'		and 
		o.trackingnumber is not null and 
		convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isactive = 1
		group by convert(date,o.createdDate))d 
		on d.createdDate = a.createdDate

END




GO
