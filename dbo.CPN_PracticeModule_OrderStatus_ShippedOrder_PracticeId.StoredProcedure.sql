USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_OrderStatus_ShippedOrder_PracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
-- [dbo].[CPN_PracticeModule_OrderStatus_ShippedOrder_PracticeId]   'b6e76840-6424-4a84-82d1-f1d3f35fed0d'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_OrderStatus_ShippedOrder_PracticeId] 

@practiceId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select convert(float,count(distinct po.orderId)) as totalShippedOrder, 
convert(decimal(18,2),isnull(sum( po.productQuntity * convert(float,pt.medicarefreeschedule)),0)) as totalOrderShippedAmount
from  PatientOrders po
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId
where po.practiceId = @practiceId and po.isactive =1
and o.shipStatus <> 'Processing'



END

GO
