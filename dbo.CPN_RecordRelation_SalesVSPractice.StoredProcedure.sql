USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_RecordRelation_SalesVSPractice]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPN_RecordRelation_SalesVSPractice]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

select prac.LegalName as practiceName ,sales.[Initial] as SalesName,rr.[RelationId] as RelationId,
rr.practiceId as practiceId from practices  prac
INNER JOIN [dbo].[RecordRelations] rr on rr.practiceid=prac.practiceid
INNER JOIN  [dbo].[salesRepInfoes] sales on  sales.[salesRepInfoId] =rr.[SalesRepId]
where rr.IsActive=1 



END

GO
