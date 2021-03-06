USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetProductsForPricing]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-15-2016>
-- Description:	<get products based on the practices>
-- CPN_GetProductsForPricing 'A66C7106-F89B-4CF9-8994-DB7DFC8C1EDC'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetProductsForPricing]
	@practiceId uniqueIdentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    -- Insert statements for procedure here
	declare @count int = (select  count(distinct p.productId) from productTables p 
	left join practiceProductInfo ppi on ppi.productId = p.productId
	where p.productId not in (select productId from practiceProductInfo where practiceId = @practiceId))

	if not exists (select top 1 null from practiceProductInfo where practiceId = @practiceid)
	begin

	insert into practiceProductInfo (practiceProductInfoId, productId,practiceId,item,productDescription,BrandName,CategoryName,HCPCS,UM,cpncogs,
	physicianCogs,medicareFreeSchedule,suggestedRetail,CommissionMoSupply,
	commissionUm,instock,tierType,productCost,Manufacturer,cashPrice,primarycommission,secondaryCommission,
	BillableUnits,ShippableUnits,DaySuppluMax,CreatedBy,createdDate,isactive,EffectivePrice,ModifiedDate,ModifiedBy)

	select  newid(), pt.productId,@practiceId,pt.item,pt.productDescription,pt.brandname,pt.categoryname,pt.hcpcs,pt.um,pt.cpncogs,
	pt.physicianCogs,pt.medicareFreeSchedule,pt.suggestedRetail,pt.commissionMosupply,
	pt.commissionum,pt.instock,pt.tiertype,pt.productCost,pt.manufacturer,pt.cashprice,pt.primarycommission, pt.secondaryCommission,
	pt.billableunits,pt.shippableunits,pt.daysupplumax,pt.createdby,pt.createdDate,pt.isactive,
	CASE WHEN Isnumeric(pt.physiciancogs) = 1 THEN CONVERT(DECIMAL(18,2),pt.physiciancogs) ELSE 0 END AS physiciancogs,pt.createddate,''
	from productTables pt
	end

	else if(@count > 0)
	begin

	insert into practiceProductInfo (practiceProductInfoId, productId,practiceId,item,productDescription,BrandName,CategoryName,HCPCS,UM,cpncogs,
	physicianCogs,medicareFreeSchedule,suggestedRetail,CommissionMoSupply,
	commissionUm,instock,tierType,productCost,Manufacturer,cashPrice,primarycommission,secondaryCommission,
	BillableUnits,ShippableUnits,DaySuppluMax,CreatedBy,createdDate,isactive,EffectivePrice,ModifiedDate,ModifiedBy)

	select  newid(), pt.productId,@practiceId,pt.item,pt.productDescription,pt.brandname,pt.categoryname,pt.hcpcs,pt.um,pt.cpncogs,
	pt.physicianCogs,pt.medicareFreeSchedule,pt.suggestedRetail,pt.commissionMosupply,
	pt.commissionum,pt.instock,pt.tiertype,pt.productCost,pt.manufacturer,pt.cashprice,pt.primarycommission, pt.secondaryCommission,
	pt.billableunits,pt.shippableunits,pt.daysupplumax,pt.createdby,pt.createdDate,pt.isactive, 
	CASE WHEN Isnumeric(pt.physiciancogs) = 1 THEN CONVERT(DECIMAL(18,2),pt.physiciancogs) ELSE 0 END AS physiciancogs,pt.createddate,''

	from productTables pt
	where pt.productId not in (select productId from practiceProductInfo where practiceId = @practiceId)
	end

	select practiceId, productId,Item,ProductDescription, Hcpcs, MedicareFreeSchedule as feeschedule, SuggestedRetail, 
	physicianCogs as standardPrice,effectivePrice,ModifiedBy, case when  ModifiedBy = '' then '' else modifiedDate  end as ModifiedDate
	from practiceProductInfo
	where practiceId = @practiceId

	

END



GO
