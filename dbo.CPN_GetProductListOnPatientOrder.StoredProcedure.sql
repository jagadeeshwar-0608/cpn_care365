USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetProductListOnPatientOrder]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,> 

-- CPN_GetProductListOnPatientOrder  'D4628816-644B-45DD-ADE7-AC079801130D'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetProductListOnPatientOrder] 



@orderId   uniqueidentifier -- nvarchar(50)

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



   

	SELECT 

	patorder.[PatientOrderId]  PatientOrderId, prod.productId as ProductId, 

	prod.item as Item,

	prod.productdescription as ProductDescription, 

	prod.HCPCS as HCPCS, 

	--ppi.MedicareFreeSchedule as MedicareFreeSchedule,

	prod.MedicareFreeSchedule as MedicareFreeSchedule,

	ppi.UM as UM,

	prod.BillableUnits * patorder.productquntity as BillableUnits, -- Multiplication changes done by pratikg

	ppi.ShippableUnits as ShippableUnits,

	ppi.DaySuppluMax as DaySuppluMax,

	patorder.productquntity as shippingQty , 

	patorder.ProductLotNumberId as LotNumberId,

	pln.LotNumber as LotNumber,

	patorder.ProductModifierId as ProductModifierId,

	pm.ProductModifierName as ProductModifierName,

	ppi.EffectivePrice as EffectivePrice



	FROM PatientOrders patorder 

	INNER JOIN ProductTables prod on prod.productId=patorder.itemid

	INNER JOIN PracticeProductInfo ppi on ppi.PracticeId=patorder.PracticeId

	INNER JOIN ProductModifier pm on pm.ProductModifierId=patorder.ProductModifierId

	left JOIN ProductLotNumber pln on pln.ProductLotNumberId=patorder.ProductLotNumberId

	WHERE patorder.IsActive =1 and patorder.orderid= @orderId

	AND ppi.productId=patorder.ItemId

  

END









GO
