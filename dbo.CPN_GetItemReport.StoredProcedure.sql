USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetItemReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <17-09-2016>
-- Description:	<Cpn bio sciences item report>
-- CPN_GetItemReport 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetItemReport]
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

	select productId, item, productDescription, BrandName,
	  isnull(manufacturer,'') as manufacturer, categoryName,
	  HCPCS, medicareFreeSchedule, SuggestedRetail,
	  physicianCOGS, 
	  cpnCOGS
	from productTables pt
	where convert(date,createdDate) >= @fDate and convert(date,createdDate) <= @tDate
END


GO
