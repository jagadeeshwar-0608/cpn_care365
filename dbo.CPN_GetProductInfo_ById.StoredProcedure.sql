USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetProductInfo_ById]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_GetProductInfo_ById 'cec5670c-0f3e-e711-811c-bc764e100dd7'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetProductInfo_ById]

@productid uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT prod.[ProductId]
      ,prod.[Item]
      ,prod.[ProductDescription]
      ,prod.[BrandName]
      ,prod.[CategoryName]
      ,prod.[HCPCS]
      ,prod.[UM]
      ,convert(float,prod.[CPNCOGS]) as CPNCOGS
      ,convert(float,prod.[PhysicianCOGS]) as PhysicianCOGS
      ,convert(float,prod.[MedicareFreeSchedule]) as MedicareFreeSchedule
      ,convert(float,prod.[SuggestedRetail]) as SuggestedRetail
      ,prod.[CommissionMoSupply]
      ,prod.[CommissionUM]
      ,prod.[InStock]
      ,prod.[TierType]
      ,prod.[CreatedBy]
      ,prod.[CreatedDate]
      ,prod.[IsActive]
      ,prod.[ProductCost]
      ,prod.[Manufacturer]
      ,prod.[CashPrice]
      ,prod.[PrimaryCommission]
      ,prod.[SecondaryCommission]
      ,prod.[BillableUnits]
      ,prod.[ShippableUnits]
      ,prod.[DaySuppluMax]
	  ,lotnum.[LotNumber] as LotNumber
	   from [dbo].[ProductTables] prod
		INNER JOIN ProductLotNumber lotnum ON lotnum.productid = prod.productid
		WHERE prod.IsActive=1 and lotnum.IsDefault=1 and prod.productid=@productid


END

GO
