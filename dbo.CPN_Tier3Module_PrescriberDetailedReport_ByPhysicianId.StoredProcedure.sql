USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Tier3Module_PrescriberDetailedReport_ByPhysicianId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <04-03-2017>
-- Description:	<Get sales order detailed report by physician and salesRep>
-- CPN_Tier3Module_PrescriberDetailedReport_ByPhysicianId '8a4379f3-f0dc-e611-8111-bc764e100dd7', '2017-04-01','2017-04-30'

-- =============================================
CREATE PROCEDURE [dbo].[CPN_Tier3Module_PrescriberDetailedReport_ByPhysicianId] 
	-- Add the parameters for the stored procedure here
	--@salesRepId uniqueidentifier,
	@physicianId uniqueidentifier,
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
select distinct po.orderId, convert(date,po.createdDate) as OrderDate, 
o.orderNumber as invoiceNumber, s.salesRepInfoId as [Rep Name],s.initial as [salesRepName] , 
o.trackingnumber as TrackingNumber,
po.productQuntity * po.ProductPrice  invoiceAmount,
concat(pat.nameFirst ,' ',pat.nameLast) as patientName,
phy.initials as physicianName, prac.legalname practiceName,
--isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
case when o.shipstatus is null then 'Processing' else o.shipStatus end as shipStatus,
 pbo.primarypayorname as primaryPayor, o.orderWound

into #temp1
from PatientOrders po
inner join orders o on o.orderId = po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join recordRelations r on r.practiceId = po.practiceId
inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
inner join patientInfoes pat on pat.patientId = po.patientId
inner join productTables prod on prod.productId = po.itemId
inner join physicians phy on phy.physicianId = po.physicianId
left  join payorbyorders pbo on pbo.orderid = po.orderId
--INNER JOIN [dbo].[MasterUserRelation] mr ON mr.SalesRepId=r.SalesRepId
--INNER JOIN [dbo].[AspNetUsers] asp ON asp.Id=mr.UserId

where po.physicianId = @physicianId 
--and r.salesrepid = @salesRepId
and po.IsActive=1 AND o.IsActive=1 and r.isactive=1 --and mr.isactive=1
 -- AND po.PracticeId='be16084e-b8bc-4f50-a493-613deddf9b55'
 --where convert(date,po.createdDate)  = '2016-05-17'
group by po.orderId,po.createdDate,o.orderNumber,
s.salesRepInfoId,s.initial,pat.nameFirst,pat.nameLast,phy.initials,
prac.legalname,o.shipstatus,o.orderWound,po.productQuntity, po.productPrice,pbo.primarypayorname --, asp.UserName
,o.trackingnumber

--,commissionMoSupply
/* To get multiple products for single OrderId*/
select po1.orderId,
stuff((select ', ' + cast (pt.hcpcs as varchar(2000)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId
and po.physicianId = @physicianId
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') Hcpcs,
stuff((select ','  + cast(pt.productDescription as nvarchar(max)) [text()]
from patientOrders po 
inner join productTables pt on  pt.ProductId = po.ItemId 
where po.orderId = po1.orderId
and po.PhysicianId = @physicianId
for xml path(''),type)
.value ('.','NVARCHAR(MAX)'),1,1,' ') productDescription
into #temp2
from patientOrders po1
group by po1.Orderid

/* Get consolidate detailed order report */
select distinct t1.orderId,t1.OrderDate as createdDate, t1.InvoiceNumber,
t1.[Rep Name], t1.salesRepName --,t1.directorName
, sum(t1.invoiceAmount) as InvoiceAmount,t1.PatientName, t1.physicianName, t1.practiceName,
t1.shipStatus as shippingStatus, t1.primaryPayor,t1.orderWound, 
t1.TrackingNumber,
t2.hcpcs,t2.productDescription
from #temp1 t1
inner join #temp2 t2 on t2.orderId = t1.orderId
where convert(date,t1.OrderDate)  > = @fDate and convert(date,t1.OrderDate) <= @tDate
group by t1.orderId, t1.OrderDate, t1.InvoiceNumber, t1.[Rep Name] 
--,t1.directorName
, t1.patientName, t1.PhysicianName,
t1.practiceName, t1.shipstatus, t1.primarypayor, t1.orderWound, t2.hcpcs, t2.productDescription
,t1.salesRepName , t1.TrackingNumber --, t1.Commission
END
-- proc_cpn_getSalesDetailedOrderReportByPhysicianId 'DA48B38C-26FD-4E6F-9E41-484C0B7BA5F6', 'null','null'
GO
