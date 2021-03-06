USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_OrderReviewOnEmail]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratik Godha
-- Create date: 27102016
-- Description:	Send Order Review on Email to CPN Admin
-- [dbo].[CPNDevice_OrderReviewOnEmail] '1B449D7D-ED68-4582-B812-786774F0E342'
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_OrderReviewOnEmail] 

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
phy.[Initials] as  PhysicianName ,
mo.[FacilityName] as FacilityName ,
mo.[FacilityType] as FacilityType,
mob.[Wounds] as Wounds ,
mob.[NumberOfDays] as  NumberOfDays,
--mob.[PrimaryProductId],
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
[TapeProductQuantity] as TapeProductQuantity,
mob.[FrequencyType] as [FrequencyType],
mob.[Location] as Location,
mob.[LocationText] as LocationText,
mob.[Length] as [Length],
mob.[Width] as Width,
mob.[Depth] as Depth,
mob.[WoundStage] as WoundStage,
mob.[Dranage] as Dranage,
mob.[Debrided] as Debrided ,
mob.[ICD10Code] as ICD10Code

  
 from [MobileOrder] mo


inner join [dbo].[Practices] pract on pract.[PracticeId] = mo.PracticeId 
inner join [dbo].[RecordRelations] rel on rel.[PracticeId]=mo.PracticeId 
inner join [dbo].[Physicians] phy on phy.[PhysicianId] = rel.[PhysicianId]
Inner join [dbo].[MobileOrderDetail] mob on mob.MobileOrderId=mo.MobileOrderId

left join [dbo].[ProductTables] prime on mob.[PrimaryProductId] =prime.[ProductId]

left join [dbo].[ProductTables] gauze on mob.[GauzeProductId] =gauze.[ProductId]

left join [dbo].[ProductTables] bandage on mob.[BandageProductId] =bandage.[ProductId]

left join [dbo].[ProductTables] tap on mob.[TapeProductId] =tap.[ProductId]

where mo.MobileOrderId = @orderid 
--and rel.[PhysicianId] =mo.PrescriberId
and rel.isactive=1 AND mo.IsActive=1

END



GO
