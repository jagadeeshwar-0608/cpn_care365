USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetLotNumberReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <24-09-2016>
-- Description:	<Get Lotnumber tracking report>
-- CPN_GetLotNumberReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetLotNumberReport]
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20)
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
    
	select convert(date, po.createdDate) as CreatedDate, '123' as InvoiceNumber, prac.Legalname as PracticeName, phy.Initials as PhysicianName,
	concat(pat.nameFirst ,' ', pat.nameLast) as PatientName,  
 prod.productDescription , po.productQuntity as ProductQuantity , o.deliveryDate as DeliveryDate, '123456' as lotnumber
 from patientOrders po
inner join orders o on o.orderId= po.orderId
inner join practices prac on prac.practiceId = po.practiceId
inner join productTables prod on prod.productId = po.Itemid
inner join physicians phy on phy.physicianId = po.PhysicianId
inner join patientInfoes pat on pat.PatientId = po.PatientId
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate

END


GO
