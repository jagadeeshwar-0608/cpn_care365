USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_cpn_getSalesDetailedOrderReportByPayorId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <11-10-2016>

-- Description:	<Get sales order detailed report>

-- proc_cpn_getSalesDetailedOrderReportByPayorId '9AA2C869-F9F9-46DD-88CE-50D4A9EE439A','2017-01-01','2017-01-04'

-- =============================================

create PROCEDURE [dbo].[proc_cpn_getSalesDetailedOrderReportByPayorId] 

	-- Add the parameters for the stored procedure here
	@payorId uniqueidentifier,
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
    -- Insert statements for procedure here
/*To get general information of Order*/

select po.orderId, convert(date,po.createdDate) as OrderDate, 
o.orderNumber as invoiceNumber, s.salesRepInfoId as [Rep Name],s.initial as [salesRepName],
productQuntity * ProductPrice as invoiceAmount,
concat(pat.nameFirst ,' ',pat.nameLast) as patientName,
phy.initials as physicianName, prac.legalname practiceName,
case when o.shipstatus is null then 'Processing' 
when o.shipstatus  = 'Delivered' then concat(o.shipStatus, ' on ', convert(date,o.deliveryDate)) 
 else o.shipStatus end as shipStatus, 
 pbo.primarypayorname as primaryPayor, o.orderWound, 
 po.productQuntity *  convert(decimal(18,2),prod.medicareFreeschedule) as medicareFreeschedule
into #temp1
from PatientOrders po
inner join orders o on o.orderId = po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations r on r.practiceId = po.practiceId
inner join productTables prod on prod.productId = po.itemId
inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
inner join patientInfoes pat on pat.patientId = po.patientId
inner join physicians phy on phy.physicianId = po.physicianId
inner join payorbyorders pbo on pbo.orderId = o.orderid
where po.IsActive = 1 and pbo.primarypayorId = @payorId
--where convert(date,po.createdDate)  = '2016-05-17'
group by po.orderId,po.createdDate,o.orderNumber,
s.salesRepInfoId,s.initial,pat.nameFirst,pat.nameLast,phy.initials,
prac.legalname,o.shipstatus,o.orderWound, po.productQuntity,
 po.productPrice, pbo.primarypayorname, prod.medicareFreeschedule, o.deliveryDate

/* To get multiple products for single OrderId*/
select po1.orderId,
stuff((select ', ' + cast (pt.hcpcs as varchar(2000)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId
and po.isactive = 1
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') Hcpcs,
stuff((select ','  + cast(pt.productDescription as nvarchar(max)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId
and po.isactive = 1
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') productDescription
into #temp2
from patientOrders po1
inner join payorbyorders pbo on pbo.orderId = po1.orderId
group by po1.Orderid



/* Get consolidate detailed order report */



select distinct t1.orderId,t1.OrderDate as createdDate, t1.InvoiceNumber,
t1.[Rep Name], t1.salesRepName, sum(t1.invoiceAmount) as InvoiceAmount,t1.PatientName, t1.physicianName, t1.practiceName,
t1.shipStatus as shippingStatus, t1.primaryPayor,t1.orderWound,
 t2.hcpcs,t2.productDescription, convert(nvarchar, sum(t1.medicareFreeSchedule)) as medicareFreeSchedule
from #temp1 t1
inner join #temp2 t2 on t2.orderId = t1.orderId
where convert(date,t1.OrderDate)  > = @fDate and convert(date,t1.OrderDate) <= @tDate
group by t1.orderId, t1.OrderDate, t1.InvoiceNumber, t1.[Rep Name], t1.patientName, t1.PhysicianName,
t1.practiceName, t1.shipstatus, t1.primarypayor, t1.orderWound, t2.hcpcs, t2.productDescription
,t1.salesRepName

END



GO
