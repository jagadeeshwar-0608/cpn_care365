USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_AdminModule_Financial_MORevenue]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- CPN_AdminModule_Financial_MORevenue @year = 2017
-- =============================================
CREATE PROCEDURE [dbo].[CPN_AdminModule_Financial_MORevenue]
	-- Add the parameters for the stored procedure here
	@year int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
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


SELECT  concat( left(DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)),3)
,'-', DATEname(year,dateadd(month,x.number,@startDate))) AS MonthName,
datepart(mm,dateadd(month,x.number,@startDate)) as monthId
into #months
FROM    master.dbo.spt_values x
WHERE   x.type = 'P'        
AND x.number <= DATEDIFF(MONTH, @StartDate, @EndDate);
	

	

select distinct po.orderId, 
(po.productQuntity * po.productPrice) as Revenue, pt.hcpcs,

 pt.item,pt.productDescription, left(datename(month,convert(date,po.createdDate)) ,3)+
 + '' + '-' + + '' + datename(year,convert(date,po.createdDate)) as monthname , @year as year

 into #general
 from patientOrders po
 inner join productTables pt on pt.productId = po.itemid
 where po.isactive = 1
 and convert(date,po.createdDate) > = @fDate and convert(date,po.createdDate) <= @tDate


 select m.monthname, m.monthId, g.item,g.hcpcs, g.productDescription,g.revenue,g.year 
		into #pracData
		from #months m
		left join #general g on g.monthname = m.monthname




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

create table #temp
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
                select Revenue,item,hcpcs,productDescription,monthname,year
                from #pracData
				where item is not null 
           ) x
            pivot 
            (
                 sum(Revenue)
                for monthname in (' + @cols + ')
            ) p '


 insert into #temp
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
  from #temp
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

-- CPN_AdminModule_Financial_MORevenue @year = 2017
GO
