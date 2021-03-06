USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetCommission_ProductReport_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <19-09-2016>
-- Description:	<CPN Commission order report>
-- [dbo].[CPN_SalesModule_GetCommission_ProductReport_BySalesId] '7FF877CF-687F-44C8-AD8E-B7122D488FDC' ,'2017-04-01','2017-04-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_GetCommission_ProductReport_BySalesId] 
	@salesId uniqueidentifier,
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
select distinct po.orderId,pt.productDescription, po.productQuntity as Quantity, ProductQuntity * ProductPrice as revenue
into #qtyData
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join recordRelations rr on rr.practiceid = po.practiceid
where po.isactive = 1 and rr.isactive = 1 and rr.salesrepid = @salesId
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate

select productDescription, sum(Quantity) as Quantity, round(convert(float, sum(revenue)),2) as revenue
into #QuantityData
from #qtyData
group by productDescription

select distinct prod.item, prod.productDescription,
convert(float, q.Quantity) as QuantityUnits, count(distinct po.orderId) as Orders, revenue,
round(convert(float, revenue*0.11),2) as Commission
from  patientOrders po  
inner join productTables prod on po.itemId = prod.productId
INNER JOIN Practices prac on po.PracticeId=prac.PracticeId
inner join recordRelations rr on rr.practiceId = prac.practiceId
inner join salesrepinfoes sale on sale.salesrepinfoId = rr.salesrepid
left join #QuantityData q on q.productDescription  = prod.productDescription
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
AND rr.salesrepid=@salesId AND po.IsActive=1 AND prod.IsActive=1
AND rr.IsActive=1
group by prod.item, prod.productDescription, commissionMoSupply, q.Quantity,revenue
END

GO
