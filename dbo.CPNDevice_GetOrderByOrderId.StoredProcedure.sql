USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_GetOrderByOrderId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pratik Godha>
-- Create date: <09/12/2016>
-- Description:	<OrderInfo By OrderId>
-- CPNDevice_GetOrderByOrderId '3b1910dd-af9e-49c9-a1d2-cdff7182249d' 
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_GetOrderByOrderId]

@orderId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



SELECT 
mo.[MobileOrderId] as MobileOrderId ,
mo.PatientFirstName as  PatientFirstName,
mo.PatientLastName as PatientLastName,
pract.[LegalName] as PracticeName,
pract.[CompanyName] as CompanyName,
pract.[Address1] as practiceShipAddress1,
pract.[City] as practiceShipCity,
pract.[State] as practiceShipState,
pract.[Zip] as practiceShipZip,
pract.[Phone] as practiceShipPhone,
pract.[NPI] as practiceNPI,
phy.[Initials] as  PhysicianName ,
mo.[FacilityName] as FacilityName ,
mo.[FacilityType] as FacilityType,
mob.[Wounds] as Wounds ,
mob.[NumberOfDays] as  NumberOfDays,
mo.InvoiceNumber ,
sales.[Initial] as RepName, 
orderDoc.FilePath as orderDoc,

mob.FrequencyType ,
mob.Location ,
mob.LocationText ,
mob.[Length] ,
mob.Width,
mob.Depth,
mob.WoundStage,
mob.Dranage,
mob.Debrided,
mob.ICD10Code,

--Field Add by Jitendra

prime.[CategoryName] as Primaryproduct,
gauze.[CategoryName] as Gauze,
bandage.[CategoryName] as bandage,
tap.[CategoryName] as tap,

prime.[HCPCS] as PrimaryproductHCPCS,
gauze.[HCPCS] as gauzeHCPCS,
bandage.[HCPCS] as bandageHCPCS,
tap.[HCPCS] as tapHCPCS,

--Field end
ISNULL(prime.[ProductDescription],'') as PrimaryProductDescription,
mob.PrimaryProductQuantity as PrimaryProductQuantity,
--mob.[GauzeProductId] ,

ISNULL(gauze.[ProductDescription],'') as GauzeProductDescription,
[GauzeProductQuantity] as GauzeProductQuantity,
--mob.[BandageProductId] ,
ISNULL(bandage.[ProductDescription],'') as BandageProductDescription,
[BandageProductQuantity] as BandageProductQuantity ,
--mob.[TapeProductId] ,
ISNULL(tap.[ProductDescription],'') as TapeProductDescription,
[TapeProductQuantity] as TapeProductQuantity
  
FROM [dbo].[MobileOrder] mo


INNER JOIN [dbo].[Practices] pract on pract.[PracticeId] = mo.PracticeId 
INNER JOIN [dbo].[RecordRelations] rel on rel.[PracticeId]=mo.PracticeId 
INNER JOIN [dbo].[Physicians] phy on phy.[PhysicianId] = rel.[PhysicianId]
INNER JOIN [dbo].[MobileOrderDetail] mob on mob.MobileOrderId=mo.MobileOrderId

INNER JOIN [dbo].[salesRepInfoes] sales on sales.[salesRepInfoId] = rel.SalesRepId
INNER JOIN [dbo].[MobileOrderDocument] orderDoc on orderDoc.MobileOrderId=mo.MobileOrderId

LEFT JOIN [dbo].[ProductTables] prime on mob.[PrimaryProductId] =prime.[ProductId]

LEFT JOIN [dbo].[ProductTables] gauze on mob.[GauzeProductId] =gauze.[ProductId]

LEFT JOIN [dbo].[ProductTables] bandage on mob.[BandageProductId] =bandage.[ProductId]

LEFT JOIN [dbo].[ProductTables] tap on mob.[TapeProductId] =tap.[ProductId]

WHERE mo.MobileOrderId = @orderId AND rel.IsActive=1

END


GO
