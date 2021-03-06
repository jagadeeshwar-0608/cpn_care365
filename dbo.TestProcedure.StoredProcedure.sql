USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[TestProcedure]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- TestProcedure 'M', '2016-10-01','2016-11-22'
-- =============================================
CREATE PROCEDURE [dbo].[TestProcedure]
	-- Add the parameters for the stored procedure here
	@reportBy char(1),
	@fromDate nvarchar(20) = null,
	@toDate  nvarchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @filterQuery nvarchar(max)  = 'Convert(nvarchar(20),Substring(DATENAME(month,o.createdDate),1,3))+ convert(nvarchar(4),Datepart(YYYY,o.createdDate))'

	declare @groupBy nvarchar(max) = 'Convert(nvarchar(20),Substring(DATENAME(month,o.createdDate),1,3))+ convert(nvarchar(4),Datepart(YYYY,o.createdDate))'
	
	declare @dynamicQuery nvarchar(max) = 
	
	'select '+@filterQuery+'  from orders  o
	where convert(date,createdDate)  >= convert(date,'''+@fromDate+''') and convert(date,createdDate) <= convert(date,'''+@toDate+''')
	group by '+@groupBy+' '

	exec (@dynamicQuery)

END


GO
