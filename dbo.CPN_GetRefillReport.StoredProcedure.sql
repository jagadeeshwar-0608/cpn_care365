USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetRefillReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get Sales Reports Product information>

-- CPN_GetRefillReport '2016-11-08','2016-11-08'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetRefillReport]

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

	select distinct po.OrderId as OrderId,  convert(date,po.createdDate) as [OrderDate],prac.legalname as PracticeName, phy.initials as physicianName,
	psi.facilityName,
	concat(pat.nameFirst,' ',pat.nameLast) as PatientName,

	dateadd(dd,30,convert(date,po.createdDate)) as nextRefill, datediff(dd,convert(date,getdate()),dateadd(dd,30,convert(date,po.createdDate))) as duedays

	from patientOrders po

	inner join practices prac on prac.practiceId  = po.PracticeId

	inner join physicians phy on phy.physicianId = po.physicianId
	inner join patientInfoes pat on pat.PatientId = po.patientId
	left join patientShippingInformation psi on psi.patientId = po.patientId
	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate

	

END


GO
