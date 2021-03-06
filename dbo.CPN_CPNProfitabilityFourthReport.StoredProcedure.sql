USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_CPNProfitabilityFourthReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	

-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <07-10-2016>
-- Description:	<Get CPN Profitablity Fourth Report>
-- CPN_CPNProfitabilityFourthReport '2017-01-03','8e4c9289-1cea-41f7-9fb1-1c8ea79340b8'
-- =============================================

CREATE PROCEDURE [dbo].[CPN_CPNProfitabilityFourthReport]
	-- Add the parameters for the stored procedure here
	@date nvarchar(20),

	@orderId uniqueIdentifier
AS



BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from



	-- interfering with SELECT statements.



	SET NOCOUNT ON;

    -- Insert statements for procedure here

select distinct(po.orderId),convert(date,po.createdDate) as createdDate,

o.orderNumber as InvoiceNumber, s.salesRepInfoId as [RepId], s.initial as [SalesrepName],

prac.practiceId as PracticeId, prac.Legalname as PracticeName,phy.physicianId, phy.Initials as PhysicianName,

pat.PatientId, concat(pat.namefirst,' ',pat.nameLast)  as PatientName,

prod.productDescription, productQuntity as productQuantity,

prod.medicareFreeSchedule,

--round(convert(float,po.productPrice),2) as  productPrice,

o.paymentStatus, 

(select 'Some Payor') as PrimaryPayor,

 po.productQuntity * po.productPrice as invoiceAmount,

isnull(o.orderstatus,'') as shippingstatus

 from patientOrders po

inner join orders o on o.orderId = po.orderId

inner join practices prac on prac.practiceId = po.practiceId

inner join physicians phy on phy.physicianId = po.physicianId

inner join patientInfoes pat on pat.patientId = po.patientId

inner join recordRelations r on r.practiceId = po.practiceId

inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId

inner join productTables prod on prod.productId = po.itemid

where convert(date,po.createdDate)  = @date and po.orderId = @orderId and r.isactive=1

group by po.orderId, po.createdDate, prac.LegalName, phy.Initials, pat.namefirst, pat.namelast,

po.productQuntity, po.productPrice, o.orderstatus, s.initial, o.paymentstatus, prod.medicarefreeschedule,

prod.productDescription, po.productQuntity, phy.physicianId, prac.PracticeId, s.salesrepinfoId, pat.patientId,o.orderNumber

END


-- CPN_CPNProfitabilityFourthReport '2017-01-03','8e4c9289-1cea-41f7-9fb1-1c8ea79340b8'

GO
