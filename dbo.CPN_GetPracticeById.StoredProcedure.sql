USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetPracticeById]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratik Godha
-- Create date: 17/08/2016
-- Description:	<Description,,>
-- CPN_GetPracticeById 'A66C7106-F89B-4CF9-8994-DB7DFC8C1EDC'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetPracticeById] --'A66C7106-F89B-4CF9-8994-DB7DFC8C1EDC'

@practiceId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
	  practice.PracticeId practicePracticeId , 
	  practice.[LegalName] practiceLegalName
     
	  ,practice.[Address1] [practiceAddress1]
      ,practice.[Address2][practiceAddress2]
	  ,practice.[City] [practiceCity]
      ,practice.[State] [practiceState]    
	  ,practice.[Zip] [practiceZip]
      ,practice.[Phone] [practicePhone]   
	  ,practice.[Email] [practiceEmail]
      ,practice.[Fax] [practiceFax]    
	  ,practice.[URL] [practiceURL]
      ,practice.[NPI] [practiceNPI]    
	  ,practice.[EIN] [practiceEIN]
      ,practice.[PTAN] [practicePTAN]    
	     
     -- ,practice.[TierType] [practiceTierType]   
	  ,practice.[CompanyName] [practiceCompanyName]
	  ,practice.[CreatedDate] [practiceCreatedDate]   
	 -- ,practice.[SalesRep] [practiceSalesRep]
	  ,practice.FicitiousNameDBA practiceFicitiousNameDBA
	  
	    ,practiceBillCont.[firstName] practiceBillContFirstName
      ,practiceBillCont.[lastName] practiceBillContLastName
      ,practiceBillCont.[Phone] practiceBillContPhone
      ,practiceBillCont.[Email] practiceBillContEmail
      ,practiceBillCont.[Fax] practiceBillContFax
	
	 ,practiceAdminCont.[firstName] practiceAdminContFirstName
      ,practiceAdminCont.[lastName] practiceAdminContLastName
      ,practiceAdminCont.[Phone] practiceAdminContPhone
      ,practiceAdminCont.[Email] practiceAdminContEmail
      ,practiceAdminCont.[Fax] practiceAdminContFax

      ,phy.PhysicianId PhysicianId
	  ,phy.Initials physicianInitials
	  ,phy.FirstName phyfirstname
	  ,phy.LastName phylastname
		,phy.[Address1] phyAddress1
		,phy.[Address2] phyAddress1
		,phy.[City] phyCity
		,phy.[State] phyState
		,phy.[Zip] phyZip
	  ,phy.Phone phyphone
	,phy.[Email] phyEmail
	,phy.[Fax] phyFax
	  ,phy.NPI phynip  

	 
	  
	  
	  --, recRel.SalesRepid SalesRepId
FROM
[dbo].[Practices] practice
left JOIN [dbo].[PracticeAdministrativeContacts] practiceAdminCont
on practice.[PracticeId] = practiceAdminCont.[PracticeId]
left JOIN [dbo].[PracticeBillingContacts] practiceBillCont on practice.[PracticeId] = practiceBillCont.[PracticeId]
INNER JOIN [dbo].[RecordRelations] recRel on recRel.[PracticeId] =practice.[PracticeId]
LEFT JOIN [dbo].[Physicians] phy on phy.PhysicianId=recRel.PhysicianId
WHERE practice.[PracticeId]= @practiceId and recRel.IsActive=1

END


GO
