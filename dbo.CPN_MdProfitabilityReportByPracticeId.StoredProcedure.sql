USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MdProfitabilityReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <13-09-2016>
-- Description:	<Jagadeeshwar Mosali>
-- CPN_MdProfitabilityReportByPracticeId 'ff3d2afd-1d48-4d09-ad3d-0b691bd6cf6a','2017-01-01','2017-03-15'

--exec CPN_MdProfitabilityReportByPracticeId '1e165131-54cf-403f-b8e8-28d353a60178', '2017-01-01','2017-04-30'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MdProfitabilityReportByPracticeId]
    @practiceId uniqueidentifier,
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
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end
	select distinct(po.orderid), convert(date,po.createdDate) as createdDate,
o.orderNumber  as InvoiceNumber,
convert(int,o.orderwound) as orderWounds,
 prac.Legalname as PracticeName,phy.Initials as PhysicianName,
concat(pat.namefirst,' ',pat.nameLast)  as PatientName,
prod.productDescription, sum(productQuntity) as productQuantity,
convert(float,prod.medicareFreeSchedule) as medicareFreeSchedule,
isnull(sum( po.productQuntity * po.productPrice),0) as invoiceAmount,
--Ppayor.PayorName as primaryInsurance, Spayor.PayorName as secondaryInsurance -- // Commented by Pratik G on 27/12/16
payororder.PrimaryPayorName as primaryInsurance,
 payororder.SecondaryPayorName as secondaryInsurance
--, sum(isnull(o.PrimaryPaidAmount,0) + isnull(o.SecondaryPaidAmount), 0) as CollectedAmount 
, o.PrimaryPaidAmount as CollectedAmount 
 into #report
from patientOrders po 
inner join practices prac on prac.practiceId = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianId
inner join patientInfoes pat on pat.patientId = po.patientId
inner join productTables prod on prod.productId = po.itemId
INNER JOIN orders o on o.orderid=po.orderid
INNER JOIN [dbo].[PayorByOrders] payororder ON payororder.OrderId = po.orderid 
LEFT JOIN Payors Ppayor on Ppayor.PayorId = payororder.PrimaryPayorId
LEFT JOIN Payors Spayor on Spayor.PayorId = payororder.SecondaryPayorId  
where  po.PracticeId=@practiceId AND convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
AND po.IsActive=1 AND o.IsActive=1 
--AND prod.categoryName like 'Primary'
group by po.orderid, po.createdDate, prac.legalname,
 phy.initials, prod.productDescription, pat.namefirst,
  pat.namelast, productQuntity, prod.medicareFreeSchedule,
o.orderNumber , o.orderwound ,
payororder.PrimaryPayorName,
payororder.SecondaryPayorName,
o.PrimaryPaidAmount
--Ppayor.PayorName ,Spayor.PayorName  -- // Commented by Pratik G on 27/12/16
select orderid , createdDate, InvoiceNumber, practicename,
physicianName, sum(convert(float,medicareFreeSchedule) * convert(float,productQuantity)) as medicareFreeSchedule,
collectedamount as CollectedAmount 
-- commented by pratikG on 15/03/2017 and confirmed by Harry
--sum(collectedamount) as CollectedAmount  
, sum(invoiceAmount) as InvoiceAmount,
primaryInsurance,PatientName, orderWounds -- ,practiceid
from #report
group by orderid,  createdDate, InvoiceNumber,practiceName, PhysicianName,PrimaryInsurance, patientName,
orderWounds,CollectedAmount  -- ,practiceid
END
--select * from [dbo].[PayorByOrders]
--select * from [dbo].[Payors]
-- CPN_MdProfitabilityReportByPracticeId '1e165131-54cf-403f-b8e8-28d353a60178','2017-01-01','2017-01-30'
GO
