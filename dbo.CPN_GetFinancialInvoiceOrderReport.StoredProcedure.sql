USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetFinancialInvoiceOrderReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================


-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get sales order basic and detailed reports>

-- CPN_GetFinancialInvoiceOrderReport 'null','null'

-- =============================================



CREATE PROCEDURE [dbo].[CPN_GetFinancialInvoiceOrderReport]

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

 concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

sum( po.productQuntity * po.productPrice) as invoiceAmount,

case when o.shipstatus is null then 'Processing' else o.shipStatus end as shippingStatus,
DATEADD(day,21,convert(date,po.createddate)) DueDate,

case when o.paymentStatus is null then 'Due' else o.paymentStatus end as paymentStatus,

isnull(o.primaryPaidAmount,0) + isnull(o.secondaryPaidAmount,0) as AmountPaid 

into #temp

 from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

LEFT join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId

where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
and po.isactive = 1


group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,

o.shipstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber,o.paymentStatus,
o.primarypaidamount,o.secondarypaidamount



select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,

sum(t.invoiceAmount) as invoiceAmount,t.AmountPaid,

t.shippingStatus, t.DueDate,t.paymentStatus

from #temp t

GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,

t.shippingStatus, t.duedate, t.paymentStatus,t.AmountPaid

END


GO
