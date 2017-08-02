USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_OrderStatus_DeliveredOrder_PracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
-- CPN_PracticeModule_OrderStatus_DeliveredOrder_PracticeId  'b6e76840-6424-4a84-82d1-f1d3f35fed0d'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_OrderStatus_DeliveredOrder_PracticeId] 

@practiceId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	select convert(float,count(distinct po.orderId)) as totalDeliveredOrder,
	 convert(decimal(18,2),sum( po.productQuntity * convert(float,pt.medicarefreeschedule))) as totalOrderDeliveredAmount
from  PatientOrders po
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productid = po.itemid
where po.practiceId = @practiceId and po.isactive =1
and o.shipStatus = 'Delivered'


END

GO
