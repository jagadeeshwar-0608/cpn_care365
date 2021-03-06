USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetUserListByRole]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		PratikG.
-- Create date: 18-11-2016
-- Description:	Get User List By Role Type
-- CPN_GetUserListByRole 'CPNSTAFF'
 -- =============================================
CREATE PROCEDURE [dbo].[CPN_GetUserListByRole]

@RoleName nvarchar(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


  SELECT U.Id as UserId , U.UserName UserName , R.Name as RoleName
  FROM [dbo].[AspNetUsers] U INNER JOIN [dbo].[AspNetUserRoles] UR on UR.UserId=U.Id
  INNER JOIN  [CPNBioscience].[dbo].[AspNetRoles] R ON R.Id=UR.RoleId
  WHERE R.Name= @RoleName

END


GO
