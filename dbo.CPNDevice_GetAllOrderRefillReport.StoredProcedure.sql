USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_GetAllOrderRefillReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratik Godha
-- Create date: 14/10/2016
-- Description:	'GetAllOrderRefillReport' On Device Side
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_GetAllOrderRefillReport]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT morder.[MobileOrderId] AS MobileOrderId ,morder.[InvoiceNumber] as InvoiceNumber,

 CONVERT(DATE,morder.createdDate) AS [OrderDate] , morder.[FacilityName] AS FacilityName ,
	phy.[Initials] PhysicianName , morder.[PatientFirstName] PatientFirstName , morder.[PatientLastName] PatientLastName
	--,CONVERT(DATE,morder.createdDate) AS [OrderDate]
	,  -- CONCAT(morder.[PatientFirstName],' ',morder.[PatientLastName]) AS PatientName,
	DATEADD(dd,30,CONVERT(DATE,morder.createdDate)) AS NextRefillDate,
	DATEDIFF(dd,convert(DATE,GETDATE()),DATEADD(dd,30,CONVERT(DATE,morder.createdDate))) AS Duedays

	FROM [dbo].[MobileOrder] morder

	INNER JOIN [dbo].[Physicians] phy ON phy.physicianId = morder.[PrescriberId]
	WHERE morder.IsActive=1

--	Where morder.Practiceid=@practiceId AND morder.[FacilityName]=@facilityName 

END


GO
