USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_GetDashboardProviderPerformanceData_BySalesId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <21-10-2016>
-- Description:	<Get dashboard provider performance data>
-- [dbo].[CPN_SalesModule_GetDashboardProviderPerformanceData_BySalesId] '7FF877CF-687F-44C8-AD8E-B7122D488FDC'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_GetDashboardProviderPerformanceData_BySalesId]
@salesRepId uniqueidentifier	
AS
BEGIN
	SET NOCOUNT ON 
	-- interfering with SELECT statements.
	
	select distinct phy.initials, prac.legalname, po.orderid, isnull(round(convert(float,convert(float,po.productQuntity) * convert(float, po.productPrice)),2),0) as revenue
	into #revenue
	from patientorders po
	inner join practices prac on prac.practiceid = po.practiceid
	inner join physicians phy on phy.physicianId = po.physicianId
	inner join recordrelations rr on rr.practiceid = po.practiceid
	where po.isactive =1 and rr.isactive =1
	and rr.salesRepId = @salesRepId
	select initials, legalname, sum(revenue) as revenue into #revenuefinal from #revenue
	group by initials, legalname
	select top 10 p.legalname,phy.initials, count(distinct po.orderId) as pracCount, 
	min(datediff(d, convert(date,po.createdDate),convert(date,getdate()))) as lastorder into #provider
	from patientOrders po
	inner join practices p on p.practiceid = po.practiceId
	inner join physicians phy on phy.physicianId = po.physicianId
	INNER JOIN RecordRelations rr on rr.PracticeId = po.practiceId
	WHERE rr.SalesRepId = @salesRepId AND po.IsActive=1 and rr.isactive = 1
	group by po.practiceId, p.legalname, phy.initials
	order by pracCount desc
	select p.legalname, p.initials, p.pracCount, p.lastorder, round(r.revenue,2) as revenue
	from #revenuefinal r
	inner join #provider p 
	on r.legalname = p.legalname
	and r.initials = p.initials
	order by p.pracCount desc
END

GO
