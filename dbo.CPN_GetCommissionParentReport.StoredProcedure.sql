USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetCommissionParentReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <11-Aug-2016>
-- Description:	<Commissino parent report>
-- CPN_GetCommissionParentReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetCommissionParentReport] 
@fromDate nvarchar(20),
@toDate nvarchar(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @fDate date
	declare @tDate date
	if @fromDate = 'null'
	begin
	set @fDate = '1900-01-01'
	end
	else
	begin
	set @fDate = @fromDate
	end
	if @toDate = 'null'
	begin
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end
    
	select p.ProductId, p.Item as Item, p.productDescription as [ProductDescription], p.UM as Quantity, convert(float,p.physicianCOGS) AS [UnitPrice], 

	(select count(*) from patientOrders po where po.itemId = p.productId) as UnitsSold

	from productTables p 
	where convert(date,p.createdDate) >= @fDate and convert(date,p.createdDate) < = @tDate
	
END


GO
