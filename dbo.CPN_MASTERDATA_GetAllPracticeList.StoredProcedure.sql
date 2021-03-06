USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_MASTERDATA_GetAllPracticeList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_MASTERDATA_GetAllPracticeList]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT distinct prac.practiceid , prac.[PracticeId]
      ,prac.[UserId]
      ,prac.[LegalName]
      ,prac.[Address1]
      ,prac.[Address2]
      ,prac.[City]
      ,prac.[State]
      ,prac.[Zip]
      ,prac.[Phone]
      ,prac.[Email]
      ,prac.[Fax]
      ,prac.[URL]
      ,prac.[NPI]
      ,prac.[EIN]
      ,prac.[PTAN]
      ,prac.[CreatedDate]
      ,prac.[IsActive]
      ,prac.[TierType]
      ,prac.[CompanyName]
      ,prac.[SalesRep]
      ,prac.[FicitiousNameDBA]
      ,prac.[Suite]
      ,prac.[SageCustomerId]
	  FROM PRACTICES  prac
	INNER JOIN [dbo].[RecordRelations] rel on rel.PracticeId=prac.PracticeId
	WHERE rel.IsActive=1 AND prac.IsActive=1

END

GO
