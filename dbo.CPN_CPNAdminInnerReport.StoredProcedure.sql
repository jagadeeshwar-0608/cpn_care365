USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_CPNAdminInnerReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <13-Aug-2016>
-- Description:	<Cpn admin inner report>
-- CPN_CPNAdminInnerReport '2016-07-18'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_CPNAdminInnerReport]
	@date datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select distinct o.orderId, (select 123) as invoice, count(po.orderId) as [Orders],
    round(convert(float,sum(productPrice),2),2) as [OrderRevenue],  
	round(convert(float,sum(convert(float,1)),2),2) as [ProductCost],
	-- round(convert(float,sum(productCost),2),2) as [ProductCost]
	(select convert(float,15)) as shippingCost, (select  convert(float,10)) as commission

    from Orders o
   inner join patientOrders po on po.orderId = o.orderId
   inner join productTables pt on pt.productId = po.itemid
 where convert(date,o.createdDate) = @date
   group by  o.orderId
END


GO
