USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetItemReportInnerTable]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <02-08-2016>
-- Description:	<get number of item report by product Id>

-- Exec CPN_GetItemReportInnerTable '9DAD2673-093B-E611-80F1-BC764E100DD7',@fromDate = '2016-08-01', @toDate = '2016-08-15'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetItemReportInnerTable]
	@productId uniqueidentifier,
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
	AS
BEGIN
	
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

	--select distinct p.createdDate as [Date], s.initial as [SalesrepName], pr.legalName as [Practice], phy.initials as [Physician],
	-- concat(pat.nameFirst,' ',pat.namelast) as [Patient], pat.PatientId
	--, concat(prod.productDescription,' ( ', prod.CategoryName, ' )') as [Product],
	--p.productQuntity,round(convert(float,p.productPrice),2) as  productPrice
	--from patientOrders p 
	--inner join recordRelations r on r.practiceId = p.practiceId
	--inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
	--inner join practices pr on pr.practiceId = p.practiceId
	--inner join Physicians phy on phy.physicianId = p.Physicianid
	--inner join patientInfoes pat on pat.patientId = p.PatientId
	--inner join productTables prod on prod.ProductId = p.itemId
	--where p.ItemId = @productId and convert(date,p.createdDate)  > = @fDate and convert(date,p.createdDate) <= @tDate
	

	select distinct o.orderId , (select '123') as item ,pt.hcpcs, pt.productDescription, convert(float,pt.physicianCOGS) AS [unitPrice], (select  sum(productQuntity) )as Quantity
	--0 as unitsSold
	 from productTables pt
	inner join patientOrders po on po.itemId = pt.productId
	inner join orders o on o.orderid = po.orderid
	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate and po.Itemid = @productId
	group by pt.item, pt.productDescription, pt.physicianCogs, pt.productId, pt.hcpcs, o.orderId

END


GO
