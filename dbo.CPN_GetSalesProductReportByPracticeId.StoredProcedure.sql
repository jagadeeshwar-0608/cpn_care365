USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSalesProductReportByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-09-2016>

-- Description:	<Get Sales Reports Product information>

-- CPN_GetSalesProductReportByPracticeId 'B6E76840-6424-4A84-82D1-F1D3F35FED0D', 'null','null'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetSalesProductReportByPracticeId]

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

	select distinct pt.productId, pt.item,pt.hcpcs, pt.productDescription, count(distinct po.orderId) as NoOfOrders,

	sum(productQuntity) as unitsSold, 

	sum( po.productQuntity * po.productPrice) as invoiceAmount

	 from productTables pt

	inner join patientOrders po on po.itemId = pt.productId

	where convert(date,po.createdDate)  > = @fDate and convert(date,po.createdDate) <= @tDate

	AND po.PracticeId = @practiceId AND po.IsActive=1 AND pt.IsActive=1

	group by pt.item, pt.productDescription, pt.physicianCogs, pt.productId, pt.hcpcs

END



GO
