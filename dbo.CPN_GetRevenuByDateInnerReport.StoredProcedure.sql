USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetRevenuByDateInnerReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================







-- Author:		<Author,,Name>







-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec CPN_GetRevenuByDateInnerReport 'July'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetRevenuByDateInnerReport]

	@monthName varchar(20),
	@practiceId uniqueidentifier,
	@physicianId uniqueidentifier,

	@fromDate nvarchar(20) = null,

	@toDate nvarchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	declare @monthId int

	set @monthId  = dbo.getMonthId(@monthName)

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
	if(@practiceId <> '00000000-0000-0000-0000-000000000000' and @physicianId <> '00000000-0000-0000-0000-000000000000')
	begin
  select convert(date, createdDate) as [Date], count(patientId) as Orders,
  round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
  from patientOrders where datepart(mm,createdDate) = @monthId 
  and convert(date,createdDate)  > = @fDate and convert(date,createdDate) <= @tDate 
  and practiceId = @practiceId and physicianId = @physicianId
  group by convert(date,createdDate)
  end
  else if(@practiceId <> '00000000-0000-0000-0000-000000000000')
  begin
   select convert(date, createdDate) as [Date], count(patientId) as Orders,
  round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
  from patientOrders where datepart(mm,createdDate) = @monthId 
  and convert(date,createdDate)  > = @fDate and convert(date,createdDate) <= @tDate  and practiceId = @practiceId
  group by convert(date,createdDate)
  end
  else
  begin
   select convert(date, createdDate) as [Date], count(patientId) as Orders,
  round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
  from patientOrders where datepart(mm,createdDate) = @monthId 
  and convert(date,createdDate)  > = @fDate and convert(date,createdDate) <= @tDate 
  group by convert(date,createdDate)
  end

END


GO
