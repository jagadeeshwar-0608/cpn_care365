USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesEodReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <17-09-2016>

-- Description:	<Get Sales end of the day report>

-- CPN_GetSalesEodReportByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', '2017-01-01','2017-01-30'
-- select * from practices where practiceid='B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetSalesEodReportByPracticeId] 
	@practiceId uniqueidentifier,
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
		sum(po.productQuntity * convert(float,medicareFreeSchedule)) as Revenue, o.orderNumber
		--,sum(convert(float,medicareFreeSchedule) * convert(float,po.[ProductQuntity])) as FeeSchedule
		--,'NULL' as FeeSchedule
		
		into #general
		from orders o 
		inner join patientOrders po on po.orderId = o.orderId
		inner JOIN [dbo].[ProductTables] prod on prod.ProductId=po.ItemId
		where convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isActive = 1 AND po.PracticeId= @practiceId AND prod.IsActive=1
		group by datename(dw, o.createdDate), convert(date,o.createdDate), o.orderWound,o.orderNumber
		--,prod.medicareFreeSchedule,po.[ProductQuntity]


		select  a.[dayofweek], a.createdDate as OrderDate, isnull(a.wounds,0) as TotalWounds,
		isnull(a.orders,0) as GrossOrders, a.revenue as FeeSchedule, isnull(b.medicare,0) as MedicareOrders, isnull(c.ppohmo,0) as ppoOrders,
		isnull(d.shippedOrders,0) shippedOrders 
		--, ISNULL(a.FeeSchedule,0) as FeeSchedule

		from 

		(select [dayofweek], createdDate, sum(orderWounds) as wounds, sum(orders) as orders, convert(decimal(18,2),sum(Revenue)) as revenue
		
		from #general
		group by [dayOfWeek], CreatedDate) a
		left join 

		(select convert(date,o.createdDate) as createdDate, count(distinct o.orderId) as medicare
		from orders o 
		inner join payorbyorders pbo on pbo.orderId = o.orderId
		INNER JOIN patientorders po on po.orderid=o.orderid
		where pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
		and convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isactive=1 and po.PracticeId= @practiceId
		group by convert(date,o.createdDate)) b
		on b.createdDate = a.createdDate
		left join 

		(select convert(date,o.createdDate) as createdDate, count(distinct o.orderId) as ppohmo
		from orders o 
		inner join payorbyorders pbo on pbo.orderId = o.orderId
		INNER JOIN patientorders po on po.orderid=o.orderid
		where pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
		and convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isactive=1 and po.PracticeId= @practiceId
		group by convert(date,o.createdDate))c
		on c.createdDate = a.createdDate

		left join 

		(select convert(date,o.createdDate) as createdDate,
		 count(distinct o.orderid) as shippedOrders
		from orders o
		inner join patientOrders po on po.orderId = o.orderId
		where 
		--o.shipStatus = 'Shipped'		and
		--deliverydate is not null 
		o.trackingnumber is not null and 
		convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isactive = 1 AND po.PracticeId= @practiceId
		group by convert(date,o.createdDate))d 
		on d.createdDate = a.createdDate

END


-- CPN_GetSalesEodReportByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', '2017-01-01','2017-01-30'


GO
