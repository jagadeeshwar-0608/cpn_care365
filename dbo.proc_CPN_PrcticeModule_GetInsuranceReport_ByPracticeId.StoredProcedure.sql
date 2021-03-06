USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_CPN_PrcticeModule_GetInsuranceReport_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <09-Dec-2016>

-- Description:	<Get Insurance report>

-- proc_CPN_PrcticeModule_GetInsuranceReport_ByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', 'null','null'

-- =============================================

CREATE PROCEDURE [dbo].[proc_CPN_PrcticeModule_GetInsuranceReport_ByPracticeId]

	-- Add the parameters for the stored procedure here
	@practiceid uniqueidentifier ,
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

select distinct o.orderId, pbo.primarypayorname, convert(int,o.orderWound) as orderWounds
into #temp
from orders o 
inner join patientOrders po on po.orderId = o.orderId
inner join payorbyorders pbo on pbo.orderId = o.orderId
where po.isactive = 1 and po.practiceId = @practiceid
and convert(date,po.createddate) >= @fDate and convert(date,po.createdDate) <=@tDate


select primarypayorname, sum(orderWounds) as orderWounds 
into #woundsdata
from #temp
group by primarypayorname


select count(distinct po.orderId) as orders,p.payorId,
p.payorname, pbo.primaryPayorname,
sum(po.productQuntity * convert(float, pt.medicarefreeschedule)) as feeCollected, 
convert(float,sum(po.productQuntity * po.productPrice)) as Revenue
,wd.orderWounds,isnull(sum(convert(float,o.primaryPaidAmount)),0) as mdcollected
from patientOrders po 
inner join payorbyorders pbo on pbo.orderId = po.orderId
inner join payors p on p.payorId = pbo.primarypayorId
inner join orders o on o.orderId = po.orderId
inner join productTables pt on pt.productId = po.itemId
left join #woundsdata wd on wd.primarypayorname =  pbo.primarypayorname
where po.isactive = 1 and po.practiceId = @practiceid
and convert(date,po.createddate) >= @fDate and convert(date,po.createdDate) <=@tDate
group by payorname, pbo.primarypayorname, wd.orderWounds,p.payorId


END


GO
