USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_GetDashboardProviderPerformanceData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <21-10-2016>

-- Description:	<Get dashboard provider performance data>

-- [dbo].[CPN_PracticeModule_GetDashboardProviderPerformanceData_ByPracticeId] 'B6E76840-6424-4A84-82D1-F1D3F35FED0D'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_PracticeModule_GetDashboardProviderPerformanceData_ByPracticeId]

@practiceId uniqueidentifier	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;

    -- Insert statements for procedure here

select top 5 p.legalname,phy.initials, count(distinct po.orderid) as pracCount, 
convert(float,sum(po.productQuntity * convert(float,pt.medicareFreeSchedule))) as revenue
--sum(productQuntity * ProductPrice) as revenue

from patientOrders po
inner join practices p on p.practiceid = po.practiceId
inner join physicians phy on phy.physicianId = po.physicianId
inner join productTables pt on pt.productId = po.itemId
WHERE po.practiceId = @practiceId
and po.isactive = 1
group by  p.legalname, phy.initials
order by pracCount desc






END


GO
