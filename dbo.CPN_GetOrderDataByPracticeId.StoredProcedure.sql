USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetOrderDataByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <22-10-2016>

-- Description:	<Get order data by practiceId>

-- CPN_GetOrderDataByPracticeId '0f60a1b9-c9be-4254-ac77-ac6534101a50'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetOrderDataByPracticeId] 

	-- Add the parameters for the stored procedure here

	@practiceId uniqueidentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;

    -- Insert statements for procedure here

	select distinct prac.practiceId,o.orderId, o.createdDate, o.orderNumber as OrderNumber,
	phy.initials as physicianName, concat(pat.namefirst,' ', pat.namelast) as patientName, 
	case when orderStatus  = 'Delivered' then convert(bit,1) else convert(bit,0) end as shipStatus ,
	case when orderStatus = 'Delivered' then concat(orderStatus, ' on ', convert(varchar(10), cast(DeliveryDate as date), 101)) else orderStatus end as orderStatus
	
	-- prod.MedicareFreeSchedule,
	,o.orderChartNumber, o.OrderBillDate, o.OrderPaidDate, o.primaryPaidAmount, o.SecondaryPaidAmount

	from patientOrders po

	inner join orders o on o.orderId= po.OrderId

	inner join practices prac on prac.practiceId = po.practiceId

	inner join physicians phy on phy.physicianid = po.physicianId

	inner join productTables prod on prod.productId = po.itemId

	inner join patientInfoes pat on pat.patientId = po.patientId

	where po.practiceId = @practiceId

END


GO
