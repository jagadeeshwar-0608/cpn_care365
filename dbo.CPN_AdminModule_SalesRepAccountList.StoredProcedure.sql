USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_SalesRepAccountList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_SalesRepAccountList] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   

select AU.Id salesRepAccountId, SR.[Initial] salesRepAccountName  from aspnetusers AU
INNER JOIN [dbo].[AspNetUserRoles] UR ON UR.UserId=AU.Id
INNER JOIN [dbo].[AspNetRoles] AR ON AR.Id=UR.RoleId
INNER JOIN [dbo].[salesRepInfoes] SR ON SR.[salesRepInfoId]=AU.Id
WHERE AR.Name='SalesRep' 


END

GO
