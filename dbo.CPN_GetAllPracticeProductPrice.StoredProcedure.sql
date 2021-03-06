USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetAllPracticeProductPrice]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Shashiram Reddy>
-- Create date: <12-14-2017>
-- Description:	<gets every practice, every product and every price from care 365>
-- CPN_GetAllPracticeProductPrice
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetAllPracticeProductPrice] 
AS
BEGIN
	SET NOCOUNT ON;
select prac.legalname, prac.practiceId, ppi.effectivePrice ,ppi.item
into #pracData
from practices prac 
inner join practiceProductInfo ppi on ppi.practiceId = prac.practiceId
DECLARE @cols AS NVARCHAR(MAX), @query nvarchar(max)


 select @cols = STUFF((SELECT  ',' + QUOTENAME(item)
  FROM 
  (SELECT DISTINCT item
                          FROM #pracData
                          )sub
  FOR XML PATH(''), TYPE
  ).value('.', 'NVARCHAR(MAX)') 
  ,1,1,'')


set @query = N'select * into #temp
from 
(
  select legalname, practiceId, effectivePrice, item
  from #pracData
) src
pivot
(
  sum(effectivePrice)
  for item in ('+@cols+') 
) piv; 
select * from #temp '
execute(@query);
end

GO
