USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_GetStateReportForGraph_new]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_AdminModule_GetStateReportForGraph '2017-01-01','2017-05-18'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_GetStateReportForGraph_new]
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
select count(distinct po.orderid) as  orders, isnull(patInfo.[state], 'Other State') as [state]
,sum(po.productQuntity * po.productPrice) as revenue  
from patientOrders po
INNER JOIN orders o on o.OrderId=po.OrderId
inner join patientInfoes patInfo on patinfo.patientId = po.patientId
where convert(date,o.createdDate)  >=  @fDate  
AND convert(date,o.createdDate) <= @toDate 
AND po.IsActive=1 AND o.IsActive=1
group by patinfo.[State]


--select sum(revenue) as revenue, 
----FORMAT(sum(revenue), 'c') as revenue, 
--state from #rev
--where len(state)!= 2 
----and state not in ('Alabama','Arizona') 
--group by state
--order by state
END
-- CPN_AdminModule_GetStateReportForGraph '2017-01-01','2017-05-18'


GO
