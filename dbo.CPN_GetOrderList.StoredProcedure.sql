USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetOrderList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-09-2016>
-- Description:	<Get sales order basic and detailed reports>
-- CPN_GetOrderList '2017-01-01','2017-01-30'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetOrderList]

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



 select distinct(po.orderId) ,convert(date,po.createdDate) as createdDate,

o.orderNumber as InvoiceNumber, 
o.CPNRefNo as CPNRefNo,

prac.Legalname as PracticeName, phy.Initials as PhysicianName,

 concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

sum( po.productQuntity * po.productPrice) as invoiceAmount,
--sum(po.productQuntity) as prodQty,

case when o.shipstatus is null then 'Processing' when 
o.shipstatus = 'Delivered' then concat(o.shipStatus, ' on ', convert(varchar(10), cast(o.deliveryDate as date), 101))
 else o.shipStatus end as shippingStatus,
 o.orderstatus orderStatus,
isnull(o.paymentstatus,'Due') as paymentStatus, 
o.reportToShippingApi, o.TrackingNumber ,
o.FreightAmt as FreightAmt

into #temp

 from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

LEFT  join productLotNumber pln on pln.productLotnumberId = po.productLotNumberId

where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
and po.isActive = 1 and o.IsActive=1 

group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,
o.shipstatus,o.orderstatus, phy.physicianId, prac.PracticeId, pat.patientId,o.orderNumber, 
o.paymentStatus,o.reportToShippingApi
,o.deliveryDate, o.TrackingNumber , o.CPNRefNo , o.FreightAmt


select count(ordn.OrderId) as totalNotes ,o.orderid as orderId
into #Notetemp
from orders o left join  
ordernotes ordn on o.orderid=ordn.orderid
where o.isactive=1 and 
convert(date,o.createdDate)  > = @fDate and convert(date,o.createdDate) <= @tDate
group by ordn.OrderId,o.orderid


select t.orderId, t.createdDate, t.invoiceNumber, t.practiceName, t.physicianName, t.patientName,
sum(t.invoiceAmount) as invoiceAmount, t.TrackingNumber ,
t.shippingStatus,t.orderstatus,t.paymentStatus,t.reportToShippingApi
,t1.totalNotes , t.CPNRefNo
,t.FreightAmt

from #temp t
INNER JOIN #Notetemp t1 ON t1.orderId = t.orderId
GROUP BY t.orderId, t.createdDate, t.invoiceNumber, t.PracticeName, t.physicianName, t.PatientName,

t.shippingStatus,t.orderstatus,t.paymentstatus,t.reportToShippingApi, t.TrackingNumber 
,t1.totalNotes , t.CPNRefNo ,t.FreightAmt

--,t.prodQty

END

-- CPN_GetOrderList '2017-01-01','2017-01-30'

GO
