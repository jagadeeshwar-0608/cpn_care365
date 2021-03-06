USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_AdminModule_GetAllSalesRepCommission]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		< Pratik Godha >
-- Create date: <20/02/2017>
-- Description:	<Description,,>
-- CPNDevice_AdminModule_GetAllSalesRepCommission 'null','null'
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_AdminModule_GetAllSalesRepCommission]

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

		SELECT sales.Initial as SalesRepName, SUM(modet.[PrimaryProductQuantity] * pt.commissionMosupply)/30 AS commission
		--CONVERT(DATE,mo.createdDate) orderDate
		FROM [dbo].[MobileOrder] mo
				INNER JOIN [dbo].[MobileOrderDetail] modet on modet.MobileOrderId = mo.MobileOrderId
				INNER JOIN productTables pt on pt.[ProductId] = modet.PrimaryProductId
				INNER JOIN [dbo].[Practices] prac on prac.PracticeId = mo.[PracticeId]
				INNER JOIN [dbo].[RecordRelations] rr on rr.[PracticeId] = prac.PracticeId
				INNER JOIN [dbo].[salesRepInfoes] sales on sales.[salesRepInfoId] = rr.[SalesRepId]
		WHERE CONVERT(DATE,mo.createdDate) >= @fDate and CONVERT(DATE,mo.createdDate) <= @tDate
		AND mo.IsActive=1 AND
		pt.isactive=1 AND rr.isactive=1
		GROUP BY sales.Initial --, CONVERT(DATE,mo.createdDate)

END

GO
