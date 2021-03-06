USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPracticeCommonData]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <17-10-2016>

-- Description:	<Get common data for practice >

-- CPN_GetPracticeCommonData 'b6e76840-6424-4a84-82d1-f1d3f35fed0d'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetPracticeCommonData]

	-- Add the parameters for the stored procedure here

	@practiceId uniqueidentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    -- Insert statements for procedure here

	



select distinct  pr.practiceid
,rel.[SalesRepId] as SalesRepId 

, pr.LegalName as practiceName,pr.address1, pr.address2, pr.city, pr.state,pr.zip,pr.email,
pr.fax,pr.Phone,pr.NPI, pr.EIN, pr.PTAN, pr.URL as URL,pr.Suite as Suite,

pbc.firstname as billingFirstName, pbc.lastname as BillingLastName, pbc.phone as billingPhone, pbc.email as billingEmail,
pbc.fax as BillingFax , pac.firstName as AdminFirstName,pac.lastName as AdminLastName,
pac.Phone as AdminPhone, pac.Email as AdminEmail, pac.Fax as AdminFax,
pr.SageCustomerId as SageCustomerId
from practices pr 
left join practiceBillingContacts pbc on pbc.practiceId = pr.practiceId
left join practiceAdministrativeContacts pac on pac.practiceId = pbc.PracticeId
inner join [dbo].[RecordRelations] rel on rel.practiceid=pr.practiceid

where pr.practiceId = @practiceId AND rel.IsActive=1
END


-- CPN_GetPracticeCommonData 'b6e76840-6424-4a84-82d1-f1d3f35fed0d'


GO
