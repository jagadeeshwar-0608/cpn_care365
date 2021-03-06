USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_GetSalesRepDashboardChartData_ByMasterId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <23-10-2016>
-- Description:	<Get Chart Data for Dashboard>
-- CPN_MasterSalesModule_GetSalesRepDashboardChartData_ByMasterId '7D3591BE-3425-43CD-9BAD-1602E6E74B7D' , 'Y'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_GetSalesRepDashboardChartData_ByMasterId] 
	@mastersalesId uniqueidentifier,
	@filter char
AS
BEGIN
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @Date1 DATE, @Date2 DATE
	
   select distinct convert(date,po.createdDate) as createdDate, po.orderId, pt.productDescription,
   isnull(round(convert(float, po.productQuntity * convert(float, po.productPrice)),2),0) as Commission
   into #commissiondata
   --drop table #commissiondata
   from patientOrders po 
   inner join productTables pt on pt.productid = po.itemId
   inner join recordrelations rr on rr.practiceId  = po.practiceid
   inner join MasterUserRelation mr on mr.salesrepid  = rr.salesrepid 
   where po.isactive = 1 and rr.isactive = 1 and mr.isactive = 1
   and mr.UserId = @mastersalesId
   --select top 5 * from #commissiondata
   --order by createdDate desc
	select distinct convert(date,pbo.createdDate)  as createdDate, pbo.orderId 
	into #Medicare
	from payorbyorders pbo
	inner join patientOrders po on po.orderId = pbo.orderId
	inner join payors p on p.payorId = pbo.primarypayorid 
	inner join recordrelations rr on rr.practiceId  = po.practiceid
	inner join MasterUserRelation mr on mr.salesrepid  = rr.salesrepid 
	WHERE p.payorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
	and mr.UserId = @mastersalesId
	and po.IsActive = 1 and rr.isactive = 1 and mr.isactive = 1

	--select top 5 * from #Medicare			
	--order by createdDate desc
			
	select distinct convert(date,pbo.createdDate)  as createdDate, pbo.orderId 
	into #Commercial
	from payorbyorders pbo
	inner join patientOrders po on po.orderId = pbo.orderId
	inner join payors p on p.payorId = pbo.primarypayorid
	inner join recordrelations rr on rr.practiceId  = po.practiceid
	inner join MasterUserRelation mr on mr.salesrepid  = rr.salesrepid 
	WHERE p.payorId <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
	and mr.UserId = @mastersalesId
	and po.IsActive = 1 and rr.isactive = 1 and mr.isactive = 1
	--select top 5 * from #Commercial
	--order by createdDate desc
	--return 

	if(@filter = 'C')
	begin
		
		SET @Date1 =  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
		SET @Date2 = convert(date, getdate())
		select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(c.commission,0) as commission, a.MonthDate, isnull(d.Revenue, 0) as Revenue, isnull(e.Medicare,0) as Medicare, isnull(f.Commercial, 0) as Commercial
		 from (
		SELECT concat( datepart(mm, DATEADD(DAY,number,@Date1)),'/',datepart(dd,DATEADD(DAY,number,@Date1))) [Date], datepart(dd,DATEADD(DAY,number,@Date1)) as MonthDate
		FROM master..spt_values
		WHERE type = 'P'
		AND DATEADD(DAY,number - 1 ,@Date1) < @Date2) a 
		left join
			(select  concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date],
			count(distinct orderId) as orders 
			from #commissiondata
			where convert(date,createdDate) between @Date1 and @Date2
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))b
			on b.date = a.date
		left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			 round(sum(Commission) * 0.11, 2) as Commission
			 from #commissiondata
			where convert(date,createdDate) between @Date1 and @Date2
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))c
			on c.date = a.date
		left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			 sum(Commission) as Revenue
			 from #commissiondata
			where convert(date,createdDate) between @Date1 and @Date2
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate)))) d
			on d.date = a.date
		left join 
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			count(distinct orderId) as Medicare 
			from  #Medicare
			where convert(date,createdDate) between @Date1 and @Date2
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))e
			on a.[Date] = e.[Date]
		left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date],
			count(distinct orderId) as Commercial 
			from #Commercial 
			where convert(date,createdDate) between @Date1 and @Date2
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))f
			on a.[Date] = f.[Date]
			order by a.MonthDate
	end
	else if(@filter = 'L')
	begin 
		
		SET @Date1 =  getdate() - 7
		SET @Date2 = getdate() +1
		print @Date1
		print @Date2
		select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(round(c.commission,2),0) as commission, isnull(round(d.Revenue,2),0) as Revenue, isnull(e.Medicare,0) as Medicare, isnull(f.Commercial, 0) as Commercial, a.MonthDate
		 from (
		SELECT concat( datepart(mm, DATEADD(DAY,number+1,@Date1)),'/',datepart(dd,DATEADD(DAY,number+1,@Date1))) [Date], datepart(dd,DATEADD(DAY,number,@Date1)) as MonthDate
		FROM master..spt_values
		WHERE type = 'P'
		AND DATEADD(DAY,number+1,@Date1) < @Date2) a 
		left join
			(select  concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date],
			count(distinct orderId) as orders 
			
			 from #commissiondata
			where convert(date,createdDate) between convert(date,getdate()-7) and convert(date,getdate())
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))b
			on b.date = a.date
			left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			round(sum(Commission) * 0.11, 2) as Commission
			 from #commissiondata
			where convert(date,createdDate) between convert(date,getdate()-7) and convert(date,getdate())
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate)))  )c
			on c.date = a.date
			left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			sum(Commission) as Revenue
			 from #commissiondata
			where convert(date,createdDate) between convert(date,getdate()-7) and convert(date,getdate())
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate)))  ) d
			on d.date = a.date
			left join 
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date], 
			count(distinct orderId) as Medicare 
			from  #Medicare
			where convert(date,createdDate) between convert(date,getdate()-7) and convert(date,getdate())
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))e
			on a.[Date] = e.[Date]
			left join
			(select concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))) as [Date],
			count(distinct orderId) as Commercial 
			from #Commercial 
			where convert(date,createdDate) between convert(date,getdate()-7) and convert(date,getdate())
			group by concat(datepart(mm,convert(date,createdDate)),'/', datepart(dd,convert(date,createdDate))))f
			on a.[Date] = f.[Date]
			order by a.MonthDate
	end
	else if (@filter = 'Y')
	begin
	
	DECLARE @StartDate  DATETIME,
       @EndDate    DATETIME;
	SELECT   @StartDate = convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))       
        ,@EndDate   = convert(date, getdate())
	select distinct a.[date], isnull(b.orders,0) as orders, isnull(round(c.commission,2),0) as commission, isnull(round(d.Revenue,2),0) as Revenue, isnull(e.Medicare,0) as Medicare, isnull(f.Commercial, 0) as Commercial, a.monthId
	from (
		SELECT   DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS [Date], datepart(mm, DATEADD(MONTH, x.number, @StartDate)) as monthId
		FROM    master.dbo.spt_values x
		WHERE   x.type = 'P'        
		AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)) a
	
	left join
			(select  datename(month,createdDate) as [Date],
			count(distinct orderId) as orders 
			 from #commissiondata
			where convert(date,createdDate) >=  @StartDate and convert(date,createdDate) <= @EndDate
			group by datename(month,createdDate))b
			on b.date = a.date
			left join
			(select datename(month,createdDate) as [Date], 
			sum(Commission) * 0.11 as Commission
			 from #commissiondata
			where convert(date, createdDate) >=  @StartDate and convert(date, createdDate) <= @EndDate
			group by datename(month,createdDate) )c
			on c.date = a.date
			left join
			(select datename(month,createdDate) as [Date], 
			sum(Commission) as Revenue
			 from #commissiondata
			where convert(date, createdDate) >=  @StartDate and convert(date, createdDate) <= @EndDate
			group by datename(month,createdDate) )d
			on d.date = a.date

			left join
			(select datename(month,createdDate) as [Date], 
			count(distinct orderId) as Medicare
			 from #Medicare
			where convert(date, createdDate) >=  @StartDate and convert(date, createdDate) <= @EndDate
			group by datename(month,createdDate) )e
			on a.date = e.date
			left join
			(select datename(month,createdDate) as [Date],
			count(distinct orderId) as Commercial 
			from #Commercial 
			where convert(date, createdDate) >=  @StartDate and convert(date, createdDate) <= @EndDate
			group by datename(month,createdDate) )f
			on a.date = f.date

			order by a.monthId 
	
	end
	else 
	begin
		select distinct a.[date], isnull(b.orders,0) as orders, isnull(round(c.commission,2),0) as commission, isnull(round(d.Revenue,2),0) as Revenue, isnull(e.Medicare,0) as Medicare, isnull(f.Commercial, 0) as Commercial
		from 
		(SELECT convert(date, concat( datepart(yyyy,getdate()), '-', datepart(mm, getdate()),'-', datepart(dd,getdate()))) AS [Date]
		) a
		left join
		(select  convert(date,createdDate) as [Date],count(distinct orderId) as orders 
		from #commissiondata
		where convert(date,createdDate) = convert(date,getdate())
		group by convert(date,createdDate))b
		on b.date = a.date
		left join
		(select convert(date,createddate) as [Date], 
		sum(Commission) * 0.11 as Commission
		from #commissiondata 
		where convert(date,createdDate) = convert(date,getdate())
		group by convert(date,createdDate) )c
		on c.date = a.date
		left join
		(select convert(date,createddate) as [Date], 
		sum(Commission) as Revenue
		from #commissiondata 
		where convert(date,createdDate) = convert(date,getdate())
		group by convert(date,createdDate) )d
		on d.date = a.date
		left join 
		(select convert(date,createdDate) as [Date], 
		count(distinct orderId) as Medicare 
		from  #Medicare
		where convert(date,createdDate)  = convert(date,getdate())
		group by convert(date,createdDate) )e
		on a.[Date] = e.[Date]
		left join
		(select convert(date,createdDate) as [Date], 
		count(distinct orderId) as Commercial 
		from #Commercial 
		where convert(date,createdDate) = convert(date,getdate())
		group by convert(date,createdDate) )f
		on a.[Date] = f.[Date]
	END
END
GO
