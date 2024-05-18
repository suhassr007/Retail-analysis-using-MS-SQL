 --1. 
   select count (*) from [dbo].[Customer]
   select count (*) from[dbo].[prod_cat_info]
   select count (*) from[dbo].[Transactions]
     
--2. 
   select count(total_amt)from[dbo].[Transactions]
   where total_amt like '-%'

--3.
  select FORMAT (DOB,'dd-MM-yyyy') AS FORMATTED_DATE FROM[dbo].[Customer]
  select FORMAT (tran_date,'dd-MM-yyyy')AS FORMATTED_DATE FROM[dbo].[Transactions]
 
--4.
   select DATEDIFF(day,min(tran_date),MAX(tran_date))as days,
   DATEDIFF(MONTH,MIN(tran_date),MAX(tran_date))as months,
   DATEDIFF(year,min(tran_date),MAX(tran_date))as years from[dbo].[Transactions]

--5. 
   select*from[dbo].[prod_cat_info]
   select prod_cat from[dbo].[prod_cat_info]where prod_subcat='DIY'

  -- DATA ANALYSIS

--1.
   select top 1 (Store_type),count(Store_type) as channels from[dbo].[Transactions]
   group by (Store_type)
   order by channels desc;

--2.
   select gender,count (gender) as count from[dbo].[Customer]
   where gender in ('M','F') group by Gender

--3. 
   select top 1 (city_code), count(city_code) as no_of_cus from[dbo].[Customer]
   group by (city_code) order by no_of_cus desc

--4. 
   select*from[dbo].[prod_cat_info]
   select(prod_cat),count(prod_subcat) as no_of_subcat from [dbo].[prod_cat_info]
   where (prod_cat)='BOOKS' group by (prod_cat)

--5. 
   select max(Qty)as max_qty from[dbo].[Transactions]

--6.
   select(prod_cat),sum(total_amt) as total_revenue from[dbo].[Transactions] t
   inner join[dbo].[prod_cat_info] p on p. prod_cat_code = t.prod_cat_code 
   and p.prod_sub_cat_code = t.prod_subcat_code
   where prod_cat in ('Electronics','Books') group by prod_cat

--7. 
   select count (customer_id) as cust_count from[dbo].[Customer]
   where customer_id in (select customer_id from[dbo].[Transactions]t
   inner join[dbo].[Customer] c on t.cust_id = c.customer_Id 
   where total_amt not like '-%' group by customer_id having count
  (transaction_id)>10) 

 --8. 
    select sum(total_amt) as combined_revenue from[dbo].[Transactions]t 
    inner join[dbo].[prod_cat_info] p on t.prod_cat_code=p.prod_cat_code
	and t.prod_subcat_code= p. prod_sub_cat_code where prod_cat in ('Clothing','Electronics')
	and Store_type='Flagship store' 

--9. 
   select p.prod_subcat,p.prod_cat,sum(total_amt)as total_revenue from[dbo].[Customer]c
   left join[dbo].[Transactions]  t on t.cust_id=c.customer_Id
   left join prod_cat_info p on p.prod_cat_code = t. prod_cat_code
   where Gender like 'M%' group by p.prod_subcat,p.prod_cat
   having prod_cat='Electronics'

--10. 
   select top 5 p.prod_subcat,(sum([total_amt])/(select sum([total_amt]) from[dbo].[Transactions]))*100 as per_sales,
   (count(case when [total_amt]<0 then [total_amt] else null end)/sum([total_amt]))*100 as per_returns
   from[dbo].[prod_cat_info] p
   inner join[dbo].[Transactions] T on T . [prod_cat_code]=p.[prod_cat_code] AND T.[prod_subcat_code]=P.[prod_sub_cat_code]
   group by p.prod_subcat
   order by sum([total_amt]) desc

--11.
   select[cust_id],sum([total_amt]) as total_revenue from[dbo].[Transactions] 
   where [cust_id] in
   (select [customer_Id] from[dbo].[Customer]
   where DATEDIFF(year,convert(date,[DOB],103),GETDATE()) between 25 and 35)
   And convert(date,[tran_date],103)between dateadd(day,-30,
   (select max(convert(date,[tran_date],103)) from[dbo].[Transactions]))
   and (select max (convert(date,[tran_date],103))from[dbo].[Transactions])
   group by [cust_id]

--12. 
   select top 1 p.[prod_cat],sum(total_amt) as Total_amount
   from[dbo].[prod_cat_info] p
   inner join[dbo].[Transactions] t on t.[prod_cat_code]=p.[prod_cat_code]
   and p.prod_sub_cat_code=t.prod_cat_code
   where total_amt <0
   and convert(date,tran_date,103) between dateadd(month,-3,
   (select max(convert(date,tran_date,103)) from[dbo].[Transactions]))and
   (select max(convert(date,tran_date,103)) from[dbo].[Transactions])
    group by [prod_cat]
   order by Total_amount desc; 

--13.
   select [store_type],sum(total_amt) Tot_SALES, SUM([Qty]) TOT_QUAN
   from[dbo].[Transactions]
   GROUP BY [Store_type]
   HAVING SUM(total_amt) >=ALL (SELECT SUM(total_amt) from [dbo].[Transactions] group by store_type)
   AND SUM (Qty)>=ALL (SELECT SUM (Qty) from [dbo].[Transactions] group by store_type) 

--14 .
  select [prod_cat],avg([total_amt]) as average from [dbo].[prod_cat_info] p
  inner join[dbo].[Transactions] t on t.prod_cat_code=p.prod_cat_code
  group by [prod_cat]
  having avg([total_amt])>(select avg([total_amt]) from[dbo].[Transactions])

--15.
   select top 5 [prod_subcat],avg([total_amt]) as avg_rev,
   sum([total_amt])as tot_rev
   from[dbo].[Transactions] t
   inner join[dbo].[prod_cat_info] p on p.[prod_cat_code]=t.[prod_cat_code] and p.[prod_sub_cat_code]=t.[prod_subcat_code]
   where [prod_cat] in
   (select top 5 [prod_cat] from[dbo].[Transactions]
   inner join [dbo].[prod_cat_info]p on p.[prod_cat_code]=t.[prod_cat_code] and p.[prod_sub_cat_code]=t.[prod_subcat_code]
   group by [prod_cat]
   order by sum(Qty) desc)
   group by [prod_subcat]