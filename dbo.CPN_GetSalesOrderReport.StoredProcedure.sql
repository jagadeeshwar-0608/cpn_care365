USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesOrderReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================



-- Author:		<Jagadeeshwar Mosali>



-- Create date: <10-09-2016>



-- Description:	<Get sales order basic and detailed reports>



-- CPN_GetSalesOrderReport 'null','null'



-- =============================================



CREATE PROCEDURE [dbo].[CPN_GetSalesOrderReport]



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

min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder,

o.orderNumber as InvoiceNumber, 

o.orderstatus as orderStatus,

prac.Legalname as PracticeName, phy.Initials as PhysicianName,

 concat(pat.namefirst,' ',pat.nameLast)  as PatientName,



patShip.FacilityName as FacilityName,

patShip.[Address] as ShippingAddress,

patShip.[City] as ShippingCity,

patShip.[State] as ShippingState,

patShip.[Zip] as ShippingZip,



sum( po.productQuntity * po.productPrice) as invoiceAmount,

isnull(o.shipStatus,'') as shippingstatus,

o.paymentstatus ,

CASE WHEN o.BilledAmount=0.0 THEN null ELSE o.BilledAmount END BilledAmount,

--o.BilledAmount as BilledAmount,

o.OrderBillDate as OrderBillDate,

o.OrderPaidDate as OrderPaidDate,

CASE WHEN o.PrimaryPaidAmount=0.0 THEN null ELSE o.PrimaryPaidAmount END PrimaryPaidAmount,

--o.PrimaryPaidAmount as PrimaryPaidAmount,

CASE WHEN o.SecondaryPaidAmount=0.0 THEN NULL ELSE o.SecondaryPaidAmount END SecondaryPaidAmount,

--o.SecondaryPaidAmount as SecondaryPaidAmount,

o.shippingDate as shippingDate,

o.DeliveryDate as DeliveryDate,

o.trackingnumber

into #temp

from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

--INNER JOIN PracticeProductInfo prod on prod.PracticeId=po.practiceId

--INNER JOIN PracticeProductInfo pracProd on pracProd.[ProductId]=po.ItemId

LEFT join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId

LEFT join PatientShippingInformation patShip on patShip.PatientId = pat.PatientId



where 

convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate AND 

po.IsActive=1



group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,

o.shipstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber,

o.orderstatus,

patShip.FacilityName,

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

o.trackingnumber

select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,

t.shippingStatus ,

t.orderStatus,

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

t.trackingnumber,

t.lastorder

from #temp t

GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,

t.FacilityName,

t.[ShippingAddress],

t.[ShippingCity],

t.[ShippingState],

t.[ShippingZip] ,

t.shippingStatus,

t.paymentstatus,

t.orderStatus,

t.BilledAmount,

t.OrderBillDate,

t.OrderPaidDate ,

t.PrimaryPaidAmount, 

t.SecondaryPaidAmount ,

t.shippingDate,

t.DeliveryDate,

t.trackingnumber,

t.lastorder

	/*

 select distinct(po.orderId),convert(date,po.createdDate) as createdDate,



o.orderNumber as InvoiceNumber, s.salesRepInfoId as [RepId], s.initial as [SalesrepName],



prac.practiceId as PracticeId, prac.Legalname as PracticeName,phy.physicianId, phy.Initials as PhysicianName,



pat.PatientId, concat(pat.namefirst,' ',pat.nameLast)  as PatientName,



prod.productDescription, sum(productQuntity) as productQuantity,



prod.hcpcs,prod.medicareFreeSchedule,



--round(convert(float,po.productPrice),2) as  productPrice,



o.paymentStatus,



--  pln.LotNumber,



o.PrimaryPaidAmount , -- added by pratikg on 30/12/2016



DATEADD(day,21,o.createddate) DueDate ,  -- added by pratikg on 30/12/2016



(select 'Some Payor') as PrimaryPayor,



sum( po.productQuntity * po.productPrice) as invoiceAmount,



isnull(o.shipStatus,'') as shippingstatus



 from patientOrders po



inner join orders o on o.orderId = po.orderId



inner join practices prac on prac.practiceId = po.practiceId



inner join physicians phy on phy.physicianId = po.physicianId



inner join patientInfoes pat on pat.patientId = po.patientId



inner join recordRelations r on r.practiceId = po.practiceId



inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId



inner join productTables prod on prod.productId = po.itemid



--inner join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId



where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate

and po.isActive = 1



group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,



po.productQuntity, po.productPrice, o.shipstatus, s.initial, o.paymentstatus, prod.medicarefreeschedule,



prod.productDescription, po.productQuntity, phy.physicianId, prac.PracticeId, s.salesrepinfoId, pat.patientId,o.orderNumber



--,pln.LotNumber 



,prod.hcpcs,

o.PrimaryPaidAmount,  -- added by pratikg on 30/12/2016

o.createddate  -- added by pratikg on 30/12/2016

*/

END



GO
