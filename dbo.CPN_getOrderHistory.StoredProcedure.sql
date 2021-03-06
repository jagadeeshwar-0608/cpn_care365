USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_getOrderHistory]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>
-- CPN_getOrderHistory 'null','null'
-- =============================================



CREATE PROCEDURE [dbo].[CPN_getOrderHistory]



@fromDate nvarchar(20) = null,

@toDate nvarchar(20) = null



AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



	declare @fDate date



	declare @tDate date



	if @fromDate = 'null'



	begin



	set @fDate = '1900-01-01'



	end



	else



	begin



	set @fDate = @fromDate



	end



	if @toDate = 'null'



	begin



	set @tDate = convert(date,getdate())



	end



	else



	begin



	set @tDate = @toDate



	end





select distinct patorder.orderid as orderid,patorder.PatientOrderId as patientOrderId, practice.PracticeId as practiceID,

prod.productId as productId, 

 pat.nameFirst as patientFirstName,  pat.nameLast as patientLastName ,

practice.LegalName as practiceName , phy.Initials as Physician ,

-- payor.PayorName as PayorName , 

salesrep.Initial as salesRep,

--PPTier.TierType as TierType, 

prod.item as productCode, prod.productdescription as productDescription, prod.HCPCS as HCPCS, 

 patorder.productquntity as productQTY , prod.PhysicianCOGS as PhysicianCOGS,

  patorder.productprice as productcost , 

  patorder.CreatedDate AS orderDate ,sum(patorder.productprice) as totalAmount ,

 ord.orderstatus as orderstatus , ord.paymentstatus as paymentstatus , ord.trackingnumber as trackingnumber ,

ord.shipstatus as shipstatus ,

ord.OrderNumber as OrderNumber,

ord.reporttoshippingapi 

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

  where patorder.IsActive =1 

  and convert(date,patorder.createdDate)  > = @fDate and convert(date,patorder.createdDate) <= @tDate

  group by 

  patorder.orderid ,patorder.PatientOrderId , practice.PracticeId ,

  prod.productId ,pat.nameFirst , pat.nameLast  ,

  practice.LegalName , phy.Initials  , 

  --payor.PayorName , 

  salesrep.Initial ,

  --PPTier.TierType ,

  prod.item , prod.productdescription , prod.HCPCS , 

  patorder.productquntity , prod.PhysicianCOGS ,

  patorder.productprice , patorder.CreatedDate  ,

  ord.orderstatus  ,  ord.paymentstatus ,

  ord.trackingnumber ,ord.shipstatus ,

  ord.OrderNumber,ord.reporttoshippingapi 

  



order by patorder.CreatedDate







END


GO
