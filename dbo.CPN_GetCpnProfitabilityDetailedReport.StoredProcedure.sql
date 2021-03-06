USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetCpnProfitabilityDetailedReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <19-09-2016>
-- Description:	<Financial Cpn Profitability detailed Report>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetCpnProfitabilityDetailedReport]
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
select distinct convert(date,po.CreatedDate) OrderDate, '123' as Invoice , rep.initial as RepName, prac.Legalname as PracticeName,
phy.initials, concat(pat.nameFirst,' ',pat.nameLast) as PatientName, prod.ProductDescription,
po.productQuntity, prod.medicareFreeSchedule,  po.ProductPrice as Revenue, prod.cpncogs,0 as shippingCost, 
0 as Commission, '' as primaryInsurance, '' as secondaryInsurance

from patientOrders po 
inner join recordRelations rec on rec.practiceId = po.practiceId
inner join salesRepInfoes  rep on rep.SalesrepinfoId = rec.salesrepid
inner join practices prac on prac.practiceId = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientId = po.patientId
inner join productTables prod on prod.productId = po.itemid
inner join orders o on o.orderId = po.orderId
left join patientShippingInformation ship on ship.PatientId = po.PatientId
left join payorbyorders pay on pay.orderId = po.orderId
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
END


GO
