USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_OrderStatus_PracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
-- CPN_PracticeModule_OrderStatus_PracticeId  'B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_OrderStatus_PracticeId] 

@practiceId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select convert(decimal(18,2),sum( patorder.productQuntity * convert(float,pt.medicarefreeschedule))) totalOrderAmount
 , convert(float,count(distinct ord.orderId)) totalOrder 
from Orders ord
INNER JOIN patientOrders patorder on patorder.orderId=ord.orderId 
inner join productTables pt on pt.productId = patorder.itemid
where 
--ord.shipstatus = 'shipped' and 
-- convert(date,ord.createdDate)  >=  convert(date,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) 
--AND convert(date,ord.createdDate) <= convert(date, getdate()) AND 
patorder.PracticeId=@practiceId AND patorder.IsActive=1 AND ord.IsActive=1

END

GO
