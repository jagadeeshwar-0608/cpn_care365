USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_GetOrderListById]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_GetOrderListById]

@userId uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
SELECT morder.[MobileOrderId] AS MobileOrderId , CONVERT(DATE,morder.createdDate) AS [OrderDate] ,
	morder.[InvoiceNumber] as InvoiceNumber ,
 	phy.[Initials] PhysicianName , 
	pract.[LegalName] PracticeName ,
	morder.[PatientFirstName] PatientFirstName , morder.[PatientLastName] PatientLastName,
	'Ordered' as OrderStatus
	FROM [dbo].[MobileOrder] morder
	INNER JOIN [dbo].[Physicians] phy ON phy.physicianId = morder.[PrescriberId]
	inner join [dbo].[Practices] pract on pract.PracticeId=morder.PracticeId
	Where morder.Practiceid=@userId And morder.IsActive=1


END


GO
