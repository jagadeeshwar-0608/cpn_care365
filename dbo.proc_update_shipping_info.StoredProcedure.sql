USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_shipping_info]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE proCEDURE [dbo].[proc_update_shipping_info]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @v_udf_imported char(1)
declare @v_sales_order_no int
declare @v_active_ind bit

DECLARE db_cursor CURSOR FOR  

select distinct salesOrderNo,udf_imported from [192.69.72.62].[MAS_CPN].[dbo].[SO_SalesOrderHistoryHeader] rem
inner join SageAccountingOrder sage
on sage.InvoiceNumber = rem.salesOrderNo
where sage.IsActive = 1


OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @v_sales_order_no, @v_udf_imported

WHILE @@FETCH_STATUS = 0   
BEGIN   

		if(@v_udf_imported = 'Y')
		begin
			set @v_active_ind = 0

			update SageAccountingOrder set IsActive = @v_active_ind where InvoiceNumber = @v_sales_order_no
		end

		

	   FETCH NEXT FROM db_cursor INTO @v_sales_order_no, @v_udf_imported
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
END

GO
