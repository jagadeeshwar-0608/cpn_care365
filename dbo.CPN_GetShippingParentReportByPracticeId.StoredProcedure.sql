USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetShippingParentReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
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
CREATE PROCEDURE [dbo].[CPN_GetShippingParentReportByPracticeId]
	@practiceId uniqueidentifier ,
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
concat(pat.address1,'',pat.Address2,'',pat.city,'', pat.state,'',pat.zip) as ShipAddress, convert(date,o.createdDate) as CreatedDate,
shippingdate, deliveryDate, shipstatus
from orders o
inner join patientOrders po on po.orderId = o.orderID
inner join Practices prac on prac.practiceId = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientId = po.patientId
	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
	AND po.practiceId =@practiceId
END


GO
