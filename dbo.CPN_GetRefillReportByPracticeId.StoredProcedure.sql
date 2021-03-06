USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetRefillReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get Sales Reports Product information>

-- CPN_GetRefillReportByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', 'null','null'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetRefillReportByPracticeId]
	
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

	set @tDate = getdate()

	end

	else

	begin

	set @tDate = @toDate

	end

	select distinct po.orderId as OrderId,  convert(date,po.createdDate) as [OrderDate],prac.legalname as PracticeName, phy.initials as physicianName,
	concat(pat.nameFirst,' ',pat.nameLast) as PatientName,

	dateadd(dd,30,convert(date,po.createdDate)) as nextRefill, datediff(dd,convert(date,getdate()),dateadd(dd,30,convert(date,po.createdDate))) as duedays

	from patientOrders po

	inner join practices prac on prac.practiceId  = po.PracticeId

	inner join physicians phy on phy.physicianId = po.physicianId
	inner join patientInfoes pat on pat.PatientId = po.patientId

	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate
	AND po.PracticeId= @practiceId AND po.IsActive=1

END


GO
