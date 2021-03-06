USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetCommissionOrderReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <19-09-2016>

-- Description:	<CPN Commission order report>

-- CPN_GetCommissionOrderReport '2017-03-01','2017-03-06'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetCommissionOrderReport] 

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

    -- Insert statements for procedure here

select distinct o.ordernumber as invoiceNumber, convert(date,po.createdDate) as OrderDate,
po.orderId as orderid,
s.initial as RepName,prac.legalname as PracticeName, phy.initials as physicianName , prod.ProductDescription,
productQuntity as Quantity,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
convert(date,getdate()) as commissionDate,
o.paymentStatus as customerPayment ,
convert(float,(po.productQuntity * po.ProductPrice)) as revenue

 into #commissionData
from patientOrders po

inner join recordRelations rec on rec.practiceId = po.practiceid

inner join salesrepinfoes s on s.salesrepinfoId = rec.salesrepId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join productTables prod on prod.productId = po.ItemId

inner join orders o on o.orderId = po.orderId

where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and po.isActive = 1  and rec.isactive = 1 and o.isactive=1

group by convert(date,po.CreatedDate),s.initial,prac.legalname, 
prod.productDescription,phy.initials,o.ordernumber,
po.orderId, po.productQuntity,prod.CommissionMoSupply,o.paymentstatus, po.productPrice 


select distinct invoicenumber, orderDate, orderId, repName, PracticeName, PhysicianName, 
sum(Quantity) as Quantity, sum(commission) as commission,
commissionDate, CustomerPayment, sum(revenue) as Revenue
from #commissionData
group by invoicenumber, orderdate, orderId, repname, practiceName, physicianName, commissionDate, CustomerPayment


END

-- CPN_GetCommissionOrderReport '2017-03-01','2017-03-06'

GO
