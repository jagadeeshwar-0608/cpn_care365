USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetUserRoles]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetUserRoles]

	@userId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT AspNetUsers.UserName, AspNetRoles.Name 
                FROM AspNetUsers 
                LEFT JOIN AspNetUserRoles ON  AspNetUserRoles.UserId = AspNetUsers.Id 
                LEFT JOIN AspNetRoles ON AspNetRoles.Id = AspNetUserRoles.RoleId
				WHERE AspNetUsers.Id = @userId
END


GO
