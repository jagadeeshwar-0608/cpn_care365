USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetAllFacilityListWithPracticeInfo]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratik Godha
-- Create date: 01/11/2016
-- Description:	Facility BY Practice
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetAllFacilityListWithPracticeInfo] 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


select pract.LegalName as PracticeName, *    from FacilityByPractice fac
inner join Practices pract on pract.PracticeId= fac.PracticeId
where fac.isactive=1

END


GO
