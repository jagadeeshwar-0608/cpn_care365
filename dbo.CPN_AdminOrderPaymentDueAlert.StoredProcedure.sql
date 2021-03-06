USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminOrderPaymentDueAlert]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <31-12-2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminOrderPaymentDueAlert] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	select top 5 convert(date,deliverydate) deliverydate, count(distinct orderId) as noOfOrders
from orders where shipstatus = 'Delivered' and orderbilldate is not null
and orderpaiddate is null and datediff(day,convert(date,deliverydate),convert(date,getdate())) > 21 
and datediff(day,convert(date,deliverydate),convert(date,getdate())) < 31
group by convert(date,deliverydate) order by deliverydate
	
END

GO
