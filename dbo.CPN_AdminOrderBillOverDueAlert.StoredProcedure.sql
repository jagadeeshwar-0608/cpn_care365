USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminOrderBillOverDueAlert]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <31-12-2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminOrderBillOverDueAlert] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	select top 5 convert(date,deliverydate) as deliverydate,count(distinct orderId) noOfOrders 
from orders where shipstatus = 'Delivered' and 
orderbilldate is null and  datediff(day,convert(date,deliverydate),convert(date,getdate())) > 5
group by convert(date,deliverydate)  order by deliverydate
	
END

GO
