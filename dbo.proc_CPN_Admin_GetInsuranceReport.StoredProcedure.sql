USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_CPN_Admin_GetInsuranceReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <09-Dec-2016>

-- Description:	<Get Insurance report>

-- proc_CPN_Admin_GetInsuranceReport 'null','null'

-- =============================================

CREATE PROCEDURE [dbo].[proc_CPN_Admin_GetInsuranceReport]

	-- Add the parameters for the stored procedure here
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

	select distinct o.orderId, p.payorname,pbo.primarypayorname, convert(int,o.orderwound)  as orderWounds
into #wounds
from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join payorbyorders pbo on pbo.orderId = o.orderId
inner join payors p on p.payorId = pbo.primaryPayorId
where convert(date,o.createdDate) >= @fDate
and convert(date,o.createdDate)  <= @tDate and po.isactive = 1
group by p.payorname,o.orderId,o.orderwound,pbo.primarypayorname

select payorname, primarypayorname, sum(orderwounds) as wounds into #woundsdata from #wounds group by payorname,primarypayorname

	 select distinct p.payorId, p.payorName, pio.PrimaryPayorName,count(distinct pio.Orderid) as Orders,
 sum(po.productQuntity * convert(float,pt.medicarefreeschedule)) as feeCollected,
  sum(convert(float,isnull(o.primaryPaidAmount,0)) + convert(float,isnull(o.secondarypaidamount,0))) as mdcollected,
convert(float, sum(po.productQuntity * po.productPrice)) as revenue

 --,o.[OrderNumber] as orderwounds 
into #temp
 from payorbyorders pio
 inner join payors p on p.payorId = pio.primaryPayorId
 inner join patientOrders po on po.orderId = pio.orderId
 inner join productTables pt on pt.productId = po.itemId
 inner join orders o on o.orderId = po.orderId
 where convert(date,po.createdDate) >= @fDate  and convert(date,po.createdDate) <= @tDate
 and po.isactive =1
 group by p.payorId, p.payorName,pio.PrimaryPayorName 

select t1.*, t2.wounds as OrderWounds from #temp t1
left join #woundsdata t2 on t2.payorname = t1.payorname 
and t2.primarypayorname = t1.primarypayorname




END


GO
