USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPhysicianDataByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-15-2016>

-- Description:	<Get physician data based on the practiceId for practice physician tab data>

-- CPN_GetPhysicianDataByPracticeId   'A66C7106-F89B-4CF9-8994-DB7DFC8C1EDC'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetPhysicianDataByPracticeId] 

	-- Add the parameters for the stored procedure here

	@practiceId uniqueidentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



   select distinct pr.practiceId, phy.physicianid, phy.initials as physicianName,

   phy.[FirstName] as FirstName

   , phy.[LastName] as LastName

   , phy.npi,phy.createdDate,
    phy.modifiedby, phy.modifiedDate

from practices pr

inner join recordRelations rr on rr.practiceId = pr.practiceId

inner join physicians phy on phy.physicianId = rr.PhysicianId

where pr.practiceid = @practiceId and rr.IsActive=1

	

END



GO
