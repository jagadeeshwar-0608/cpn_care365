USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetRevenuByDate]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <07-18-2016>
-- Description:	<Get revenue by date>
-- CPN_GetRevenuByDate  @practiceId = '00000000-0000-0000-0000-000000000000', @physicianId = '00000000-0000-0000-0000-000000000000'@fromDate = '2016-08-01', @toDate = '2016-08-31'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetRevenuByDate]
	@practiceId uniqueIdentifier,
	@physicianId uniqueIdentifier,
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null

AS
BEGIN
	
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
	if(@practiceId <> '00000000-0000-0000-0000-000000000000' and @physicianId <> '00000000-0000-0000-0000-000000000000')
	begin
   select   datename(month,convert(date, createdDate)) as [Month], count(patientId) as Orders,
   round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
   from patientOrders
   where convert(date,createdDate) >= @fDate and convert(date,createdDate) <= @tDate
   and practiceId = @practiceId and physicianId = @physicianId
   group by datename(month,convert(date,createdDate))
    end
	else if(@practiceId <> '00000000-0000-0000-0000-000000000000')
	begin
	select   datename(month,convert(date, createdDate)) as [Month], count(patientId) as Orders,
   round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
   from patientOrders
   where convert(date,createdDate) >= @fDate and convert(date,createdDate) <= @tDate
   and practiceId = @practiceId 
   group by datename(month,convert(date,createdDate))
   end
   else
   begin
   select   datename(month,convert(date, createdDate)) as [Month], count(patientId) as Orders,
   round(convert(float,sum(productPrice),2),2) as [TotalRevenue], round(convert(float,sum(productprice)/ count(patientId),2),2) as [AverageRevenue]
   from patientOrders
   where convert(date,createdDate) >= @fDate and convert(date,createdDate) <= @tDate
   group by datename(month,convert(date,createdDate))
   end

END


GO
