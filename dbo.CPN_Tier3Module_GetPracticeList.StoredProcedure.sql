USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_Tier3Module_GetPracticeList]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_SalesModule_GetPracticeList_BySalesId '9894CDB1-54E5-4128-AC7A-12851FFAB4CA'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_Tier3Module_GetPracticeList] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT distinct(prac.practiceId),
prac.practiceId,
prac.UserId,
prac.LegalName,
prac.Address1,
prac.Address2,
prac.City,
prac.State,
prac.Zip,
prac.Phone,
prac.Email,
prac.Fax,
prac.URL,
prac.NPI,
prac.EIN,
prac.PTAN,
prac.CreatedDate,
prac.IsActive,
prac.TierType,
prac.CompanyName,
prac.SalesRep,
prac.FicitiousNameDBA,
prac.Suite,
prac.[SageCustomerId]
FROM Practices  prac
INNER  join recordRelations rr on rr.practiceId = prac.practiceId
INNER join salesrepinfoes sale on sale.salesrepinfoId = rr.salesrepid
where rr.IsActive=1 AND prac.IsActive=1


END


GO
