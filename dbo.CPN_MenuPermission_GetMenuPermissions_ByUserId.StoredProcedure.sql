USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MenuPermission_GetMenuPermissions_ByUserId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_MenuPermission_GetMenuPermissions_ByUserId '0f60a1b9-c9be-4254-ac77-ac6534101a50'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MenuPermission_GetMenuPermissions_ByUserId]
	
	@userId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
		--select case when up.IsActive is NULL then 'False' when up.IsActive = 1 then 'True' else up.IsActive
		--end as Permission ,m.[MenuName] as MenuName , m.SiteMenuId  from [dbo].[SiteMenu] m
		--Left JOIN  UserMenuPermission up on up.SiteMenuId=m.SiteMenuId 
		--where up.UserId= @userId order by m.[MenuName]

select IsActive, SiteMenuId into #UserMenuPermission from UserMenuPermission up 
where up.UserId= @userId

select case when up.IsActive is NULL then 'False' when up.IsActive = 1 then 'True' else up.IsActive end as Permission
,m.[MenuName] as MenuName , m.MenuCategory as MenuCategory , m.SiteMenuId as SiteMenuId  from [dbo].[SiteMenu] m
  left JOIN  #UserMenuPermission up 
  on up.SiteMenuId=m.SiteMenuId order by m.[MenuName] 


END

GO
