USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetSKUWrittenReport]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <18-09-2016>
-- Description:	<Sku writeen report>
-- CPN_GetSKUWrittenReport '2017-07-01','2017-07-18'
-- =============================================
CREATE PROCEDURE [dbo].[CPN_GetSKUWrittenReport]
	@fromDate nvarchar(20) = null,
	@toDate nvarchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure 
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
	
	select a.practiceId, a.legalname as PracticeName, a.physicianName,a.physicianId,
	a.Orders, isnull(b.counta,0) as Hydrogel, isnull(c.counta,0) as CollagenPowder, isnull(d.counta,0) as CollagenDressing, 
	isnull(e.counta,0) as Hydrocolloidal, isnull(f.counta,0) as Foam, isnull(g.counta,0) as SilverAlginate
	 from 
	 (select prac.practiceId, prac.legalname,  phy.physicianId,phy.initials as physicianName,
	  count(distinct po.orderId) as Orders from Practices prac
		inner join patientOrders po on po.practiceId= prac.practiceId
		inner join physicians phy on phy.physicianId = po.physicianId

		where convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by prac.practiceId, prac.legalname, phy.initials,phy.PhysicianId) a
		left join 
		
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where productDescription Like '%Hydrogel%' and
		convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) b on a.practiceId = b.practiceId
		left join 
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where productDescription Like '%Collagen Powder%'
		and convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) c on a.practiceId = c.practiceId
		left join 
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where productDescription Like '%collagen dressing%'and
		convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) d on a.practiceId = d.practiceId
		left join 
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where productDescription Like '%Hydrocolloidal%' and
		convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) e on a.practiceId = e.practiceId
		left join 
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where productDescription Like '%Foam%' and 
		convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) f on a.practiceId = f.practiceId
		left join 
		(
		select prac.PracticeId, productDescription, count(po.orderId) as counta  from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		inner join practices prac on prac.practiceId = po.practiceId
		where (productDescription Like '%Silver%' or productDescription Like '%Alginate%') and
		convert(date,po.CreatedDate) >= @fDate and convert(date,po.CreatedDate) <= @tDate
		and po.isactive = 1
		group by productDescription, prac.practiceID
		) g on a.practiceId = g.practiceId
END


GO
