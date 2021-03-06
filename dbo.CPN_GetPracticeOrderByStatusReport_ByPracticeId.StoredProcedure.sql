USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPracticeOrderByStatusReport_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================

-- Author:		<Pratik Godha>

-- Create date: <02-11-2016>

-- Description:	<Get sales order basic and detailed reports>

-- CPN_GetSalesOrderReportByPracticeId 'E202E9EC-9644-4877-86C3-9466E798D941','null','null'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetPracticeOrderByStatusReport_ByPracticeId]

	@practiceId uniqueidentifier
AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;

select distinct(po.orderId),convert(date,po.createdDate) as createdDate,
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
o.paymentstatus 
-- '' as MedicareFreeSchedule

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

where  po.practiceId= @practiceId AND po.IsActive=1

group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,
o.shipstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber,
o.orderstatus,
patShip.FacilityName,
patShip.[Address],
patShip.[City],
patShip.[State],
patShip.[Zip] ,
o.paymentstatus 
--,prod.MedicareFreeSchedule

select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,
t.shippingStatus ,
t.orderStatus,
t.FacilityName,
t.ShippingAddress,
t.[ShippingCity],
t.[ShippingState],
t.[ShippingZip] ,
sum(t.invoiceAmount) as invoiceAmount,
t.paymentstatus
--,t.MedicareFreeSchedule

from #temp t

GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,
t.FacilityName,
t.[ShippingAddress],
t.[ShippingCity],
t.[ShippingState],
t.[ShippingZip] ,
t.shippingStatus,
t.paymentstatus,
t.orderStatus

END




GO
