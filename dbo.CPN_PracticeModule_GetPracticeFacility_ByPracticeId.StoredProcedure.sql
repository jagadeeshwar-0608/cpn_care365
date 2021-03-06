USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_GetPracticeFacility_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <12-12-2016>
-- Description:	<Get practice facility by practice id>
-- CPN_PracticeModule_GetPracticeFacility_ByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_PracticeModule_GetPracticeFacility_ByPracticeId] 
	-- Add the parameters for the stored procedure here
	@practiceId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select a.facilityName, isnull(a.Orders,0) as Orders, isnull( a.wounds,0) as Wounds,

isnull( b.medicare,0) as Medicare, isnull(c.medicare ,0) as commercial, isnull(a.fsrevenue,0) as fsrevenue,
convert(decimal(18,2),(isnull(a.fsrevenue,0) / isnull(a.Orders,0))) as  AvgRevenue
from
(

select fp.facilityName, count(distinct o.orderId) as Orders, sum(convert(int,o.orderWound)) as Wounds ,
sum(po.productQuntity * convert(float, pt.medicarefreeschedule)) as fsrevenue
from facilitybypractice fp  
inner join patientOrders po on po.practiceId = fp.practiceId
inner join orders o on o.orderId = po.orderId
inner join placeofServiceMastertable psmt on psmt.placeofserviceNumber = o.placeofService
inner join payorbyorders pbo on pbo.orderId = o.orderId
inner join productTables pt on pt.productId = po.itemId
inner join payors p on p.payorid = pbo.primaryPayorId or p.payorId = pbo.secondaryPayorId
where p.isactive=1 and po.practiceId = @practiceId AND po.IsActive=1 AND o.IsActive=1 AND fp.IsActive=1
group by fp.facilityName) a

left join
(
select fp.facilityname, count(distinct po.orderId)  as medicare
from facilitybypractice fp 
inner join patientOrders po on po.practiceId = fp.practiceId
inner join payorbyorders pbo on pbo.orderId = po.orderId
inner join orders o on o.orderId = po.orderId
inner join placeofServiceMastertable psmt on psmt.placeofserviceNumber = o.placeofService
where pbo.primaryPayorId = 'D31168CF-7034-4EC5-AC87-1AB18CF511F6' and po.practiceId = @practiceId
AND po.IsActive=1
group by fp.facilityName) b 
on a.facilityName = b.facilityName

left join
(
select fp.facilityname, count(distinct po.orderId)  as medicare
from facilitybypractice fp 
inner join patientOrders po on po.practiceId = fp.practiceId
inner join payorbyorders pbo on pbo.orderId = po.orderId
inner join orders o on o.orderId = po.orderId
inner join placeofServiceMastertable psmt on psmt.placeofserviceNumber = o.placeofService
where pbo.primaryPayorId <> 'D31168CF-7034-4EC5-AC87-1AB18CF511F6'  and po.practiceId = @practiceId
AND po.IsActive=1
group by fp.facilityName) c
on a.facilityName = c.facilityName

END


GO
