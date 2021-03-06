USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_tracking_info]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create proCEDURE [dbo].[proc_update_tracking_info]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @v_tracking_id varchar(100)
declare @v_sales_order_no int
declare @v_freight_amt float

DECLARE db_cursor CURSOR FOR  

select distinct rem.InvoiceNo,rem.TrackingID,rem.FreightAmt from [192.69.72.62].[MAS_CPN].[dbo].[SO_InvoiceTracking] rem
inner join orders o
on o.orderNumber = rem.InvoiceNo
where o.trackingNumber is null and rem.trackingId is not null


OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @v_sales_order_no, @v_tracking_id, @v_freight_amt

WHILE @@FETCH_STATUS = 0   
BEGIN   

		if(@v_tracking_id is not null)
		begin
			update orders set trackingNumber = @v_tracking_id, freightAmt= @v_freight_amt
			where ordernumber = @v_sales_order_no
		end
		

	   FETCH NEXT FROM db_cursor INTO @v_sales_order_no, @v_tracking_id, @v_freight_amt
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
END

GO
