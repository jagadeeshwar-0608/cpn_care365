USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetHelOrderList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <10-09-2016>
-- Description:	<Get sales order basic and detailed reports>
-- CPN_GetHelOrderList '2017-02-01','2017-02-25'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetHelOrderList]

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



	select hel.HeldOrderId, hel.PatientFirstName +' '+ hel.PatientLastName PatientName,
	prac.LegalName as PracticeName ,
	phy.Initials PhysicainName,convert(date,hel.CreatedDate) OrderDate,
	hel.OrderStatus AS OrderStatus,
	hel.CreatedBy  FROM HeldOrder hel
	INNER JOIN Practices prac on prac.PracticeId=hel.PracticeId
	--INNER JOIN RecordRelations rel on rel.PracticeId=prac.PracticeId
	INNER JOIN Physicians phy on phy.PhysicianId=hel.PhysicianId
	WHERE convert(date,hel.createdDate)  > = @fDate and convert(date,hel.createdDate) <= @tDate
	 and hel.isactive=1
    
END


GO
