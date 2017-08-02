USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetDashboardChartData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <23-10-2016>
-- Description:	<Get Chart Data for Dashboard>
-- CPN_GetDashboardChartData  'Y'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetDashboardChartData] 
	-- Add the parameters for the stored procedure here
	@filter char
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
if( @filter = 'L')
begin
DECLARE @Date1 DATE, @Date2 DATE
SET @Date1 =  getdate() - 7
SET @Date2 = getdate() +1
print @Date1
print @Date2
select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial
 from (
SELECT concat( datepart(mm, DATEADD(DAY,number+1,@Date1)),'/',datepart(dd,DATEADD(DAY,number+1,@Date1))) [Date]
FROM master..spt_values
WHERE type = 'P'
AND DATEADD(DAY,number+1,@Date1) < @Date2) a
 left join
	
(select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) 
and po.isactive = 1 and o.isactive = 1
group by concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,o.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) and po.isactive = 1 and o.isactive = 1
group by o.orderwound, o.orderNumber, concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join patientOrders po on po.orderId = pbo.orderId
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))e
on a.[Date] = e.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo 
inner join payors p on p.payorId = pbo.primarypayorid
inner join patientOrders po on po.orderId = pbo.orderId
 --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))f
on a.[Date] = f.[Date]
end
-- records fetch currentmonth
else if(@filter = 'D')
begin 
DECLARE @SDate  DATE,
        @EDate    DATE;
SELECT   @SDate = CONVERT(DATE,dateadd(dd,-(day(getdate())-1),getdate()))       
        ,@EDate   = CONVERT(DATE, dateadd(s,-1,dateadd(mm,datediff(m,0,getdate())+1,0)))
select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial, a.MonthDate
 from (
SELECT concat( datepart(mm, DATEADD(DAY,number,@SDate)),'/',datepart(dd,DATEADD(DAY,number,@SDate))) [Date], datepart(dd,DATEADD(DAY,number,@SDate)) as MonthDate
FROM master..spt_values
WHERE type = 'P'
AND DATEADD(DAY,number,@SDate) <= @EDate) a
 left join
	
(select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) between @SDate and @EDate 
and po.isactive = 1 and o.isactive = 1
group by concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) between @SDate and @EDate and po.isactive = 1 and o.isactive = 1
group by o.orderwound, o.orderNumber, concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join patientOrders po on po.orderId = pbo.orderId
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))e
on a.[Date] = e.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo 
inner join payors p on p.payorId = pbo.primarypayorid
inner join patientOrders po on po.orderId = pbo.orderId
 --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))f
on a.[Date] = f.[Date]
order by a.MonthDate
end
--last month
else if(@filter = 'K')
begin 
DECLARE @PreviousMonthStartDate  DATE,
        @PreviousMonthEndDate    DATE;
SELECT   @PreviousMonthStartDate = CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))      
        ,@PreviousMonthEndDate   = CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))
select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial
 from (
SELECT concat( datepart(mm, DATEADD(DAY,number,@PreviousMonthStartDate)),'/',datepart(dd,DATEADD(DAY,number,@PreviousMonthStartDate))) [Date]
FROM master..spt_values
WHERE type = 'P'
AND DATEADD(DAY,number,@PreviousMonthStartDate) < @PreviousMonthEndDate) a
 left join
	
(select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) between @PreviousMonthStartDate and @PreviousMonthEndDate 
and po.isactive = 1 and o.isactive = 1
group by concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) between @PreviousMonthStartDate and @PreviousMonthEndDate and po.isactive = 1 and o.isactive = 1
group by o.orderwound, o.orderNumber, concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join patientOrders po on po.orderId = pbo.orderId
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))e
on a.[Date] = e.[Date]
left join
	
(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo 
inner join payors p on p.payorId = pbo.primarypayorid
inner join patientOrders po on po.orderId = pbo.orderId
 --or p.payorId = pbo.secondarypayorid
WHERE pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))f
on a.[Date] = f.[Date]
end
-- records fetch yearly
else if(@filter = 'M')
begin 
DECLARE @StartDate  DATETIME,
        @EndDate    DATETIME;
SELECT   @StartDate = convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))       
        --,@EndDate   = convert(date, getdate())
		,@EndDate   = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) 
		
		PRINT @StartDate
		PRINT @EndDate
select distinct a.monthId, a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial
 from (
SELECT   DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS [Date], datepart(mm, DATEADD(MONTH, x.number, @StartDate)) as monthId
FROM    master.dbo.spt_values x
WHERE   x.type = 'P'        
AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)) a
 left join
	
(select datename(month,o.createdDate) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) >=  @StartDate and convert(date,po.createdDate) <= @EndDate and po.isactive = 1 and o.isactive = 1
group by datename(month,o.createdDate))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select datename(month,o.createdDate) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,o.createdDate) >=  @StartDate and convert(date,o.createdDate) <= @EndDate  and po.isactive = 1 and o.isactive = 1
group by o.orderwound, o.orderNumber, datename(month,o.createdDate))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select datename(month,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId= pbo.orderid
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1 
and convert(date,pbo.createdDate) >=  @StartDate and convert(date,pbo.createdDate) <= @EndDate
group by datename(month,pbo.createdDate))e
on a.[Date] = e.[Date]
left join
	
(select datename(month,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId =pbo.orderId
WHERE pbo.primarypayorid <> '9AA2C869-F9F9-46DD-88CE-50D4A9EE439A' and po.isactive = 1 
and convert(date,pbo.createdDate) >=  @StartDate and convert(date,pbo.createdDate) <= @EndDate
group by datename(month,pbo.createdDate))f
on a.[Date] = f.[Date]
order by a.MonthId asc
end
else if(@filter = 'Y')
begin 
DECLARE @StartYear  DATETIME, @EndYear    DATETIME;

SELECT   @StartYear   = convert(date, '2016-01-01')
select @EndYear = convert(date, dateadd(yy, 9, getdate()))

select distinct a.[Date] as [Year], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial
 from (
	SELECT   datepart(yy,DATEADD(year, x.number, @StartYear)) AS [Date]
	FROM    master.dbo.spt_values x
	WHERE   x.type = 'P'       
	AND     x.number <= DATEDIFF(year, @StartYear, @EndYear)) a
 left join
	
(select datepart(yy,o.createdDate) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,po.createdDate) >=  @StartYear and convert(date,po.createdDate) <= @EndYear and po.isactive = 1 and o.isactive = 1
group by datepart(yy,o.createdDate))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select datepart(yy,o.createdDate) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,o.createdDate) >=  @StartYear and convert(date,o.createdDate) <= @EndYear  and po.isactive = 1 and o.isactive = 1
group by o.orderwound, o.orderNumber, datepart(yy,o.createdDate))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select datepart(yy,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId= pbo.orderid
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.isactive = 1 
and convert(date,pbo.createdDate) >=  @StartYear and convert(date,pbo.createdDate) <= @EndYear
group by datepart(yy,pbo.createdDate))e
on a.[Date] = e.[Date]
left join
	
(select datepart(yy,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId =pbo.orderId
WHERE pbo.primarypayorid <> '9AA2C869-F9F9-46DD-88CE-50D4A9EE439A' and po.isactive = 1 
and convert(date,pbo.createdDate) >=  @StartYear and convert(date,pbo.createdDate) <= @EndYear
group by datepart(yy,pbo.createdDate))f
on a.[Date] = f.[Date]
order by a.date asc
end
-- else at the end 
else 
begin
select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,
isnull(e.medicare,0) as Medicare, isnull(f.Commercial,0) as Commercial
 from (
SELECT   concat( datepart(mm, getdate()),'-', datepart(dd,getdate()),'-', datepart(yyyy,getdate())) AS [Date]
) a
 left join
	
(select   convert(date,o.createdDate) as [Date],
count(distinct o.ordernumber) as [Orders],  sum(po.productQuntity*po.ProductPrice) as [Revenue]
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,o.createdDate) = convert(date,getdate())  and po.isactive = 1
group by convert(date,o.createdDate))b 
on a.[Date] = b.[Date]
left join 
(select c.Date, sum(c.wounds) as wounds from (
select convert(date,o.createdDate) as [Date],
convert(int,o.orderWound) wounds
from patientOrders po
inner join orders o  on o.orderId = po.orderId
where convert(date,o.createdDate) = convert(date,getdate()) and po.isactive = 1
group by o.orderwound, o.orderNumber, convert(date,o.createdDate))c
group by c.date) d
on a.[Date] = d.[Date]
left join
	
(select convert(date,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Medicare from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId = pbo.orderId
WHERE pbo.primarypayorid = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' 
--or pbo.primarypayorid = '0794F2F6-E217-41A0-A17A-2E67864200AE'
and po.isactive = 1 and convert(date,pbo.createdDate) = convert(date,getdate()) 
group by convert(date,pbo.createdDate))e
on a.[Date] = e.[Date]
left join
	
(select convert(date,pbo.createdDate) as [Date],
count(distinct pbo.orderId) as Commercial from payorbyorders pbo
inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid
inner join patientOrders po on po.orderId = pbo.orderid
WHERE pbo.primarypayorid <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
 --and pbo.primarypayorid <> '0794F2F6-E217-41A0-A17A-2E67864200AE'
 and po.isactive = 1 and convert(date,pbo.createdDate) = convert(date,getdate()) 
group by convert(date,pbo.createdDate))f
on a.[Date] = f.[Date]
end
END
GO
