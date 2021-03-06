USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MdProfitabilityReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <13-09-2016>

-- Description:	<Jagadeeshwar Mosali>

-- CPN_MdProfitabilityReport'2017-06-01','2017-06-30'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_MdProfitabilityReport]

@fromDate nvarchar(20) = null,

	@toDate nvarchar(20) = null


	--select 916.33 + 233.76 --450.09

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



select distinct(ord.OrderNumber),

po.orderid as orderid, 

po.practiceid,

convert(date,po.createdDate) as createdDate,

ord.OrderNumber as InvoiceNumber, prac.Legalname as PracticeName,phy.Initials as PhysicianName,

concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

sum(productQuntity) as productQuantity,

prod.medicareFreeSchedule as medicareFreeSchedule,

sum( po.productQuntity * po.productPrice) as invoiceAmount,

payord.PrimaryPayorName as primaryInsurance, payord.SecondaryPayorName as secondaryInsurance

, 0 as collectionFeeSchedule , 

convert(int,ord.orderwound) as orderWounds,

isnull(ord.PrimaryPaidAmount,0) + isnull(ord.secondarypaidamount,0) as CollectedAmount,

prod.[CPNCOGS] as CPNCOGS

 into #report

from patientOrders po 

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

inner join productTables prod on prod.productId = po.itemId

INNER JOIN orders ord on ord.OrderId=po.OrderId

INNER JOIN PayorByOrders payord on payord.OrderId =  po.OrderId

where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate

AND po.IsActive=1 AND ord.IsActive=1 
group by po.PatientOrderId , po.orderid , po.createdDate, prac.legalname,

 phy.initials, pat.namefirst,

  pat.namelast, productQuntity, prod.medicareFreeSchedule,

  ord.OrderNumber,ord.orderwound,

payord.PrimaryPayorName,payord.SecondaryPayorName ,ord.PrimaryPaidAmount,ord.secondarypaidamount,

prod.[CPNCOGS],

po.practiceid


select orderid, InvoiceNumber,

convert(date,createdDate) as createdDate,

sum(convert(float,medicareFreeSchedule) * convert(float,productQuantity)) as medicareFreeSchedule,

sum(invoiceAmount) as invoiceAmount

into #temp1

from #report 

group by InvoiceNumber, orderid , createdDate


select distinct InvoiceNumber, orderid,

practiceid, convert(date,createdDate) as createdDate,

PracticeName, PhysicianName,

PatientName, primaryInsurance, secondaryInsurance,

orderWounds, CollectedAmount

into #temp2

from #report

Order BY InvoiceNumber desc


--select * from #report

select t1.orderid , t1.createdDate, t1.InvoiceNumber, practicename,

physicianName, medicareFreeSchedule,

CollectedAmount,

primaryInsurance,PatientName, orderWounds,practiceid

from #temp1 t1
inner join #temp2 t2 on t1.orderid = t2.orderid

END


-- CPN_MdProfitabilityReport_1 '2017-06-01','2017-06-30'



GO
