USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesProductReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-09-2016>
-- Description:	<Get Sales Reports Product information>
-- CPN_GetSalesProductReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetSalesProductReport]
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
	select distinct pt.productId, pt.item,pt.hcpcs, pt.productDescription, count(po.orderId) as NoOfOrders,
	sum(productQuntity) as unitsSold, 
	sum( po.productQuntity * po.productPrice) as invoiceAmount,
	SUM(CONVERT(FLOAT,pt.[MedicareFreeSchedule])) as FreeSchedule
	 into #temp
	 from productTables pt
	inner join patientOrders po on po.itemId = pt.productId
	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
	AND po.IsActive=1 and pt.isactive=1
	group by pt.item, pt.productDescription, pt.physicianCogs, pt.productId, pt.hcpcs
	,pt.[MedicareFreeSchedule]

	select ProductId, Item, hcpcs, productDescription, NoofOrders, UnitsSold, InvoiceAmount,
	invoiceAmount/unitsSold as avgunitrev, invoiceAmount/NoOfOrders as avgorderRev , FreeSchedule as FreeSchedule
	 from #temp
END


GO
