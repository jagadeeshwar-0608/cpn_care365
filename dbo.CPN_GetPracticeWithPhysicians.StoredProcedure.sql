USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPracticeWithPhysicians]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetPracticeWithPhysicians]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select pract.practiceid practiceid,pract.legalname practicename, 
	phy.PhysicianId physicianId,
	phy.initials physicianname from Practices pract inner join [dbo].[RecordRelations] rel
	on pract.practiceid=rel.practiceid
	inner join physicians phy on phy.physicianid=rel.physicianid
	where pract.isactive=1 and phy.isactive=1
	order by practicename asc
END


GO
