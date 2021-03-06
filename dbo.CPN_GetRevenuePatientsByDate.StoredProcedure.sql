USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetRevenuePatientsByDate]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <21-07-2016>
-- Description:	<get number of patient list by date>

-- Exec CPN_GetRevenuePatientsByDate '2016-07-29'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetRevenuePatientsByDate]
	@date datetime,
	@practiceId uniqueidentifier,
	@physicianId uniqueidentifier
	AS
BEGIN
	
	SET NOCOUNT ON;
	if(@practiceId <> '00000000-0000-0000-0000-000000000000' and @physicianId <> '00000000-0000-0000-0000-000000000000')
	begin
	select distinct p.PatientId, p.createdDate as [Date], s.initial as [SalesrepName], pr.legalName as [Practice], phy.initials as [Physician],
	 concat(pat.nameFirst,' ',pat.namelast) as [Patient], pat.PatientId
	, prod.productDescription as [Product],
	 p.productQuntity,round(convert(float,p.productPrice),2) as  productPrice
	from patientOrders p 
	inner join recordRelations r on r.practiceId = p.practiceId
	inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
	inner join practices pr on pr.practiceId = p.practiceId
	inner join Physicians phy on phy.physicianId = p.Physicianid
	inner join patientInfoes pat on pat.patientId = p.PatientId
	inner join productTables prod on prod.ProductId = p.itemId
	where convert(date,p.createdDate)  = @date and prod.categoryName = 'Primary'
	and p.practiceId = @practiceId and p.physicianId = @physicianId
	end
	else if(@practiceId <> '00000000-0000-0000-0000-000000000000' )
	begin
	select distinct p.PatientId, p.createdDate as [Date], s.initial as [SalesrepName], pr.legalName as [Practice], phy.initials as [Physician],
	 concat(pat.nameFirst,' ',pat.namelast) as [Patient], pat.PatientId
	, prod.productDescription as [Product],
	 p.productQuntity,round(convert(float,p.productPrice),2) as  productPrice
	from patientOrders p 
	inner join recordRelations r on r.practiceId = p.practiceId
	inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
	inner join practices pr on pr.practiceId = p.practiceId
	inner join Physicians phy on phy.physicianId = p.Physicianid
	inner join patientInfoes pat on pat.patientId = p.PatientId
	inner join productTables prod on prod.ProductId = p.itemId
	where convert(date,p.createdDate)  = @date and prod.categoryName = 'Primary'
	and p.practiceId = @practiceId
	end
	else 
	begin
	select distinct p.PatientId, p.createdDate as [Date], s.initial as [SalesrepName], pr.legalName as [Practice], phy.initials as [Physician],
	 concat(pat.nameFirst,' ',pat.namelast) as [Patient], pat.PatientId
	, prod.productDescription as [Product],
	 p.productQuntity,round(convert(float,p.productPrice),2) as  productPrice
	from patientOrders p 
	inner join recordRelations r on r.practiceId = p.practiceId
	inner join salesRepInfoes s on s.salesRepInfoId = r.salesRepId
	inner join practices pr on pr.practiceId = p.practiceId
	inner join Physicians phy on phy.physicianId = p.Physicianid
	inner join patientInfoes pat on pat.patientId = p.PatientId
	inner join productTables prod on prod.ProductId = p.itemId
	where convert(date,p.createdDate)  = @date and prod.categoryName = 'Primary'
	end

END


GO
