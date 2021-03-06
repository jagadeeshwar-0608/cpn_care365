USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_Financial_MOGrossProfit]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jagadeeshwar Mosali>
-- Create date: <27-01-2017>
-- Description:	<Admin module gross profit financial report>
-- exec CPN_AdminModule_Financial_MOGrossProfit @year = 2017
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_Financial_MOGrossProfit]
	-- Add the parameters for the stored procedure here
	@year int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @fDate date
	declare @tDate date
	if @year is null
	begin
	set @year = datepart(yy,getdate())
	
	end

	set @fDate = convert(date, DATEADD(month,0,DATEADD(year,@Year-1900,0)))
	set @tDate = convert(date,DATEADD(day,-1,DATEADD(month,12,DATEADD(year,@Year-1900,0))))
	

	DECLARE @StartDate  DATETIME,
        @EndDate    DATETIME;

SELECT   @StartDate = @fDate        
        ,@EndDate   = @tDate;


SELECT  concat( left(DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)),3),
'-',
 DATEname(year,dateadd(month,x.number,@startDate))) AS MonthName,
datepart(mm,dateadd(month,x.number,@startDate)) as monthId
into #months
FROM    master.dbo.spt_values x
WHERE   x.type = 'P'        
AND x.number <= DATEDIFF(MONTH, @StartDate, @EndDate);
	

			select distinct po.orderId, pt.productDescription, pt.item,pt.hcpcs,
		po.productPrice * po.productQuntity as revenue,
		--po.productQuntity * convert(float,pt.cpncogs) as cogs,
		isnull(round(convert(float,pt.cpncogs),2),0) * po.ProductQuntity as cogs,
		left(datename(month,convert(date,po.createdDate)),3) +
		 + '' + '-' + + '' + datename(year,convert(date,po.createdDate)) as monthname,@year as year
		into #temp
		from patientOrders po
		inner join productTables pt on pt.productId = po.itemId
		where po.isactive = 1 
		and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate

		select item, hcpcs,productDescription, sum(revenue) as revenue ,sum(cogs) as cogs, monthname,year
		into #general
		from #temp
		group by item, hcpcs,productDescription,monthname,year
		
		
		select distinct po.orderId, productDescription,left(datename(month,convert(date,po.createdDate)),3) +
		+ '' + '-' + + '' + datename(year,convert(date,po.createdDate)) as monthname,
		isnull(round(convert(float,convert(float,po.productQuntity) * convert(float,commissionMoSupply)/30),2),0) as Commission
		into #commData
		from patientOrders po 
		inner join productTables pt on pt.productId = po.itemId
		where 
		po.isactive = 1 and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate
		and pt.categoryname  = 'Primary' 
		
		select productDescription,monthname, sum(commission) as commission
		into #commissionData
		from #commData
		group by productDescription,monthname
		
		select distinct po.orderId, o.freightAmt,pt.productDescription,hcpcs,
		left(datename(month,convert(date,po.createdDate)),3) +
		+ '' + '-' + + '' + datename(year,convert(date,po.createdDate)) as monthname
		into #shipcost
		from patientOrders po 
		inner join orders o on o.orderId = po.orderId
		inner join productTables pt on pt.productId = po.itemId
		where po.isactive = 1 and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate

		select productDescription,monthname, isnull(sum(freightAmt),0) as shipcost
		into #shippingcost
		from #shipcost
		group by productDescription,monthname

		select g.item, g.hcpcs, g.productDescription,g.monthname,
		--round(g.revenue - (isnull(cogs,0) + isnull(c.commission,0) + isnull(s.shipcost,0)),2) as grossProfit,
		round(g.revenue- (isnull(g.cogs,0)),2) as grossProfit,
		g.year
		into #grossProfit
		from #general g 
		left join #commissionData c on g.productDescription  = c.productDescription and g.monthname = c.monthname
		left join #shippingCost s on s.productDescription = c.productDescription and g.monthname = s.monthname


		select m.monthname, m.monthId, g.item,g.hcpcs, g.productDescription,g.grossprofit,g.year
		into #pracData
		from #months m
		left join #grossprofit g on g.monthname = m.monthname



		DECLARE @cols AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX);

		select @cols = STUFF((SELECT  ',' + QUOTENAME(monthname)
		FROM 
		(SELECT DISTINCT monthname , monthId
                          FROM #pracData
                          )sub
		  
		order by monthId
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')

create table #temp3
(
  [item]  varchar(20)
, [hcpcs]   varchar(20)
, [productDescription]   varchar(200)
,[year] int
, [Jan]   varchar(20)
, [Feb]   varchar(20)
, [Mar]   varchar(20)
, [Apr]   varchar(20)
, [May]   varchar(20)
, [Jun]   varchar(20)
, [Jul]   varchar(20)
, [Aug]   varchar(20)
, [Sep]   varchar(20)
, [Oct]   varchar(20)
, [Nov]   varchar(20)
, [Dec]  varchar(20)
)

		set @query = 'SELECT * from 
					 (
					 select grossProfit,item,hcpcs,productDescription,monthname,year
					 from #pracData
					 where item is not null 
					 ) x
					 pivot 
					 (
					 sum(grossProfit)
					 for monthname in (' + @cols + ')
					 ) p '
					 
					 
 insert into #temp3
 exec sp_executesql @query

 select  isnull(item, '') item
, isnull(hcpcs, '') hcpcs
, isnull(productDescription, '') productDescription

,isnull(year,0) year
, isnull(Jan, '0') 'Jan'
, isnull(Feb, '0') 'Feb'
, isnull(Mar, '0') 'Mar'
, isnull(Apr, '0')	'Apr'
, isnull(May, '0')	'May'
, isnull(Jun, '0')	'Jun'
, isnull(Jul, '0')	'Jul'
, isnull(Aug, '0')	'Aug'
, isnull(Sep, '0')	'Sep'
, isnull(Oct, '0')	'Oct'
, isnull(Nov, '0')	'Nov'
, isnull(Dec, '0')	'Dec'
   into #temp2
  from #temp3
 declare @rename1 varchar(50), @column_name varchar(50), @rename2 varchar(50)

 declare rename_cursor cursor
    for
 select column_name
  from tempdb.information_schema.columns 
  where table_name like '%temp2%'
  and column_name not in ('item','hcpcs','productDescription','year')
  open rename_cursor
  fetch next from rename_cursor into @column_name
  while @@fetch_status = 0
   begin
 
  set @rename1 = '#temp2.['+@column_name+']'
 --set @rename2 = @column_name +' - '+cast(@year as varchar(10))
  set @rename2 = @column_name
 exec tempdb..sp_rename @rename1,@rename2
    
	fetch next from rename_cursor into @column_name
   end
 close rename_cursor
 deallocate rename_cursor

 select * from #temp2    


    
END

-- exec CPN_AdminModule_Financial_MOGrossProfit @year = 2017
GO
