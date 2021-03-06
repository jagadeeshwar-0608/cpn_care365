USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesOrderReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Pratik Godha>
-- Create date: <02-11-2016>
-- Description:	<Get sales order basic and detailed reports>

-- CPN_GetSalesOrderReportByPracticeId 'f4d6d8b0-9885-4f34-8033-0b3ee47abef2','2017-04-15','2017-04-18'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetSalesOrderReportByPracticeId]

	@practiceId uniqueidentifier,
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


	select distinct o.orderId, o.ordernumber, phy.initials,sales.[Initial] as SalesRepName, sum(po.productQuntity *  convert(decimal(18,2),pt.medicareFreeschedule)) as medicareFreeschedule

		into #salesRep
		from orders o
		inner join patientOrders po on o.orderId = po.orderid
		inner join physicians phy on phy.physicianId = po.physicianId
		inner join productTables pt on pt.productId = po.itemId
		inner join recordrelations rr on rr.practiceId = po.practiceId
		INNER JOIN [dbo].[salesRepInfoes] sales ON sales.[salesRepInfoId] = rr.[SalesRepId]
		where  po.isactive = 1 
		--and pt.categoryname like 'Primary' 
		and rr.isactive = 1 and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
		and po.practiceId = @practiceId
		group by o.orderId, o.ordernumber, phy.initials,sales.[Initial]
		
		
select distinct(po.orderId),convert(date,po.createdDate) as createdDate,

o.orderNumber as InvoiceNumber, 

 -- o.orderstatus as orderStatus,

case when o.shipstatus is null then 'Processing' 

when o.trackingnumber  is not null and o.deliverydate is not null

 then 'Delivered' 

 else o.shipStatus end as orderS,

case when o.shipstatus is null then 'Processing' 

when o.trackingnumber  is not null and o.deliverydate is not null

 then concat('Delivered', ' on ', ' ') 

 else o.shipStatus end as DeliveredOn,

 case when o.shipstatus is null then 'Processing' 

when o.trackingnumber  is not null and o.deliverydate is not null

 then concat('Delivered', ' on ', convert(date,o.deliveryDate)) 

 else o.shipStatus end as orderStatus,

prac.Legalname as PracticeName, phy.Initials as PhysicianName,

concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

o.[PlaceOfService] as PlaceOfService,

place.[PlaceOfServiceName] as FacilityName,

patShip.[Address] as ShippingAddress,

patShip.[City] as ShippingCity,

patShip.[State] as ShippingState,

patShip.[Zip] as ShippingZip,

sum( po.productQuntity * po.productPrice) as invoiceAmount,

case when o.shipstatus is null then 'Processing' 

when o.trackingnumber  is not null and o.deliverydate is not null

 then concat('Delivered', ' on ', convert(date,o.deliveryDate)) 

 else o.shipStatus end as shippingstatus, 

o.paymentstatus ,

o.BilledAmount as BilledAmount,

o.OrderBillDate as OrderBillDate,

o.OrderPaidDate as OrderPaidDate,

o.PrimaryPaidAmount as PrimaryPaidAmount,

o.SecondaryPaidAmount as SecondaryPaidAmount,

o.shippingDate as shippingDate,

o.DeliveryDate as DeliveryDate,

o.trackingnumber



into #temp

from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

LEFT JOIN [dbo].[PlaceOfServiceMasterTable] place on place.[PlaceOfServiceNumber]=o.[PlaceOfService]

--INNER JOIN PracticeProductInfo prod on prod.PracticeId=po.practiceId

--INNER JOIN PracticeProductInfo pracProd on pracProd.[ProductId]=po.ItemId

LEFT join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId

LEFT join PatientShippingInformation patShip on patShip.PatientId = pat.PatientId

where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate AND 

po.practiceId= @practiceId AND po.IsActive=1

group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,

o.shipstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber,

o.orderstatus,

place.[PlaceOfServiceName],

patShip.[Address],

patShip.[City],

patShip.[State],

patShip.[Zip] ,

o.paymentstatus,

o.BilledAmount,

o.OrderBillDate ,

o.OrderPaidDate ,

o.PrimaryPaidAmount ,

o.SecondaryPaidAmount ,

o.shippingDate,

o.DeliveryDate,

o.[PlaceOfService],

o.trackingnumber


select count(ordn.OrderId) as totalNotes ,o.orderid as orderId
into #Notetemp
from orders o left join  
ordernotes ordn on o.orderid=ordn.orderid
where o.isactive=1 and 
convert(date,o.createdDate)  > = @fDate and convert(date,o.createdDate) <= @tDate
group by ordn.OrderId,o.orderid

select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,

t.shippingStatus ,

t.orderStatus,

t.DeliveredOn,

t.orderS,

t.FacilityName,

t.ShippingAddress,

t.[ShippingCity],

t.[ShippingState],

t.[ShippingZip] ,

sum(t.invoiceAmount) as invoiceAmount,

t.paymentstatus,

t.BilledAmount,

t.OrderBillDate,

t.OrderPaidDate,

t.PrimaryPaidAmount ,

t.SecondaryPaidAmount ,

t.shippingDate,

t.DeliveryDate,

t.PlaceOfService,

t.trackingnumber,
t1.totalNotes
 into #final
from #temp t
INNER JOIN #Notetemp t1 ON t1.orderId = t.orderId

GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,

 t.FacilityName,

t.[ShippingAddress],

t.[ShippingCity],

t.[ShippingState],

t.[ShippingZip] ,

t.shippingStatus,

t.paymentstatus,

t.orderStatus,

t.DeliveredOn,

t.orderS,

t.BilledAmount,

t.OrderBillDate,

t.OrderPaidDate ,

t.PrimaryPaidAmount, 

t.SecondaryPaidAmount ,

t.shippingDate,

t.DeliveryDate,

t.PlaceOfService,

t.trackingnumber,
t1.totalNotes

select t.*, sp.SalesRepName, cast(medicareFreeschedule as varchar) as medicareFreeschedule
from #final t
inner join #salesRep sp on  t.invoiceNumber = sp.ordernumber


-- CPN_GetSalesOrderReportByPracticeId '1e165131-54cf-403f-b8e8-28d353a60178','2017-01-01','2017-01-14'

END
GO
