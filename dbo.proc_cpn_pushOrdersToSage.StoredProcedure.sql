USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_cpn_pushOrdersToSage]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <13-12-2016>
-- Description:	<Push order details to sage for accounting and shipment process>
-- proc_cpn_pushOrdersToSage 'E5098B2E-EB39-47D1-A6BE-DC6649825D28'
-- =============================================
CREATE PROCEDURE [dbo].[proc_cpn_pushOrdersToSage] 
	
	@orderId uniqueidentifier
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
if exists  (select top 1 null from sageAccountingOrder  where orderId = @orderId)
begin
delete from sageAccountingOrder where orderId = @orderId
end 

insert into sageAccountingOrder ([Type], OrderId,  OrderDate, InvoiceNumber, SageAccount,PracticeName, practiceAddress1, practiceaddress2, practiceCity, practiceState, practiceZip,
DueDate, Physician, NPI, placeOfService, item,itemDescription, InsuranceClass, InsuranceType, salesRepCode, PaymentStatus, itemQty, UM, SalesPrice,
TotalAmount, SO, Hcpcscode, billableUnits,Modifier, ShipName, FacilityName, ShipToRoom, ShiptoBed, ShipToaddress1,Shiptoaddress2,shiptocity, 
shiptostate,shiptozip, shiptoPhone, LotNumber, OrderWounds,icd10,IsActive,Linekey,ShipToCode,carriorCode
)

select (select 'Invoice') as [Type],po.OrderId, convert(date, o.createdDate) as OrderDate, o.OrderNumber,
 prac.sageCustomerId as sageAccount, 
prac.legalname, prac.address1, prac.address2, prac.city, prac.state, prac.zip, 
convert(date, getdate()) as DueDate,  phy.initials as Physician, phy.NPI,
o.placeofservice, pt.item, pt.productDescription , pbo.primaryPayorName,
p.payorName as payorType, prac.salesRep, o.paymentStatus, po.productQuntity, pt.UM, po.productPrice, 
po.productQuntity * po.productPrice as Amount, ' ' as SO, pt.hcpcs,  pt.billableUnits * po.productQuntity, 
pm.productModifierName, concat( psi.firstname ,' ' , psi.lastname) shipname, psi.facilityName, shiproom, shipbed, shipsuit as shiptoaddress1, 
psi.address as shiptoaddress2, psi.city, psi.state, psi.zip,psi.phone,
pln.LotNumber, o.orderwound, o.icd10,1, right(1000000+ROW_NUMBER() OVER(PARTITION BY OrderNumber ORDER BY OrderNumber),6) as LineKey , psi.shiptoCode,
pn.carriorCode
 

from
patientOrders  po
inner join orders o on o.orderid = po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianId = po.physicianId
inner join payorbyorders pbo on pbo.orderId = po.orderId
inner join payors p on p.payorId = pbo.primaryPayorId
inner join payorname pn on pn.payor = pbo.primarypayorname
left join productLotNumber pln on pln.productLotNumberId = po.productLotNumberId
inner join productModifier pm on pm.productModifierId = po.productModifierId
inner join patientShippingInformation psi on psi.patientId = po.patientId
where po.orderId = @orderId


select * from sageAccountingOrder where orderId = @orderId

END



GO
