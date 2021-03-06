USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_CPNReportAdmin]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <12-Aug-2016>
-- Description:	<CPN Profit Admin only>
-- CPN_CPNReportAdmin 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_CPNReportAdmin]
	-- Add the parameters for the stored procedure here
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
   
   
   select convert(date,o.createdDate) as [Date], count(po.orderId) as [Orders],
    round(convert(float,sum(productPrice),2),2) as [OrderRevenue],  
	round(convert(float,sum(convert(float,1)),2),2) as [ProductCost],
	-- round(convert(float,sum(productCost),2),2) as [ProductCost]
	(select convert(float,15)) as shippingCost, (select  convert(float,10)) as commission

    from Orders o
   inner join patientOrders po on po.orderId = o.orderId
   inner join productTables pt on pt.productId = po.itemid
 where convert(date,o.createdDate) >= @fDate and convert(date,o.createdDate) <= @tDate
   group by convert(date,o.createdDate)
	
END


GO
