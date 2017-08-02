USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_GetUserListForMultiAccount]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_GetUserListForMultiAccount] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   

select AU.UserName , AU.Id UserId from [dbo].[AspNetUsers] AU
INNER JOIN [dbo].[SingleUserMultiAccount] SAM on AU.Id!=SAM.UserId
WHERE SAM.IsActive=1



END

GO
