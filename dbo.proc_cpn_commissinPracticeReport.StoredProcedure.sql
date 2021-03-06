USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_cpn_commissinPracticeReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <26-01-2017>
-- Description:	<Get commission prescriber by practice>
-- proc_cpn_commissinPracticeReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[proc_cpn_commissinPracticeReport]
	-- Add the parameters for the stored procedure here
	--@repId uniqueidentifier,
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
		select distinct prac.legalname,
		min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder
		into #temp
		from patientOrders po 
		inner join practices prac on prac.practiceId= po.practiceId
		inner join productTables pt on pt.productId = po.itemId
		inner join recordrelations rr on rr.practiceId = po.practiceId
		where  po.isactive = 1 and pt.categoryname like 'Primary' 
		and rr.isactive = 1 and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		--and rr.salesrepid = @repId
		group by prac.legalname

		/* Commission data*/

		select distinct po.orderId, prac.legalname,productDescription,
		isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission
		into #commData
		from patientOrders po 
		inner join productTables pt on pt.productId = po.itemId
		inner join recordRelations rr on rr.practiceid = po.practiceid
		inner join practices prac on prac.practiceId = po.practiceId
		where 
		po.isactive = 1 and rr.isactive = 1
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		and pt.categoryname  = 'Primary' 
		--and rr.salesrepid = @repId


		select legalname, sum(commission) as commission
		into #commissionData
		from #commData
		group by legalname
		

		/*Revenue Data*/

		select distinct po.orderid, prac.legalname,
		po.productQuntity * po.productPrice as revenue 
		into #revenue
		from patientOrders po
		inner join recordRelations rr on rr.practiceid = po.practiceid
		inner join practices prac on prac.practiceId = po.practiceId
		where po.isactive = 1 and rr.isactive = 1
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		--and rr.salesrepid = @repId

		select legalname, sum(revenue) as revenue into #revenueData from #revenue group by legalname

		/*Consolidated data*/	

		
		select count(distinct po.orderId) as Orders, prac.legalname as PracticeName, prac.practiceid,
		sales.[Initial] as SalesRepName ,
		convert(decimal(18,2),c.commission) as commission,
		convert(float,r.revenue) as revenue, t.lastorder,
		--, @repId as SalesRepId,
		case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
		when t.lastorder > 30 then 'Never Active' else 'Active' end as [status]
		from PatientOrders po
		inner join recordrelations rr on rr.practiceId = po.practiceid
		inner join practices prac on prac.practiceId = po.practiceId
		INNER JOIN [dbo].[salesRepInfoes] sales ON sales.[salesRepInfoId] = rr.[SalesRepId]
		inner join #commissionData c on c.legalname = prac.legalname
		inner join #revenueData r on r.legalname = prac.legalname
		inner join #temp t on t.legalname = prac.legalname
		where po.isactive  = 1 and rr.isactive = 1 
		--and rr.salesrepid = @repId
		and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		group by prac.legalname, sales.[Initial] ,prac.practiceid, c.commission,r.revenue, t.lastorder
END

GO
