USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_SalesModule_HeldOrderModule_GetHeldOrders_BySalesRepId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_SalesModule_HeldOrderModule_GetHeldOrders_BySalesRepId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D','null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_SalesModule_HeldOrderModule_GetHeldOrders_BySalesRepId] 

	@salesRepId uniqueidentifier,

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
    -- Insert statements for procedure here
	IF(@salesRepId!=null)
	BEGIN

	select distinct hel.HeldOrderId , hel.PatientFirstName +' '+ hel.PatientLastName PatientName,
	prac.LegalName as PracticeName ,
	phy.Initials PhysicainName,convert(date,hel.CreatedDate) OrderDate,
	hel.OrderStatus AS OrderStatus FROM HeldOrder hel
	INNER JOIN Practices prac on prac.PracticeId=hel.PracticeId
	--INNER JOIN RecordRelations rel on rel.PracticeId=prac.PracticeId
	INNER JOIN Physicians phy on phy.PhysicianId=hel.PhysicianId
	INNER JOIN [dbo].[RecordRelations] rr on rr.[PracticeId] = prac.PracticeId
	INNER JOIN [dbo].[salesRepInfoes] salesrep ON salesrep.[salesRepInfoId] = rr.[SalesRepId]
	WHERE convert(date,hel.createdDate)  > = @fDate AND convert(date,hel.createdDate) <=@tDate
	and hel.isactive=1 and rr.[SalesRepId]= @salesRepId and rr.IsActive=1

			--select prac.LegalName as PracticeName, * FROM [dbo].[HeldOrder] held
			--INNER JOIN Practices prac ON prac.PracticeId=held.PracticeId
			--WHERE held.IsActive=1 
			----AND held.IsHeldOrder=1 
			--AND held.practiceId=@practiceId
			--AND convert(date,held.createddate) >= @fDate AND convert(date,held.createdDate) <=@tDate
			--ORDER BY HeldOrderId DESC
	END

	ELSE
	BEGIN

	select distinct hel.HeldOrderId , hel.PatientFirstName +' '+ hel.PatientLastName PatientName,
	prac.LegalName as PracticeName ,
	phy.Initials PhysicainName,convert(date,hel.CreatedDate) OrderDate,
	hel.OrderStatus AS OrderStatus FROM HeldOrder hel
	INNER JOIN Practices prac on prac.PracticeId=hel.PracticeId
	--INNER JOIN RecordRelations rel on rel.PracticeId=prac.PracticeId
	INNER JOIN Physicians phy on phy.PhysicianId=hel.PhysicianId
	INNER JOIN [dbo].[RecordRelations] rr on rr.[PracticeId] = prac.PracticeId
	INNER JOIN [dbo].[salesRepInfoes] salesrep ON salesrep.[salesRepInfoId] = rr.[SalesRepId]
	WHERE convert(date,hel.createdDate)  > = @fDate AND convert(date,hel.createdDate) <=@tDate
	and hel.isactive=1 and rr.[SalesRepId]= @salesRepId and rr.IsActive=1

					--SELECT prac.LegalName as PracticeName, * FROM [dbo].[HeldOrder] held
					--INNER JOIN Practices prac ON prac.PracticeId=held.PracticeId
					--WHERE held.IsActive=1 
					----AND held.IsHeldOrder=1
					--AND convert(date,held.createddate) >= @fDate AND convert(date,held.createdDate) <=@tDate
					--ORDER BY HeldOrderId DESC

	END
END


GO
