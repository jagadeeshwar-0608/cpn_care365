USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetShippingReportInnerTable]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-Aug-2016>
-- Description:	<Shipping report inner table>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetShippingReportInnerTable]
	@orderId uniqueidentifier,
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
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

	select distinct p.createdDate as [Date], s.initial as [SalesrepName], pr.legalName as [Practice], phy.initials as [Physician],
	 concat(pat.nameFirst,' ',pat.namelast) as [Patient], pat.PatientId
	, concat(prod.productDescription,' ( ', prod.CategoryName, ' )') as [Product],
	p.productQuntity,round(convert(float,p.productPrice),2) as  productPrice
	from patientOrders p 
	inner join recordRelations r on r.practiceId = p.practiceId
	inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
	inner join practices pr on pr.practiceId = p.practiceId
	inner join Physicians phy on phy.physicianId = p.Physicianid
	inner join patientInfoes pat on pat.patientId = p.PatientId
	inner join productTables prod on prod.ProductId = p.itemId
	where p.orderId = @orderId and convert(date,p.createdDate)  > = @fDate and convert(date,p.createdDate) <= @tDate
END


GO
