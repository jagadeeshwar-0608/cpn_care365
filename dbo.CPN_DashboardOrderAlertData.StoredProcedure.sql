USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_DashboardOrderAlertData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <31-12-2016>
-- Description:	<Get data for alerts for getting orders status for biling management>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_DashboardOrderAlertData] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	select a.[Date],a.readytobill, b.billingOverDue, c.paymentDue,d.paymentoverdue from 
( select convert(date,getdate()) as [Date], count(distinct orderId) readytobill
 from orders where shipstatus ='Delivered' and orderbilldate is null

)a
left join 
(select convert(date,getdate()) as [Date],count(distinct orderId) billingOverDue 
from orders where shipstatus = 'Delivered' and 
orderbilldate is null and  datediff(day,convert(date,deliverydate),convert(date,getdate())) > 5)b
on a.[Date] = b.[Date]
left join 
( select convert(date,getdate()) as [Date], count(distinct orderId) as paymentdue
from orders where shipstatus = 'Delivered' and orderbilldate is not null
and orderpaiddate is null and datediff(day,convert(date,deliverydate),convert(date,getdate())) > 21 
and datediff(day,convert(date,deliverydate),convert(date,getdate())) < 31 ) c
on a.[Date] = c.[Date]
left join 
( select convert(date,getdate()) as [Date], count(distinct orderId) as paymentoverdue
from orders where shipstatus = 'Delivered' and orderbilldate is not null
and orderpaiddate is null 
and datediff(day, convert(date,deliverydate) ,convert(date,getdate()) ) > 31) d
on c.[Date] = d.[Date]

END

GO
