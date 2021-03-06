USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesRep_Commission_PracticeReport_ByMasterSalesRepId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <04-01-2017>
-- Description:	<Get master sales practice report>
-- [CPN_MasterSalesRep_Commission_PracticeReport_ByMasterSalesRepId] '33f0e6fc-557d-487c-9750-0edc0e779363','2017-03-01','2017-03-31'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesRep_Commission_PracticeReport_ByMasterSalesRepId]
	@mastersalesId uniqueidentifier ,
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
	--drop table #temp
	--drop table #temp2
select distinct phy.initials,
min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder
into #temp
from patientOrders po 
inner join practices prac on prac.practiceId= po.practiceId
inner join physicians phy on phy.physicianId= po.physicianId
inner join recordRelations rr on rr.practiceId = po.practiceId
INNER JOIN MasterUserRelation mr ON mr.SalesRepId=rr.SalesRepId
where  po.isactive = 1  and rr.isactive = 1 AND mr.IsActive=1 AND mr.UserId = @mastersalesId
and convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
group by initials
select distinct phy.initials,o.orderId,convert(int,isnull(orderWound,0)) as wounds
into #wounds
 from orders o
inner join patientOrders po on po.orderId = o.orderId
inner join physicians phy on phy.physicianId = po.physicianid
inner join recordRelations rr on rr.practiceId = po.practiceId
INNER JOIN MasterUserRelation mr ON mr.SalesRepId=rr.SalesRepId
WHERE convert(date,o.createddate) >= @fdate 
AND convert(date,o.createddate) <= @tDate
AND rr.isactive = 1 AND mr.IsActive=1 AND mr.UserId = @mastersalesId
AND po.isactive = 1
group by phy.initials,o.orderId, o.orderWound
select distinct initials, sum(wounds) as orderWounds into #woundsdata
from #wounds group by initials

select distinct phy.initials,o.orderId,phy.physicianId,productDescription,
isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission,
isnull(round(convert(float,(po.productQuntity * po.[ProductPrice])),2), 0) as revenue
into #revenue
 from orders o
INNER JOIN patientOrders po on po.orderId = o.orderId
INNER JOIN practices prac on prac.practiceid = po.practiceId
INNER JOIN physicians phy on phy.physicianId = po.physicianid
INNER JOIN recordrelations rr on rr.practiceId = po.practiceId
INNER JOIN producttables pt on pt.productId = po.itemId
INNER JOIN MasterUserRelation mr ON mr.SalesRepId=rr.SalesRepId
WHERE rr.isactive = 1 AND mr.IsActive=1 AND mr.UserId = @mastersalesId
AND convert(date,o.createddate) >= @fdate 
AND convert(date,o.createddate) <= @tDate and pt.categoryname like 'Primary' and
po.isactive = 1


select physicianId, sum(Commission) as Commission, sum(revenue) as revenue into #revenueData from #revenue
group by physicianId
select distinct prac.practiceId, prac.legalname as practiceName, phy.initials as PhysicianName,s.initial as salesrepname,
 count(distinct po.orderId) as orders,
phy.physicianId,t.lastorder,
case when t.lastOrder > 21 and t.lastOrder < 30 then 'In Active'
when t.lastorder > 30 then 'Never Active' else 'Active' end as [status],
convert(decimal(18,2),r.Commission) as Commission,
orderWounds
--round(convert(float,sum(po.productQuntity * po.[ProductPrice])),2) as revenue 
, revenue
into #final
from practices prac
INNER JOIN patientOrders po on po.practiceId = prac.practiceid
INNER JOIN physicians phy on phy.physicianId = po.physicianId
INNER JOIN recordRelations rr on rr.practiceId = po.practiceId
INNER JOIN salesRepInfoes s on s.salesrepInfoId = rr.SalesRepId
INNER JOIN MasterUserRelation mr ON mr.SalesRepId=rr.SalesRepId
LEFT JOIN #temp t on t.initials = phy.initials
LEFT JOIN #woundsdata w on w.initials = phy.initials
LEFT JOIN #revenueData r on r.physicianId = phy.physicianId
where convert(date,po.createdDate) >= @fDate and convert(date,po.createdDate) <= @tDate
and rr.isactive = 1 and po.isactive = 1 and phy.isactive = 1 AND mr.IsActive=1 AND mr.UserId = @mastersalesId
group by prac.legalname,phy.initials,s.initial,phy.physicianid,t.lastOrder,w.orderwounds,r.Commission, prac.practiceId, revenue

select practiceId, practiceName, salesrepname, sum(orders) as orders, min(lastorder) as lastorder, isnull(sum(revenue), 0) as revenue, isnull(sum(Commission), 0) as Commission, status from
#final
group by practiceId, practiceName, salesrepname, status
END
GO
