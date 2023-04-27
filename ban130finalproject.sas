
data product_clean;
set mylib4.product(keep=productid name productnumber color listprice);
if color="  " then color="NA";
format listprice1 dollar15.2;	
listprice1=input(listprice, dollar15.2);
drop listprice;
rename listprice1=listprice;
run;

proc print data=product_clean(obs=10);
run;




data salesorderdetail_clean_temp;
set mylib4.salesorderdetail(keep=SalesOrderID SalesOrderDetailID OrderQty ProductID UnitPrice LineTotal  ModifiedDate);
format unitprice1 linetotal1 dollar15.2 orderqty1 15.0 modifieddate1 mmddyy10.;
unitprice1=input(unitprice, dollar15.2);
linetotal1=input(linetotal, dollar15.2);
orderqty1=input(orderqty, 15.0);
modifieddate1=input(ModifiedDate,yymmdd10.);
drop unitprice linetotal orderqty modifieddate;
rename unitprice1=unitprice linetotal1=linetotal orderqty1=orderqty modifieddate1=modifieddate;
run;

data salesorderdetail_clean;
set salesorderdetail_clean_temp;
where (year(modifieddate)=2013) or (year(modifieddate)=2014);
run;

proc sort data=product_clean out=product_clean_sort;
by productid;
run;
proc sort data=salesorderdetail_clean out=salesoderdetail_clean_sort;
by productid;
run;

data salesdetails;
merge  salesoderdetail_clean_sort(in=in_salesorderdetail)
        product_clean_sort(in=in_product);
by productid;
if in_salesorderdetail and in_product;
drop SalesOrderID SalesOrderDetailID ProductNumber and ListPrice ;
run;

data salesanalysis;
set salesdetails;
by productid;
if first.productid then subtotal=0;
subtotal + linetotal;
if last.productid;
format subtotal dollar10.2;
run;

proc sql ;
 create table red_helmet_sales as  
	select 
	sum(case when (productid='707' and year(modifieddate)=2013)then orderqty else . end)as redhelmet_2013,
	sum(case when(productid='707'and year(modifieddate)=2014)then orderqty else . end)as redhelmet_2014,
	productid from salesdetails
	where productid='707'
	group by productid;
	quit;
	
	proc print data= red_helmet_sales;
	
proc sql;
create table multicolor_helmet_sales as
select 
sum(case when(color='Multi' and year(modifieddate)=2013)then orderqty else . end)as multicolor_helmet_2013,
sum(case when(color='Multi' and year(modifieddate)=2014)then orderqty else . end)as multicolor_helmet_2014,
color
from salesdetails
where color='Multi'
group by color;
quit;

proc print data=multicolor_helmet_sales;

proc sql;
create table total_helmet_sales as
select 
sum(case when (year(modifieddate)=2013)then linetotal else . end)as total_helmet_sales_2013,
sum(case when(year(modifieddate)=2014)then linetotal else . end)as total_helmet_sales_2014
from salesdetails
where name like '%Helmet%';
quit;

proc sql;
create table yellow_touring_1000 as
select
sum(case when(productid > '953' and productid < '958' and year(modifieddate)=2013) then orderqty else . end)
as totalsales_yellow_2013,
sum(case when(productid > '953' and productid < '958' and year(modifieddate)=2014) then orderqty else . end)
as totalsales_yellow_2014,
productid
from salesdetails
where (productid > '953' and productid < '958')
group by productid;
quit;

proc sql;
create table total_sales as
select 
sum( case when (year(modifieddate)=2013) then linetotal else . end)as total_sales_2013,
sum( case when(year(modifieddate)=2014) then linetotal else . end)as total_sales_2014
from salesdetails;
quit;












