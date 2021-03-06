USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesRep_EodReport_ByMasterSalesRepId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <31-03-2017>
-- Description:	<Get Sales end of the day report by sales rep>
-- CPN_MasterSalesRep_EodReport_ByMasterSalesRepId '33f0e6fc-557d-487c-9750-0edc0e779363', '2017-04-01','2017-04-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesRep_EodReport_ByMasterSalesRepId] 
	@masterSalesRepId uniqueidentifier,
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
		o.orderNumber, rr.salesRepId, s.initial
		into #general
		from orders o 
		inner join patientOrders po on po.orderId = o.orderId
		inner join RecordRelations rr on po.PracticeId = rr.PracticeId
		inner join [MasterUserRelation] mr on rr.salesRepId = mr.salesRepId
		INNER JOIN salesRepInfoes s on s.salesrepInfoId = rr.SalesRepId
		where mr.UserId = @masterSalesRepId --'33f0e6fc-557d-487c-9750-0edc0e779363' -- 
		and convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isActive = 1 and rr.isactive = 1
		group by datename(dw, o.createdDate), convert(date,o.createdDate), o.orderWound,o.orderNumber, rr.salesRepId, s.initial
		select distinct convert(date,po.createdDate) as createdDate, po.orderId, pt.productDescription, po.productQuntity * po.productPrice as Revenue
		into #revenue
		from patientOrders po 
		inner join productTables pt on pt.productid = po.itemId
		inner join recordrelations rr on rr.practiceId  = po.practiceid
		inner join [MasterUserRelation] mr on rr.salesRepId = mr.salesRepId
		where po.isactive = 1 and rr.isactive = 1
		and mr.UserId = @masterSalesRepId--'33f0e6fc-557d-487c-9750-0edc0e779363' -
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		select convert(date,r.createdDate) as createdDate, sum(Revenue) as Revenue into #finalrevenue 
		from #revenue r
		group by convert(date,r.createdDate)
		select  a.[dayofweek], a.createdDate as OrderDate, isnull(a.wounds,0) as TotalWounds,
		isnull(a.orders,0) as GrossOrders, --a.revenue, 
		isnull(b.medicare,0) as MedicareOrders, isnull(c.ppohmo,0) as ppoOrders,
		isnull(d.shippedOrders,0) shippedOrders, a.salesRepId, a.initial as  salesrepname into #temp
		from (select [dayofweek], createdDate, sum(orderWounds) as wounds, sum(orders) as orders, salesRepId, initial --, sum(Revenue) as revenue
		from #general
		group by [dayOfWeek], CreatedDate, salesRepId, initial) a
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
		where o.trackingnumber is not null and 
		convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
		and po.isactive = 1
		group by convert(date,o.createdDate))d 
		on d.createdDate = a.createdDate
		
		select  f.[dayofweek], f.OrderDate, sum(TotalWounds) as TotalWounds,
		sum(GrossOrders) as GrossOrders, 
		sum(MedicareOrders) as MedicareOrders, sum(ppoOrders) as ppoOrders,
		sum(shippedOrders) as shippedOrders into #final
		from #temp f
		group by f.[dayofweek], f.OrderDate

		select f.*, fr.Revenue from 
		#final f
		inner join #finalrevenue fr
		on f.OrderDate = fr.createdDate
		order by orderdate 

END
GO
