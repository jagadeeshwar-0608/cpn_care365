USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetSalesBasicOrderReport_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================


-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get sales order basic and detailed reports>

-- [dbo].[CPN_SalesModule_GetSalesBasicOrderReport_BySalesId] '9894CDB1-54E5-4128-AC7A-12851FFAB4CA','null','null'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_SalesModule_GetSalesBasicOrderReport_BySalesId]

	@salesId uniqueidentifier ,
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

	set @tDate = convert(date,getdate())

	end

	else

	begin

	set @tDate = @toDate

	end



 select distinct(po.orderId),convert(date,po.createdDate) as createdDate,

o.orderNumber as InvoiceNumber, 

prac.Legalname as PracticeName, phy.Initials as PhysicianName,
salesRep.Initial as SalesRepName ,
 concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

sum( po.productQuntity * po.productPrice) as invoiceAmount,

isnull(o.shipStatus,'') as shippingstatus

, prod.ProductDescription,
 sum(productQuntity) as Quantity,
round(convert(float,sum(convert(float,po.productQuntity/30) * convert(float,commissionMoSupply))),2) as Commission,
convert(date,getdate()) as commissionDate,
'' as customerPayment 


into #temp

 from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

LEFT join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId

INNER JOIN RecordRelations rr on rr.PracticeId=po.practiceId
INNER JOIN salesRepInfoes salesRep ON salesRep.salesRepInfoId  = rr.SalesRepId
inner join productTables prod on prod.productId = po.ItemId

where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
AND rr.SalesRepId= @salesId

group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,

o.shipstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber
,salesRep.Initial

,prod.ProductDescription,
productQuntity ,
po.productQuntity



select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,
t.SalesRepName,
sum(t.invoiceAmount) as invoiceAmount,

t.shippingStatus ,
t.SalesRepName,
t.ProductDescription,
t.Quantity,
t.commissionDate,
t.customerPayment


from #temp t

GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,

t.shippingStatus,
t.SalesRepName,
t.ProductDescription,
t.Quantity,
t.commissionDate,
t.customerPayment

END

--select * from salesRepInfoes where firstName like '%kartik%' 

GO
