USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetInventoryReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetInventoryReport]
	
	@fromDate nvarchar(20), 
	@toDate nvarchar(20)

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

    select productId, item as [ItemName], productDescription as [Description], CategoryName, physicianCOGS as [Price], instock
	from productTables
	where convert(date, createdDate) >= @fDate and convert(date,createdDate) <= @tDate
	
END


GO
