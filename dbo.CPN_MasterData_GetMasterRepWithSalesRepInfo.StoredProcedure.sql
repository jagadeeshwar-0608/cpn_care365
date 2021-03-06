USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MasterData_GetMasterRepWithSalesRepInfo]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MasterData_GetMasterRepWithSalesRepInfo]
	


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


			--SELECT aspuser.id as UserId,aspuser.UserName as UserName , asprole.Name as RoleName 
			--FROM [dbo].[AspNetUsers]  aspuser
			--INNER JOIN [dbo].[AspNetUserRoles] aspnetrole ON aspnetrole.UserId=aspuser.Id
			--INNER JOIN [dbo].[AspNetRoles] asprole ON aspnetrole.RoleId=asprole.Id
			--WHERE asprole.Name='MasterSalesRep'

select u.username as MasterUserName ,rep.[Initial] as SalesRep ,mur.masterid as  MasterUserRelId  from [dbo].[AspNetUsers] u
INNER JOIN [dbo].[AspNetUserRoles] aur on u.id=aur.userid
INNER JOIN [dbo].[AspNetRoles] r on r.id=aur.roleid
INNER JOIN [dbo].[MasterUserRelation] mur on mur.UserId=u.id
INNER JOIN [dbo].[salesRepInfoes] rep on rep.[salesRepInfoId]=mur.[SalesRepId]
where r.Name='MasterSalesRep'
order by u.username

END

GO
