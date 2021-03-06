USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetCommissionProductReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <19-09-2016>
-- Description:	<CPN Commission order report>
-- CPN_GetCommissionProductReport '2017-03-01','2017-03-31'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetCommissionProductReport] 
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
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
    -- Insert statements for procedure here
select distinct prod.item, count(po.orderid) Orders, 
prod.productDescription, isnull(convert(int,prod.DaySuppluMax),0) as DaySupplyMax,
convert(float, sum(productQuntity)) as QuantityUnits,
isnull(round( convert(float,commissionMoSupply),2),0) as Commission,
round(convert(float,sum(po.productQuntity * po.[ProductPrice])),2) as revenue
FROM productTables prod 
INNER JOIN patientOrders po on po.itemId = prod.productId
--INNER JOIN orders o ON o.OrderId = po.orderId
WHERE convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
 and po.isactive = 1
GROUP BY prod.item, prod.productDescription, commissionMoSupply,DaySuppluMax
END
GO
