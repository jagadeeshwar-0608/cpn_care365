USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_GetDashboardChartData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <23-10-2016>

-- Description:	<Get Chart Data for Dashboard>

-- dbo.CPN_PracticeModule_GetDashboardChartData_ByPracticeId '1E165131-54CF-403F-B8E8-28D353A60178','Y'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_PracticeModule_GetDashboardChartData_ByPracticeId] 



	 @practiceId uniqueidentifier,

	 @filter char



	-- Add the parameters for the stored procedure here

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    

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

count(distinct o.ordernumber) as [Orders], 
convert(decimal(18,2), sum(po.productQuntity*  convert(float, pt.medicareFreeschedule))) as [Revenue]

from patientOrders po

inner join orders o  on o.orderId = po.orderId
inner join producttables pt on pt.productId = po.itemId

where convert(date,o.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) 

and po.practiceid = @practiceId and po.isactive = 1

group by concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))b 

on a.[Date] = b.[Date]



left join 



(select c.Date, sum(c.wounds) as wounds from (

select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],

convert(int,o.orderWound) wounds

from patientOrders po

inner join orders o  on o.orderId = po.orderId

where convert(date,o.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) 

and po.practiceid = @practiceId and po.isactive = 1

group by o.orderwound, o.orderNumber, concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))c

group by c.date) d

on a.[Date] = d.[Date]



left join

	

(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],

count(distinct pbo.orderId) as Medicare from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'

and po.practiceid = @practiceId and po.isactive = 1

group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))e

on a.[Date] = e.[Date]



left join

	

(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],

count(distinct pbo.orderId) as Commercial from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'

and po.practiceid = @practiceId and po.isactive = 1

group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))f

on a.[Date] = f.[Date]



end



else if(@filter = 'Y')

begin 



DECLARE @StartDate  DATETIME,

        @EndDate    DATETIME;



SELECT   @StartDate = convert(date,DATEADD(year, DATEDIFF(year, 0, getdate()), 0))       

        ,@EndDate   = convert(date, getdate())



select distinct a.monthId, a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,

isnull(e.medicare,0) as Medicare, isnull(f.commercial,0) as Commercial

 from (

 

SELECT   DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS [Date], datepart(mm, DATEADD(MONTH, x.number, @StartDate)) as monthId

FROM    master.dbo.spt_values x

WHERE   x.type = 'P'        

AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)) a

 left join

	

(select datename(month,o.createdDate) as [Date],
count(distinct o.ordernumber) as [Orders], 
convert(decimal(18,2), sum(po.productQuntity*  convert(float, pt.medicareFreeschedule))) as [Revenue]

from patientOrders po

inner join orders o  on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId

where convert(date,o.createdDate) >=  @StartDate and convert(date,o.createdDate) <= @EndDate 

and po.practiceid = @practiceId and po.isactive = 1

group by datename(month,o.createdDate))b 

on a.[Date] = b.[Date]



left join 



(select c.Date, sum(c.wounds) as wounds from (

select datename(month,o.createdDate) as [Date],

convert(int,o.orderWound) wounds

from patientOrders po

inner join orders o  on o.orderId = po.orderId

where convert(date,o.createdDate) >=  @StartDate and convert(date,o.createdDate) <= @EndDate  

and po.practiceid = @practiceId and po.isactive = 1

group by o.orderwound, o.orderNumber, datename(month,o.createdDate))c

group by c.date) d

on a.[Date] = d.[Date]



left join

	

(select datename(month,pbo.createdDate) as [Date],

count(distinct pbo.orderId) as Medicare from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and convert(date,pbo.createdDate) >=  @StartDate and convert(date,pbo.createdDate) <= @EndDate

and po.practiceid = @practiceId and po.isactive = 1



group by datename(month,pbo.createdDate))e

on a.[Date] = e.[Date]



left join

	

(select datename(month,pbo.createdDate) as [Date],

count(distinct pbo.orderId) as Commercial from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and convert(date,pbo.createdDate) >=  @StartDate and convert(date,pbo.createdDate) <= @EndDate

and po.practiceid = @practiceId and po.isactive = 1

group by datename(month,pbo.createdDate))f

on a.[Date] = f.[Date]

order by a.MonthId asc



end



else 

begin

select distinct a.[Date], isnull(b.Orders,0) as Orders, isnull(b.Revenue,0) as Revenue,isnull(d.wounds,0) as wounds,

isnull(e.medicare,0) as Medicare, isnull(f.Commercial,0) as Commercial

 from (

 

SELECT   concat( datepart(mm, getdate()),'-', datepart(dd,getdate()),'-', datepart(yyyy,getdate())) AS [Date]

) a

 left join

	

(select   convert(date,o.createdDate) as [Date],
count(distinct o.ordernumber) as [Orders], 

convert(decimal(18,2), sum(po.productQuntity *  convert(float, pt.medicareFreeschedule))) as [Revenue]

from patientOrders po

inner join orders o  on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId

where convert(date,o.createdDate) = convert(date,getdate())  

and po.practiceid = @practiceId and po.isactive = 1

group by convert(date,o.createdDate))b 

on a.[Date] = b.[Date]



left join 



(select c.Date, sum(c.wounds) as wounds from (

select convert(date,o.createdDate) as [Date],

convert(int,o.orderWound) wounds

from patientOrders po 

inner join orders o  on o.orderId = po.orderId

where convert(date,o.createdDate) = convert(date,getdate()) 

and po.practiceid = @practiceId and po.isactive = 1

group by o.orderwound, o.orderNumber, convert(date,o.createdDate))c

group by c.date) d

on a.[Date] = d.[Date]



left join

	

(select convert(date,pbo.createdDate) as [Date],

count(distinct pbo.orderId) as Medicare from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and convert(date,pbo.createdDate) = convert(date,getdate()) 

and po.practiceid = @practiceId and po.isactive = 1

group by convert(date,pbo.createdDate))e

on a.[Date] = e.[Date]



left join

	

(select convert(date,pbo.createdDate) as [Date],

count(distinct pbo.orderId) as Commercial from payorbyorders pbo

inner join patientOrders po on po.orderId = pbo.orderId

inner join payors p on p.payorId = pbo.primarypayorid --or p.payorId = pbo.secondarypayorid

WHERE p.payorId <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and convert(date,pbo.createdDate) = convert(date,getdate()) 

and po.practiceid = @practiceId and po.isactive = 1

group by convert(date,pbo.createdDate))f

on a.[Date] = f.[Date]



end



END

GO
