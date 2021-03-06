USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPatientManagementReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================

-- Author:		<Pratik Godha>

-- Create date: <02-11-2016>

-- Description:	<Patient Management ReportBy PracticeId>

-- CPN_GetPatientManagementReportByPracticeId 'be16084e-b8bc-4f50-a493-613deddf9b55','null','null'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetPatientManagementReportByPracticeId]

	@practiceId uniqueidentifier,
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

SELECT DISTINCT
o.orderId,
o.[CreatedDate], o.orderNumber,o.[CPNRefNo],
  case when o.orderbillDate is not null then 'Billed' else  'Unbilled' end as BilledStatus,
  case when o.OrderPaidDate is not null then 'Collected' else  'Due' end as CollectionStatus,

o.shipstatus,
concat(pat.namefirst,' ', pat.namelast) as patientName,
o.CPNRefNo as CPNRefNo

FROM
[dbo].[Orders] o,

[dbo].[PatientOrders] po,

[dbo].[PatientInfoes] pat
WHERE
po.[PatientId]=pat.PatientId and po.[orderId]=o.[orderId] 
AND convert(date,po.createdDate)  > = @fDate
AND convert(date,po.createdDate) <= @tDate
AND po.IsActive=1 AND po.practiceId= @practiceId 

END

-- CPN_GetPatientManagementReportByPracticeId 'E202E9EC-9644-4877-86C3-9466E798D941','null','null'

GO
