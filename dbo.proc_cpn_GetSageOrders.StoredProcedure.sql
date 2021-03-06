USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_cpn_GetSageOrders]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_cpn_GetSageOrders] 
	-- Add the parameters for the stored procedure here
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


    -- Insert statements for procedure here
	
select distinct orderId, invoiceNumber,convert(date,orderDate) as orderDate, practiceName, 
shipName as patientName, sum(itemQty * salesPrice) as InvoiceAmount, Physician
 from sageAccountingOrder
 where convert(date,orderDate) > = @fDate and convert(date,orderDate) <= @tDate
 group by orderId, invoiceNumber, orderDate, practiceName, shipname, physician
	
END


GO
