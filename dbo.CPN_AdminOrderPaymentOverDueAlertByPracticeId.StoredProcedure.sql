USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminOrderPaymentOverDueAlertByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <31-12-2016>
-- Description:	<Description,,>
-- CPN_AdminOrderPaymentOverDueAlertByPracticeId 'BE16084E-B8BC-4F50-A493-613DEDDF9B55'  
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminOrderPaymentOverDueAlertByPracticeId] 
	-- Add the parameters for the stored procedure here
	@practiceId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
select top 5 convert(date,deliverydate) as deliverydate, count(distinct o.orderId) as noOfOrders
from orders o 
inner join patientOrders po on po.orderId = o.orderId
where shipstatus = 'Delivered' and orderbilldate is not null and po.practiceId= @practiceId
and orderpaiddate is null 
and datediff(day, convert(date,deliverydate) ,convert(date,getdate()) ) > 31
group by convert(date,deliverydate) order by deliverydate
	
END

GO
