USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_PracticeModule_GetDashboardRecentOrdersData_ByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <21-10-2016>

-- Description:	<Get dashboard recent orders data>
-- CPN_PracticeModule_GetDashboardRecentOrdersData_ByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_PracticeModule_GetDashboardRecentOrdersData_ByPracticeId] 



@practiceId uniqueidentifier

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    -- Insert statements for procedure here

select distinct top 5 po.orderid,  o.createdDate,isnull(o.orderNumber,0) as ordernumber ,

concat(pat.namefirst,' ',pat.nameLast) as patientName,

prod.productDescription as brandname, isnull(o.shipstatus,'Processing') shipstatus,

phy.Initials PhysicianName

from patientOrders po

inner join practices p on p.practiceId = po.practiceId

inner join orders o on o.orderId = po.orderId

inner join patientInfoes pat on pat.patientid = po.patientId

inner join producttables prod on prod.productId = po.itemId

INNER JOIN Physicians phy on po.PhysicianId=phy.PhysicianId

WHERE po.PracticeId= @practiceId AND prod.CategoryName='Primary'
AND po.IsActive =1 AND o.IsActive=1

order by o.createdDate desc



END


-- CPN_PracticeModule_GetDashboardRecentOrdersData_ByPracticeId '1E165131-54CF-403F-B8E8-28D353A60178'


GO
