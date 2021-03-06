USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetDashboardRecentOrdersData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <21-10-2016>

-- Description:	<Get dashboard recent orders data>

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetDashboardRecentOrdersData] 

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    -- Insert statements for procedure here

	select distinct top 5  o.createdDate,isnull(o.orderNumber,0) as ordernumber ,

 concat(pat.namefirst,'',pat.nameLast) as patientName,prod.brandname, isnull(o.shipstatus,'') shipstatus

from patientOrders po

inner join practices p on p.practiceId = po.practiceId

inner join orders o on o.orderId = po.orderId

inner join patientInfoes pat on pat.patientid = po.patientId

inner join producttables prod on prod.productId = po.itemId

order by o.createdDate desc

END



GO
