USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetPaymentActivityReport_BySaleId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get sales order basic and detailed reports>

-- [CPN_SalesModule_GetPaymentActivityReport_BySaleId] '7FF877CF-687F-44C8-AD8E-B7122D488FDC' , '2017-01-01','2017-01-30'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_SalesModule_GetPaymentActivityReport_BySaleId]
	
	@salesId uniqueidentifier,

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
where po.orderId = po1.orderId and pt.categoryname like 'Primary'
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') Hcpcs,
stuff((select ','  + cast(pt.productDescription as nvarchar(max)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId 
and po.isactive = 1 and pt.categoryname like 'Primary'
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') productDescription
into #productData
from patientOrders po1
inner join productTables pt on pt.productId = po1.itemId
inner join recordRelations rr on rr.practiceId = po1.practiceId
where po1.isactive = 1 and rr.isactive=1 and rr.salesrepid = @salesId
and pt.categoryname like 'Primary' and convert(date,po1.createdDate) > = @fDate and convert(date,po1.createdDate) <= @tDate
group by po1.Orderid


select distinct po.orderId,pt.productDescription,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,po.ProductPrice)),2),0) as totalInvoice
into #commData
from patientOrders po 
inner join productTables pt on pt.productId = po.itemId
inner join recordRelations rr on rr.practiceid = po.practiceid
where 
po.isactive = 1 and rr.isactive = 1 and rr.salesrepid = @salesId
and pt.categoryname  = 'Primary' and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate

select orderId, sum(commission) as commission ,sum(totalInvoice) as totalInvoice
into #commissionData
from #commData
group by orderId

select distinct convert(date,po.createddate) as createdDate, po.orderId, prac.legalname as practicename, phy.initials as physicianName,
concat(pat.nameFirst , ' ', pat.nameLast) as patientName, o.paymentStatus
,s.initial, o.shipStatus, o.orderNumber as invoicenumber
into #temp
from patientOrders po 
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientid = po.patientId
inner join practices prac on prac.practiceId = po.practiceid
inner join recordrelations rr on rr.practiceId = po.practiceId
inner join salesrepinfoes s on s.salesrepinfoid = rr.salesrepid

where po.isactive = 1 and rr.isactive = 1
and rr.salesrepid = @salesId
and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate


select isnull(sum(po.productQuntity),0) as productQuntity, o.orderId
into #quantityData
from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join productTables pt on pt.productId = po.itemId
where po.isactive = 1 and convert(date,o.createdDate) > = @fDate and convert(date,o.createdDate) <= @tDate
and pt.categoryname like 'Primary'
group by o.orderid

select createddate as OrderDate, practicename,t.orderId,physicianName,patientName,paymentStatus,initial as RepName,
shipStatus as shippingStatus,invoicenumber, isnull(c.commission,0) as commission, ISNULL(c.totalInvoice,0) as totalInvoice,
 isnull(p.productDescription,'No Primary Product') as productDescription, isnull(p.hcpcs,'') as hcpcs
 ,isnull(q.productQuntity,0) as Quantity from #temp  t
 left join #productData p on p.orderid = t.orderid
left join #commissionData c on c.orderId = t.orderId
left join #quantityData q on q.orderId = t.orderId
group by createddate,practicename,t.orderId,physicianName,patientName,paymentStatus,initial,shipStatus,invoicenumber,
c.commission,c.totalInvoice,p.productDescription,p.hcpcs, q.productQuntity

END


-- [CPN_SalesModule_GetSalesBasicOrderReport_BySaleId] '9894CDB1-54E5-4128-AC7A-12851FFAB4CA' , 'null','null'



GO
