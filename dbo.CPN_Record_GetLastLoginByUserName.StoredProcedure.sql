USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Record_GetLastLoginByUserName]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_Record_GetLastLoginByUserName 'cpnbioscience@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_Record_GetLastLoginByUserName]

@username nvarchar(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


WITH YourCTE AS (
SELECT TOP 2
    *
	--, ROW_NUMBER() OVER(ORDER BY [LoginDateTime]) AS RowNumber
    FROM [User] where useremail= @username order by [LoginDateTime] desc
)  

SELECT * FROM YourCTE
order by [LoginDateTime] desc
OFFSET 1 ROWS   -- Skip this number of rows
FETCH NEXT 1 ROW ONLY;  -- Return this number of rows


END

GO
