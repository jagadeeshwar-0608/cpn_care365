USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_getOrderHistoryByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		Pratik Godha

-- Create date: 11/10/2016

-- Description:	Get Order By PracticeId
--  [dbo].[CPN_getOrderHistoryByPracticeId]  'B6E76840-6424-4A84-82D1-F1D3F35FED0D'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_getOrderHistoryByPracticeId]  


@PracticeId uniqueidentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;

select  patorder.orderid as orderid,patorder.PatientOrderId as patientOrderId,
 practice.PracticeId as practiceID,

prod.productId as productId, 

 pat.nameFirst as patientFirstName,  pat.nameLast as patientLastName ,

--practice.LegalName as practiceName ,

        practice.LegalName as practiceName,
        practice.Address1 as practiceAddress1,
        practice.Address2 as practiceAddress2,
        practice.City as practiceCity,
        practice.[State] as practiceState,
        practice.Zip as practiceZip,
        practice.Phone as practicePhone,
        practice.Email as practiceEmail,
        practice.Fax as practiceFax,
        practice.URL as practiceURL,
        practice.NPI as practiceNPI,
        practice.EIN as practiceEIN,
        practice.PTAN as practicePTAN,        
        practice.CompanyName as practiceCompanyName,
        practice.CreatedDate as practiceCreatedDate,
        practice.FicitiousNameDBA as practiceFicitiousNameDBA,

 phy.Initials as Physician ,
-- payor.PayorName as PayorName , 

salesrep.Initial as salesRep,

--PPTier.TierType as TierType, 
prod.item as productCode, prod.productdescription as productDescription, prod.HCPCS as HCPCS, 
prod.[MedicareFreeSchedule] as MedicareFreeSchedule,
 patorder.productquntity as productQTY , prod.PhysicianCOGS as PhysicianCOGS,

  patorder.productprice as productcost , 

  patorder.CreatedDate AS orderDate ,sum(patorder.productprice) as totalAmount ,

 ord.orderstatus as orderstatus , ord.paymentstatus as paymentstatus , ord.trackingnumber as trackingnumber ,
ord.shipstatus as shipstatus 

  from PatientInfoes pat   

  inner join PatientOrders patorder on pat.PatientId=patorder.PatientId

  inner join [dbo].[Practices] practice on  practice.practiceId=patorder.practiceid

  inner join Physicians phy on phy.physicianId=patorder.physicianId

 -- inner join payors payor on payor.payorid=patorder.payorid

  inner join ProductTables prod on prod.productId=patorder.itemid

  inner join orders ord on ord.orderid=patorder.orderid 

  --inner join [dbo].[ProductPriceTiers] PPTier on PPTier.TierId=prod.TierType

  inner join RecordRelations RR on RR.practiceid= practice.practiceid

  inner join salesRepInfoes salesrep on salesrep.[salesRepInfoId]=RR.[SalesRepId]

  where patorder.IsActive = 1 AND patorder.PracticeId=@PracticeId
  
  group by 

  patorder.orderid ,patorder.PatientOrderId , practice.PracticeId ,

  prod.productId ,pat.nameFirst , pat.nameLast  ,

	--practice.LegalName as practiceName ,

        practice.LegalName,
        practice.Address1 ,
        practice.Address2 ,
        practice.City   ,
        practice.[State],
        practice.Zip    ,
        practice.Phone  ,
        practice.Email  ,
        practice.Fax    ,
        practice.URL    ,
        practice.NPI    ,
        practice.EIN    ,
        practice.PTAN   ,       
        practice.CompanyName,
        practice.CreatedDate,
        practice.FicitiousNameDBA ,

	 phy.Initials  , 
	--payor.PayorName , 

	salesrep.Initial ,

	--PPTier.TierType ,
	 prod.item , prod.productdescription , prod.HCPCS , 
	 prod.MedicareFreeSchedule,
	 patorder.productquntity , prod.PhysicianCOGS ,

   patorder.productprice , patorder.CreatedDate  ,
    ord.orderstatus  ,  ord.paymentstatus ,
   ord.trackingnumber ,ord.shipstatus 


order by patorder.CreatedDate

END


GO
