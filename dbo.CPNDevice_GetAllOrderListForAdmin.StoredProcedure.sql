USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPNDevice_GetAllOrderListForAdmin]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPNDevice_GetAllOrderListForAdmin '2017-01-01','2017-01-30' 
-- =============================================
CREATE PROCEDURE [dbo].[CPNDevice_GetAllOrderListForAdmin]

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
	set @tDate = getdate()
	end
	else
	begin
	set @tDate = @toDate
	end

	
--SELECT morder.[MobileOrderId] AS MobileOrderId , CONVERT(DATE,morder.createdDate) AS [OrderDate] ,
--	morder.[InvoiceNumber] as InvoiceNumber ,
-- 	phy.[Initials] PhysicianName , 
--	pract.[LegalName] PracticeName ,
--	morder.[PatientFirstName] PatientFirstName , morder.[PatientLastName] PatientLastName,
--	'Processing' as OrderStatus
--	FROM [dbo].[MobileOrder] morder
--	INNER JOIN [dbo].[Physicians] phy ON phy.physicianId = morder.[PrescriberId]
--	inner join [dbo].[Practices] pract on pract.PracticeId=morder.PracticeId
--	Where morder.IsActive=1 AND
	
	
--	convert(date,morder.createdDate)  > = @fDate and convert(date,morder.createdDate) <= @tDate
SELECT CONVERT(DATE,morder.createdDate) AS [OrderDate], ISNULL(morder.[InvoiceNumber],0) as InvoiceNumber ,

 	phy.[Initials] PhysicianName , 
	morder.[PatientFirstName] PatientFirstName , morder.[PatientLastName] PatientLastName,
	morder.FacilityName as  FacilityName,
	pract.[LegalName] PracticeName ,
	DATEADD(dd,30,CONVERT(DATE,morder.createdDate)) AS NextRefillDate,
	DATEDIFF(dd,convert(DATE,GETDATE()),DATEADD(dd,30,CONVERT(DATE,morder.createdDate))) AS Duedays,

	ISNULL(prime.[ProductDescription],'') as PrimaryProductDescription,
	prime.HCPCS as PrimaryProductHCPCS,
	moborderdetail.PrimaryProductQuantity as PrimaryProductQuantity,
	ISNULL(CONVERT(FLOAT,moborderdetail.PrimaryProductPrice * moborderdetail.PrimaryProductQuantity),0)  as PrimaryProductInvoicePrice ,

	ISNULL(gauze.[ProductDescription],'') as GauzeProductDescription,
	gauze.HCPCS as GauzeProductHCPCS,
	[GauzeProductQuantity] as GauzeProductQuantity,
	ISNULL(CONVERT(FLOAT,moborderdetail.GauzeProductPrice * moborderdetail.GauzeProductQuantity),0)  as GauzeProductInvoicePrice ,

	ISNULL(bandage.[ProductDescription],'') as BandageProductDescription,
	bandage.HCPCS as BandageProductHCPCS,
	[BandageProductQuantity] as BandageProductQuantity ,
	ISNULL(CONVERT(FLOAT,moborderdetail.BandageProductPrice * moborderdetail.BandageProductQuantity),0)  as BandageProductInvoicePrice ,

	ISNULL(tap.[ProductDescription],'') as TapeProductDescription,
	tap.HCPCS as TapeProductHCPCS,
	[TapeProductQuantity] as TapeProductQuantity,
	ISNULL(CONVERT(FLOAT,moborderdetail.TapeProductPrice * moborderdetail.TapeProductQuantity),0)  as TapeProductInvoicePrice ,

	'Processing' as OrderStatus,
	 morder.[MobileOrderId] AS MobileOrderId 
	 
	FROM [dbo].[MobileOrder] morder
	INNER JOIN [dbo].[Physicians] phy ON phy.physicianId = morder.[PrescriberId]
	INNER JOIN [dbo].[Practices] pract on pract.PracticeId=morder.PracticeId
	INNER JOIN [dbo].[MobileOrderDetail] moborderdetail ON moborderdetail.MobileOrderId=morder.MobileOrderId
	--RIGHT JOIN [dbo].[PracticeProductInfo] pro on pro.PracticeId = morder.PracticeId
	
	--left join [dbo].[PracticeProductInfo] prime on   moborderdetail.[PrimaryProductId] =prime.[ProductId]
	--left join [dbo].[PracticeProductInfo] gauze on   moborderdetail.[GauzeProductId] =gauze.[ProductId]
	--left join [dbo].[PracticeProductInfo] bandage on moborderdetail.[BandageProductId] =bandage.[ProductId]
	--left join [dbo].[PracticeProductInfo] tap on     moborderdetail.[TapeProductId] =tap.[ProductId]

	left join [dbo].[ProductTables] prime on   moborderdetail.[PrimaryProductId] =prime.[ProductId]
	left join [dbo].[ProductTables] gauze on   moborderdetail.[GauzeProductId] =gauze.[ProductId]
	left join [dbo].[ProductTables] bandage on moborderdetail.[BandageProductId] =bandage.[ProductId]
	left join [dbo].[ProductTables] tap on     moborderdetail.[TapeProductId] =tap.[ProductId]

	Where morder.IsActive=1
		AND convert(date,morder.createdDate)  > = @fDate and convert(date,morder.createdDate) <= @tDate	
	order by morder.CreatedDate desc 

END

--  CPNDevice_GetAllOrderListForAdmin 'null','null' 

GO
