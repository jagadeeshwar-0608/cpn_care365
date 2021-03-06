USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_getOrderHistoryByOrderId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



-- exec [dbo].[CPN_getOrderHistoryByOrderId] '79848021-9b54-4044-b8fa-54b9e103fff1'







CREATE PROCEDURE [dbo].[CPN_getOrderHistoryByOrderId] 



@orderId uniqueidentifier 



AS



BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;





select distinct patorder.orderid as orderid,patorder.PatientOrderId as patientOrderId, practice.PracticeId as practiceID,



prod.productId as productId, 



 pat.nameFirst as patientFirstName,  pat.nameLast as patientLastName ,



practice.LegalName as practiceName , phy.Initials as Physician ,

-- payor.PayorName as PayorName , 



salesrep.Initial as salesRep,
ord.orderNumber AS orderNumber,



--PPTier.TierType as TierType, 

prod.item as productCode, prod.productdescription as productDescription, prod.HCPCS as HCPCS, 



 patorder.productquntity as productQTY , prod.PhysicianCOGS as PhysicianCOGS,



  patorder.productprice as productcost , prod.MedicareFreeSchedule,



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



  where patorder.IsActive =1 and ord.orderid= @orderId

  

  group by 



  patorder.orderid ,patorder.PatientOrderId , practice.PracticeId ,



  prod.productId ,pat.nameFirst , pat.nameLast  ,



	practice.LegalName , phy.Initials  , 

	--payor.PayorName , 



	salesrep.Initial ,



	--PPTier.TierType ,

	 prod.item , prod.productdescription , prod.HCPCS , ord.orderNumber1,



	 patorder.productquntity , prod.PhysicianCOGS ,prod.MedicareFreeSchedule,



   patorder.productprice , patorder.CreatedDate  ,

    ord.orderstatus  ,  ord.paymentstatus ,

   ord.trackingnumber ,ord.shipstatus 
,ord.orderNumber




order by patorder.CreatedDate







/*

	select distinct ord.orderid as orderid,patorder.PatientOrderId as patientOrderId, practice.PracticeId as practiceID,

phy.physicianId , 

--payor.PayorId,



prod.ProductId,

 pat.nameFirst as patientFirstName , 

  pat.nameLast as patientLastName ,

   concat(pat.address1,' ',pat.address2) as patientAddress,

 pat.city as patientCity, 

 pat.[state] as patientState, 

 pat.zip as patientZip,

 pat.mainemail as patientEmail,

  pat.mainPhone as patientPhone,

 

 patship.FacilityName as ShipFacilityName,

 patship.FirstName as shipFirstName,

 patship.LastName as shipLastName,

 patship.[Address] as shipAddress,

 patship.City as shipCity,

 patship.[State] as shipState,

 patship.Zip as shipZip,

 patship.Phone as shipPhone,

 patship.shipRoom as shipRoom,

 patship.shipBed as shipBed,

 patship.shipSuit as shipSuit,



practice.LegalName as practiceName , 



phy.Initials as Physician ,

phy.Address1 as phyaddress1,

phy.Address2 as phyaddress2,

phy.City as phycity,

phy.[State] as phystate,

phy.Zip as phyzip,

phy.Phone as phyphone,

phy.Fax as phyfax,

phy.NPI as phynip,



--payor.PayorName as PayorName , 

salesrep.Initial as salesRep, 

round(convert(float,ord.PrimaryPaidAmount),2) as PrimaryPaidAmount ,

--convert(date,ord.PrimaryPaidDate) as PrimaryPaidDate,

round(convert(float,ord.secondaryPaidAmount),2) as secondPaidAmount,

--convert(date, ord.SecondaryPaidDate) as SecondaryPaidDate,

ord.[SecondaryPayorName] as SecondaryPayorName,

--PPTier.TierType as TierType, 

prod.item as productCode, 

prod.productdescription as productDescription,

 prod.HCPCS as HCPCS, 

prod.MedicareFreeSchedule MedicareFreeSchedule,

patorder.productquntity as productQTY ,

 prod.PhysicianCOGS as PhysicianCOGS,

patorder.productprice as productcost ,

 sum(patorder.productprice) as totalAmount,

ord.orderstatus as orderstatus ,

 ord.paymentstatus as paymentstatus ,

  ord.trackingnumber as trackingnumber ,

ord.shipstatus as shipstatus,

ord.[PlaceOfService] as PlaceOfService ,  -- added by pratik g on 27092016 

ord.[orderwound] as orderwound  -- added by pratik g on 27092016 



--ord.shippingDate as [shippingDate] ,

--ord.DeliveryDate as   [DeliveryDate] 



-- ,notes.OrderNotesId as OrderNotesId,

--notes.NoteDetails as orderNotes ,

--convert(date,notes.CreatedDate) as orderNotesDate 

--orddoc.OrderDocId as OrderDocId  , orddoc.[FileName] as docfilename , orddoc.[FilePath] as docfilepath , orddoc.FileExtention as fileExtention,

--convert(date,orddoc.CreatedDate) as docCreated 







,payorder.PrimaryPayorId as PrimaryPayorId

, payorder.PrimaryPlanId as [PrimaryPlanId]

, payorder.[PrimaryPayorName] as [PrimaryPayorName]

, payorder.[SecondaryFirstPayorId] as [SecondaryFirstPayorId]

, payorder.[SecondaryFirstPayorName] as [SecondaryFirstPayorName]

, payorder.[SecondaryFirstPlanId] as [SecondaryFirstPlanId]

, payorder.[SecondarSecondPayorId] as [SecondarSecondPayorId]

, payorder.[SecondarSecondPayorName] as [SecondarSecondPayorName]

, payorder.[SecondarSecondPlanId] as [SecondarSecondPlanId]





  from PatientInfoes pat   

  INNER JOIN PatientOrders patorder on pat.PatientId=patorder.PatientId

  INNER JOIN [dbo].[Practices] practice on  practice.practiceId=patorder.practiceid

  INNER JOIN Physicians phy on phy.physicianId=patorder.physicianId

  --INNER JOIN payors payor on payor.payorid=patorder.payorid

  INNER JOIN ProductTables prod on prod.productId=patorder.itemid

  INNER JOIN orders ord on ord.orderid=patorder.orderid 

  --INNER JOIN [dbo].[ProductPriceTiers] PPTier on PPTier.TierId=prod.TierType

  INNER JOIN RecordRelations RR on RR.practiceid= practice.practiceid

  INNER JOIN salesRepInfoes salesrep on salesrep.[salesRepInfoId]=RR.[SalesRepId]

  INNER JOIN PatientShippingInformation patship on pat.PatientId=patship.PatientId

  --INNER JOIN [dbo].[OrderNotes] notes on notes.OrderId= ord.OrderId

  --INNER JOIN [dbo].[OrderDocuments] orddoc on orddoc.orderid=ord.OrderId



  INNER JOIN [dbo].[PayorByOrders] payorder on payorder.orderid=ord.orderid



   WHERE ord.orderid = @orderId

   -- and orddoc.IsActive=1

  group by

	ord.orderid ,patorder.PatientOrderId , practice.PracticeId ,

	pat.nameFirst , pat.nameLast  ,

	practice.LegalName , phy.Initials  , 

	--payor.PayorName , 

	salesrep.Initial , 

	--PPTier.TierType , 

	prod.item , prod.productdescription , prod.HCPCS , 

	patorder.productquntity , prod.PhysicianCOGS ,prod.MedicareFreeSchedule,

	patorder.productprice 

	

	-- ,notes.OrderNotesId, notes.NoteDetails , notes.CreatedDate

	

	, pat.Address1, pat.Address2,

	pat.city, pat.state, pat.zip, pat.mainemail, pat.mainphone, 

	patship.FacilityName ,

 patship.FirstName ,

 patship.LastName ,

 patship.[Address],

 patship.City 	,

 patship.[State] ,

 patship.Zip ,

 patship.Phone, 

 patship.shipRoom,

 patship.shipBed,

 patship.shipSuit,

	phy.physicianId ,

	phy.Initials,

	phy.Address1,

	phy.Address2,

	phy.City	,

	phy.[State]	,

	phy.Zip		,

	phy.Phone	,

	phy.Fax		,

	phy.NPI		,



	-- payor.PayorId,

	

	ord.PrimaryPaidAmount, --ord.PrimaryPaidDate,

	 ord.secondaryPaidAmount,

	 -- ord.SecondaryPaidDate,

	ord.[SecondaryPayorName],	prod.ProductId , 

   patorder.productprice , 

   --patorder.CreatedDate  , 

     ord.orderstatus  ,  ord.paymentstatus ,

   ord.trackingnumber ,ord.shipstatus ,

   ord.[PlaceOfService],  -- added by pratik g on 27092016 

   ord.[orderwound]  -- added by pratik g on 27092016 



 --  , orddoc.OrderDocId  , orddoc.[FileName]  , orddoc.[FilePath] , orddoc.FileExtention ,   orddoc.CreatedDate ,

   --ord.shippingDate ,

  -- ord.DeliveryDate

  ,payorder.PrimaryPayorId 

, payorder.PrimaryPlanId 

, payorder.[PrimaryPayorName]

, payorder.[SecondaryFirstPayorId]

, payorder.[SecondaryFirstPayorName]

, payorder.[SecondaryFirstPlanId]

, payorder.[SecondarSecondPayorId]

, payorder.[SecondarSecondPayorName]

, payorder.[SecondarSecondPlanId]

*/





 -- select * from [dbo].[PayorByOrders]



 --select * from orders where orderid = 'BD115C43-B3F6-43ED-9F82-82D9F3FE7447'

END



 -- select * from PatientShippingInformation




GO
