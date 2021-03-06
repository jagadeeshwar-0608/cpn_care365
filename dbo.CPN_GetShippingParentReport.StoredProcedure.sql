USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetShippingParentReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-Aug-2016>
-- Description:	<get shipping report details>
-- CPN_GetShippingParentReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetShippingParentReport]
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
AS
BEGIN
	
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
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end
	select distinct o.OrderId, orderNumber as OrderNumber, prac.legalname as PracticeName, phy.initials as PhysicianName, concat(pat.namefirst,' ', nameLast) as PatientName, 
	pat.address1 as shipAddress1, pat.address2 as shipaddress2,pat.city as shipCity, pat.state as shipState, pat.zip as shipZip,
concat(pat.address1,'',pat.Address2,'',pat.city,'', pat.state,'',pat.zip) as ShipAddress, convert(date,o.createdDate) as CreatedDate,
shippingdate, deliveryDate, 
case when o.shipstatus is null then 'Processing' when 
o.shipstatus = 'Delivered' then concat(o.shipStatus, ' on ', convert(varchar(10), cast(o.deliveryDate as date), 101))
 else o.shipStatus end as shipStatus,
o.TrackingNumber,
o.shipstatus as shippingStatus

from orders o
inner join patientOrders po on po.orderId = o.orderID
inner join Practices prac on prac.practiceId = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientId = po.patientId
	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
	and po.isActive = 1

END


GO
