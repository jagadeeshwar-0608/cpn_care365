USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_GetCommissionSalesRepReport_ByMasterId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <26-01-2017>
-- Description:	<Get commission prescriber by sales reps>
-- CPN_MasterSalesModule_GetCommissionSalesRepReport_ByMasterId '33f0e6fc-557d-487c-9750-0edc0e779363','null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_GetCommissionSalesRepReport_ByMasterId]
	-- Add the parameters for the stored procedure here
	@mastersalesId uniqueidentifier ,
	@fromDate nvarchar(20) = null,
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

		/*last order data*/
		select distinct s.initial,
		min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder
		into #temp
		from patientOrders po 
		inner join practices prac on prac.practiceId= po.practiceId
		inner join productTables pt on pt.productId = po.itemId
		inner join recordrelations rr on rr.practiceId = po.practiceId
		inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid
		INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
		where  po.isactive = 1 --and pt.categoryname like 'Primary' 
		and rr.isactive = 1 and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		and mr.UserId = @mastersalesId 
		group by initial

		/* Commission data*/

		select distinct po.orderId, s.initial,productDescription,
		isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission
		into #commData
		from patientOrders po 
		inner join productTables pt on pt.productId = po.itemId
		inner join recordRelations rr on rr.practiceid = po.practiceid
		inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid
			INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
		where 
		po.isactive = 1 and rr.isactive = 1
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		--and pt.categoryname  = 'Primary'
		and mr.UserId = @mastersalesId

		select initial, sum(commission) as commission
		into #commissionData
		from #commData
		group by initial
		

		/*Revenue Data*/

		select distinct po.orderid, s.initial,
		po.productQuntity * po.productPrice as revenue 
		into #revenue
		from patientOrders po
		inner join recordRelations rr on rr.practiceid = po.practiceid
		inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid
		INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
		where po.isactive = 1 and rr.isactive = 1
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		and mr.UserId = @mastersalesId

		select initial, sum(revenue) as revenue into #revenueData from #revenue group by initial

		/*Consolidated data*/	

		
		select count(distinct po.orderId) as Orders,count(distinct rr.practiceid) as Noofpractice, s.initial as SalesRepName, s.salesrepinfoid as SalesRepId,
		convert(decimal(18,2),c.commission) as commission,
		convert(float,r.revenue) as revenue, t.lastorder, 
		case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
		when t.lastorder > 30 then 'Never Active' else 'Active' end as [status]
		from PatientOrders po
		inner join recordrelations rr on rr.practiceId = po.practiceid
		inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid
		inner join #commissionData c on c.initial = s.initial
		inner join #revenueData r on r.initial = s.initial
		inner join #temp t on t.initial = s.initial
		INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
		where po.isactive  = 1 and rr.isactive = 1
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		and mr.UserId = @mastersalesId
		group by s.initial, s.salesrepinfoid , c.commission,r.revenue, t.lastorder
END

GO
