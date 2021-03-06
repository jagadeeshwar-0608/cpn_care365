USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPracticeDashboardChartData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <23-10-2016>

-- Description:	<Get Chart Data for Dashboard>

-- CPN_GetPracticeDashboardChartData '02f568bd-104c-47e8-9c7b-2c9e2641ab88'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetPracticeDashboardChartData] 

	-- Add the parameters for the stored procedure here
	@salesRepId uniqueidentifier
	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    -- Insert statements for procedure here



DECLARE @Date1 DATE, @Date2 DATE

SET @Date1 =  getdate() - 7

SET @Date2 = getdate() +1



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

from cpnbioscience.dbo.patientOrders po

inner join orders o  on o.orderId = po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations rr on rr.practiceId = prac.practiceId
inner join salesRepInfoes sale on sale.salesRepInfoId = rr.salesRepId

where convert(date,o.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) 
and sale.salesRepInfoId = @salesRepId
group by concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))b 

on a.[Date] = b.[Date]



left join 



(select c.Date, sum(c.wounds) as wounds from (

select concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))) as [Date],

convert(int,o.orderWound) wounds

from cpnbioscience.dbo.patientOrders po

inner join orders o  on o.orderId = po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations rr on rr.practiceId = prac.practiceId
inner join salesRepInfoes sale on sale.salesRepInfoId = rr.salesRepId

where convert(date,o.createdDate) between convert(date,getdate()-7) and convert(date,getdate()) 
and sale.salesRepInfoId = @salesRepId

group by o.orderwound, o.orderNumber, concat(datepart(mm,convert(date,o.createdDate)),'/', datepart(dd,convert(date,o.createdDate))))c

group by c.date) d

on a.[Date] = d.[Date]



left join

	

(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],

count(distinct o.orderId) as Medicare from payorbyorders pbo

inner join payors p on p.payorId = pbo.primarypayorid or p.payorId = pbo.secondarypayorid
inner join orders o  on o.orderId = pbo.orderId
inner join patientOrders po on po.orderId = o.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations rr on rr.practiceId = prac.practiceId
inner join salesRepInfoes sale on sale.salesRepInfoId = rr.salesRepId

WHERE p.payorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'
and sale.salesRepInfoId = @salesRepId
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))e

on a.[Date] = e.[Date]

left join

(select concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))) as [Date],

count(distinct o.orderId) as Commercial from payorbyorders pbo
inner join orders o  on o.orderId = pbo.orderId
inner join patientOrders po on po.orderId = o.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations rr on rr.practiceId = prac.practiceId
inner join salesRepInfoes sale on sale.salesRepInfoId = rr.salesRepId

inner join payors p on p.payorId = pbo.primarypayorid or p.payorId = pbo.secondarypayorid

WHERE p.payorId = '9AA2C869-F9F9-46DD-88CE-50D4A9EE439A'
and sale.salesRepInfoId = @salesRepId
group by concat(datepart(mm,convert(date,pbo.createdDate)),'/', datepart(dd,convert(date,pbo.createdDate))))f

on a.[Date] = f.[Date]







END










GO
