USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Tier3Module_GetCommission_OrderReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-09-2016>
-- Description:	<Get sales order basic and detailed reports>
-- CPN_Tier3Module_GetCommission_OrderReport '2017-04-03','2017-04-03'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_Tier3Module_GetCommission_OrderReport]
	
	--@mastersalesId uniqueidentifier,
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
 select po1.orderId,
stuff((select ', ' + cast (pt.hcpcs as varchar(2000)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId 
--and pt.categoryname like 'Primary'
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') Hcpcs,
stuff((select ','  + cast(pt.productDescription as nvarchar(max)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId 
and po.isactive = 1 
--and pt.categoryname like 'Primary'
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') productDescription
into #productData
from patientOrders po1
inner join productTables pt on pt.productId = po1.itemId
inner join recordRelations rr on rr.practiceId = po1.practiceId
--INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
where po1.isactive = 1 and rr.isactive=1 --AND mr.isactive=1 
--and mr.UserId = @mastersalesId
--and pt.categoryname like 'Primary' 
and convert(date,po1.createdDate) > = @fDate and convert(date,po1.createdDate) <= @tDate
group by po1.Orderid

select po1.Orderid, (select sum(cast(pt.medicareFreeschedule as float) * po.ProductQuntity) as medicareFreeschedule
from  patientOrders po
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId 
and po.isactive = 1) as feeschedule into #medicareFreeschedule
from patientOrders po1
inner join productTables pt on pt.productId = po1.itemId
inner join recordRelations rr on rr.practiceId = po1.practiceId
--INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId

where po1.isactive = 1 and rr.isactive=1 --AND mr.isactive=1 --and mr.UserId = @mastersalesId
--and pt.categoryname like 'Primary' 
and convert(date,po1.createdDate) > = @fDate and convert(date,po1.createdDate) <= @tDate
group by po1.Orderid
select distinct po.orderId,pt.productDescription,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,po.Productprice)),2),0) as totalInvoice
into #commData
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join recordRelations rr on rr.practiceid = po.practiceid
--INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
WHERE
po.isactive = 1 and rr.isactive = 1 --AND mr.isactive=1 --and mr.UserId = @mastersalesId
--and pt.categoryname  = 'Primary' 
and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate
select orderId, sum(commission) as commission , sum(totalInvoice) as totalInvoice
into #commissionData
from #commData
group by orderId

select distinct convert(date,po.createddate) as createdDate, po.orderId, prac.legalname as practicename, phy.initials as physicianName,
concat(pat.nameFirst , ' ', pat.nameLast) as patientName, o.paymentStatus
,s.initial, 

case when o.shipstatus is null then 'Processing' 
when o.trackingnumber  is not null and o.deliverydate is not null
then concat('Delivered', ' on ', convert(date,o.deliveryDate))
else o.shipStatus end as shipStatus,
o.trackingnumber, 
--, o.shipStatus,

o.orderNumber as invoicenumber, o.orderwound, pbo.primarypayorname --, asp.UserName as directorName
into #temp
from patientOrders po 
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientid = po.patientId
inner join practices prac on prac.practiceId = po.practiceid
inner join recordrelations rr on rr.practiceId = po.practiceId
inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid
--INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=rr.SalesRepId
--INNER JOIN [dbo].[AspNetUsers] asp ON asp.Id=mr.UserId
inner join payorbyorders pbo on pbo.orderId = o.orderid
where po.isactive = 1 and rr.isactive = 1 --AND mr.isactive=1 -- and mr.UserId = @mastersalesId
and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate
select isnull(sum(po.productQuntity),0) as productQuntity, o.orderId
into #quantityData
from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join productTables pt on pt.productId = po.itemId
where po.isactive = 1 and convert(date,o.createdDate) > = @fDate and convert(date,o.createdDate) <= @tDate
--and pt.categoryname like 'Primary'
group by o.orderid

select createddate as OrderDate, practicename,t.orderId,physicianName,patientName,paymentStatus,initial as RepName,
shipStatus as shippingStatus,
trackingnumber as trackingnumber , invoicenumber, isnull(c.commission,0) as commission, isnull(c.totalInvoice,0) as totalInvoice,
 isnull(p.productDescription,'No Primary Product') as productDescription, isnull(p.hcpcs,'') as hcpcs
 ,isnull(q.productQuntity,0) as Quantity, orderwound, primarypayorname, fs.feeschedule
 --,t.directorName as directorName
 from #temp  t
left join #productData p on p.orderid = t.orderid
left join #commissionData c on c.orderId = t.orderId
left join #quantityData q on q.orderId = t.orderId
inner join #medicareFreeschedule fs on t.orderid = fs.orderid
group by createddate,practicename,t.orderId,physicianName,patientName,paymentStatus,initial,shipStatus, trackingnumber ,invoicenumber,
c.commission,c.totalInvoice,p.productDescription,p.hcpcs, q.productQuntity, orderwound, primarypayorname, fs.feeschedule 
--, directorName
order by initial, createddate
END
-- CPN_MasterSalesModule_GetSalesBasicOrderReport_ByMasterId '913CDCA5-2892-4DF9-BE02-8AFDB87BD8E1' , '2017-01-01','2017-01-30'
GO
