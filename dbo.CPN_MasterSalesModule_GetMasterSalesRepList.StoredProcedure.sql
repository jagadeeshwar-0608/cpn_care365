USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterSalesModule_GetMasterSalesRepList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[CPN_MasterSalesModule_GetMasterSalesRepList]
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterSalesModule_GetMasterSalesRepList]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select u.Id as id,u.EMail as MasterRepEmail ,u.UserName as MasterRepUserName from [dbo].[AspNetUsers] u
	INNER JOIN [dbo].[AspNetUserRoles] ur on ur.UserId = u.Id
	INNER JOIN [dbo].[AspNetRoles] r on ur.RoleId = r.Id
	where r.Name ='MasterSalesRep'


END

GO
