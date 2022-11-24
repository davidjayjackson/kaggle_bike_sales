USE bikeshop
GO

SELECT 
	ord.partnerid,
	ord.salesorderid,
	ord.createdat ,
	it.salesorderitem,
	it.productid,
	it.netamount,
	it.quantity
--	INTO #sales1
FROM orders ord
INNER JOIN order_item it
ON ord.salesorderid = it.salesorderid;

SELECT p.productid,p.medium_descr,s.*
FROM product_text p
INNER  JOIN #sales1 s
ON  p.productid = s.productid	




