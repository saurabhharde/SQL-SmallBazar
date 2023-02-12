CREATE DATABASE small_bazar;
use small_bazar;
---------------------------------
CREATE TABLE customer
					(cust_id INT PRIMARY KEY auto_increment,
					 cust_name VARCHAR(30),
					 mobil_no BIGINT ,
					 email VARCHAR(50),
					 address VARCHAR(100),
					 city VARCHAR(20),
					 state1 VARCHAR(20),
					 country VARCHAR(20),
					 pin_code INT);
SET auto_increment_increment=1;					
		
		SELECT * FROM customer;			 
INSERT INTO customer (cust_name,mobil_no,email,address,city,state1,country,pin_code)
			   VALUES('Shubham Pawar',9876123456,'shubham.pawar@ellicium.com','pune camp','pune','maharashtra','india',411004),
					 ('Ganesh Mane',3776623637,'ganesh.mane@ellicium.com','dangat patil nagar N.D.A road','pune','maharashtra','india',160144),
					 ('Satyam Asati',3276423626,'satyam.asatri@ellicium.com','khair lanji','gondia','maharashtra','india',441601),
					 ('Saurabh Bhoyar',6736732653,'saurabh.bhoyar09@gmail.com','keshav nagar','nagpur','maharastra','india',440023);
-------------------------------------------
SELECT* FROM branch;
CREATE TABLE branch
					(branch_id INT PRIMARY KEY auto_increment,
					 branch_name VARCHAR(50),
					 b_address VARCHAR(100),
					 city VARCHAR(20),
					 country VARCHAR(20)DEFAULT  ('india'),
					 pin_code INT);
	ALTER TABLE branch
				auto_increment=101;
                SET auto_increment_increment=1;
                
	ALTER TABLE branch
    ADD COLUMN branch_status BOOL DEFAULT 1;
					 
INSERT INTO branch  (branch_name,b_address,city,pin_code)
			  VALUES('Small bazar of nanded city','nanded city pune','pune',876322),
					('Small bazar of kurve nagar','kurve nagar pune','pune',214542),
					('Small bazar of gondia city','gandhi nagar gondia','gondia',441601),
					('Small bazar of nagpur city','manish nagar nagpur','nagpur',365356);
---------------------------------------------
SELECT * FROM store;
CREATE TABLE STORE
				   (branch_id INT,
				    product_id INT,
					status1 SMALLINT DEFAULT 1,
					CONSTRAINT b_p_key PRIMARY KEY (branch_id,product_id),
                    CONSTRAINT fk_branch FOREIGN KEY store(branch_id)
                          REFERENCES branch(branch_id),
					CONSTRAINT product_fk FOREIGN KEY store(product_id)
                          REFERENCES product(product_id));
INSERT INTO store (branch_id,product_id)
				VALUES(101,1001),(101,1002),(101,1003),(101,1004),(101,1006),
					  (102,1001),(102,1002),(102,1003),(102,1004),(102,1005),(102,1006),
					  (103,1001),(103,1002),(103,1003),(103,1004),(103,1005),(103,1006),
					  (104,1001),(104,1002),(104,1003),(104,1004),(104,1005),(104,1006);
ALTER TABLE store 
ADD COLUMN cost_price int;
ALTER TABLE store
ADD COLUMN sell_price int;

UPDATE store
SET cost_price=25
WHERE branch_id=104 AND product_id=1006;
 
UPDATE store 
set sell_price=35
where branch_id=104 and product_id=1006;
----------------------------------------------------------------
CREATE TABLE product
					(product_id INT PRIMARY KEY auto_increment,
					 product_name VARCHAR(20));

ALTER TABLE product
				auto_increment=1001;
				
INSERT INTO  product(product_name)
			 VALUES('led bulb'),
					('Holder'),
					('Heater'),
					('Water_bowiler'),
					('switch_board'),
					('carry_bag');
					 
--------------------------------------------
CREATE TABLE order_details
						 (order_id INT,
						  product_id INT,
						  quantity INT DEFAULT 1,
                          CONSTRAINT fk_order FOREIGN KEY order_details(order_id)
                          REFERENCES order_master(order_id));
INSERT INTO order_details (order_id,product_id)
					VALUES(10001,1001),(10001,1002),(10001,1006),
						  (10002,1001),(10002,1002),(10002,1004),(10002,1006),
                          (10003,1001),(10003,1002),(10003,1003),(10003,1006),
                          (10004,1001),(10004,1002),(10004,1003),(10004,1004),(10004,1006);
						
                          
                          SELECT * FROM order_details;
 ----------------------------------------------------------                         
CREATE TABLE order_master
						  (order_id INT PRIMARY KEY auto_increment,
                           cust_id INT,
                           branch_id int,
						   order_date DATE,
						   delivery_status VARCHAR(20) DEFAULT('InProcess'),
						   delivery_type VARCHAR(50),
						   delivery_date DATE,
						   delivery_charges INT DEFAULT 0,
						   total_amount INT ,
                           CONSTRAINT fk_cust FOREIGN KEY order_master(cust_id)
                           REFERENCES customer(cust_id),
                           CONSTRAINT branch_fk FOREIGN KEY order_master(branch_id)
                           REFERENCES branch(branch_id));
	ALTER TABLE order_master
					auto_increment=10001;
	SET auto_increment_increment=1;
	DROP TABLE order_master;
					
INSERT INTO order_master(cust_id,branch_id,Order_date,delivery_status,delivery_type,delivery_date,delivery_charges)
					VALUES(1,101,'22-09-01','self_deleverd','self','22-09-01',0),
						  (2,102,'22-09-02','deleverd','home','22-09-03',50),
						  (3,103,'22-09-03','deleverd','self','22-09-03',50),
						  (4,104,'22-09-03','self_deleverd','self','22-09-03',0);
                          
                          
                          
COMMIT;

---------------------------------------------------------------------
/* 
(1)The CEO of ‘Small Bazar’ wants to check the profitability of the Branches. 
Create a View for his use which will show monthly Profit of all Branches for the current year.
*/

CREATE VIEW view_branch_profit AS 
						(SELECT om.branch_id,SUM(od.quantity*(s.sell_price-s.cost_price) )AS profit
						 FROM order_master Om JOIN order_details Od
						 ON (om.order_id=od.order_id)
						 JOIN store s
						 ON(s.branch_id=om.branch_id AND s.product_id=od.product_id)
						 GROUP BY 
						 EXTRACT(MONTH FROM om.order_date),
						 om.branch_id);

SELECT * FROM view_branch_profit;
---------------------------------------------------------------------
/*
(3)Create a stored procedure which will calculate the total bill for any order. Bill should have details like: 
CustomerName, 
orderId,
 OrderDate,
 Branch,
 ProductName, 
 Price per Unit,

 No. Of Units,
 Total Cost of that product,
 Total Bill Amount,
 Additional Charges (0 if none),
 Delivery Option(‘Home Delivery' or ‘self Pickup’).
*/


USE small_bazar;

DELIMITER //
 CREATE PROCEDURE pro_bill(IN TRA_ID INT)
 BEGIN
 
		DECLARE finish INT DEFAULT 0;
		DECLARE CustomerName VARCHAR(50);
		DECLARE orderId1 INT;
		DECLARE  Branch VARCHAR(40);
		DECLARE order_date date;
		DECLARE  ProductName VARCHAR(60);
		DECLARE  Price_per_Unit INT;
		DECLARE no_of_units INT;
		DECLARE  Total_Bill_Amount INT;
		DECLARE delivery_option VARCHAR(50);


		DECLARE CURS_TRA CURSOR FOR
								 WITH temp_bill AS(
								 SELECT 
										om.order_id,(SUM(od.quantity*s.sell_price))+om.delivery_charges AS bill
								 FROM
										order_master om 
								 JOIN 
										order_details od
								 ON
										(om.order_id=od.order_id)
								 JOIN 
										store s
								 ON
										(od.product_id=s.product_id AND om.branch_id=s.branch_id)
								 GROUP BY 
										om.order_id)
										
								 SELECT 
										c.cust_name,t.order_id,om.order_date,b.branch_name,
										p.product_name,od.quantity,
									    (od.quantity*(s.sell_price))as cost_per_product,
										t.bill,om.delivery_type
										FROM 
											product p 
										JOIN 
											store s
										ON 
											(s.product_id=p.product_id)
										JOIN 
											order_details od
										ON 
											(od.product_id=s.product_id)
										JOIN
											order_master om 
										ON 
											(om.order_id=od.order_id  AND om.branch_id=s.branch_id)
										JOIN 
											temp_bill t
										ON 
											(om.order_id=t.order_id)
										JOIN 
											customer c
										ON 
											(om.cust_id=c.cust_id)
										JOIN  
											branch b
										ON 
											(om.branch_id=b.branch_id)
										WHERE 
											om.order_id=TRA_id ;

		DECLARE CONTINUE handler FOR 
		NOT FOUND SET finish=1;

OPEN CURS_TRA;
	S1 : LOOP
		 IF finish=1 
		 THEN LEAVE  S1;
		 END IF;

		 FETCH CURS_TRA INTO   CustomerName ,orderId1 ,order_date,Branch,
							   ProductName ,no_of_units,Price_per_Unit,
							   Total_Bill_Amount,delivery_option;
 
		 SELECT CustomerName ,orderId1 ,order_date,Branch,ProductName,
				Price_per_Unit,no_of_units,Total_Bill_Amount,delivery_option;
 
		 END LOOP;
		 
CLOSE CURS_TRA;

 END //
 
 DELIMITER ;
 
 
 CALL  PRO_BILL(10002);


----------------------------------------
/*Create a (function )Procedure  having a parameter as country name ,
which displays all the  branches available In the country that are active. */


DELIMITER $$

CREATE PROCEDURE pro_status(IN b_country VARCHAR(30))

BEGIN

	DECLARE activate_branch_name VARCHAR(100);
	DECLARE finish int;
	DECLARE cur_branch CURSOR FOR (SELECT branch_name
								   FROM branch
                                   WHERE branch_status=1 
									AND country='india');
    DECLARE CONTINUE handler FOR 
    NOT FOUND SET finish=1;

OPEN cur_branch;
	S2:LOOP
	IF 
		finish=1 
	THEN 
		leave S2;
	END IF;
	FETCH 
		 cur_branch INTO activate_branch_name ;
	SELECT 
		 activate_branch_name ;
	END LOOP;
CLOSE cur_branch;
END $$
DELIMITER ;
			
CALL pro_status('india');


-----------------------------------------------
/*
Create a stored procedure having countryName, FromDate and ToDate as Parameter,
 which will return Sitewise, Item Wise and  Date Wise the number of items sold 
 in the given Date range as separate resultsets. Create appropriate Indexes on
 the tables.
 */
 
DELIMITER //

CREATE PROCEDURE pro_S_B_2(IN country_n VARCHAR(20),
						   IN from_date DATE,
						   IN to_date DATE)
BEGIN 
	DECLARE finish INT DEFAULT 0;
	DECLARE B_id VARCHAR(20);
	DECLARE p_id VARCHAR(20);
	DECLARE O_date DATE;
	DECLARE no_sold_items INT;

	DECLARE cur_stock CURSOR FOR   (SELECT 
										  om.branch_id,od.product_id,om.order_date,SUM(od.quantity)
									FROM 
									      order_master om JOIN order_details od
									ON 
									      (om.order_id=od.order_id)
									JOIN 
									       branch b
									ON 
									      (b.branch_id =om.branch_id)
									WHERE 
									       om.order_date BETWEEN from_date AND to_date
										AND 
									       b.country=country_n
									GROUP BY 
										   om.branch_id,od.product_id,om.order_date);

	DECLARE CONTINUE handler 
	FOR NOT FOUND SET finish=1;

OPEN 
	cur_stock;
	
	S3: LOOP
		IF 
			finish=1
		THEN
			leave S3;
		END IF;
		FETCH 
			cur_stock INTO b_id,p_id,o_date,no_sold_items;
		SELECT 
			b_id,p_id,o_date,no_sold_items;
		END LOOP;
CLOSE 
	cur_stock;
END //

DELIMITER ;


CALL pro_S_B_2('india','22-09-1','22-09-3');
-----------------------------------------------------
/*
Create a trigger which will be invoked on adding a new item in the Item entity and insert 
that new item in another table with date and time when the item is added so that we can have 
date and time when an item was added.
*/

CREATE TABLE new_products
						(product_id INT,
                         product_name VARCHAR(50),
                         transaction_date TIMESTAMP);
SELECT * FROM new_products;
                         
DELIMITER $$
						
CREATE TRIGGER tri_inv

AFTER INSERT
ON product
FOR EACH ROW
BEGIN
    INSERT INTO new_products (product_id,product_name,transaction_date)
				VALUES(NEW.product_id,NEW.product_name,now());
END $$

DELIMITER ;



INSERT INTO product (product_name)
				VALUE('Spaner');
                
                
SELECT * FROM new_products;

---------------------------------------------
/*
(5)Write a Trigger which will reduce the stock of some product whenever an order
 is confirmed  by the number of that product in the order. Eg. If an order with 
 10 Oranges is confirmed from Nagpur branch, Stock of Oranges from Nagpur branch 
 must be reduced by 10.
*/
DELIMITER //

CREATE TRIGGER tri_deduct

AFTER INSERT 

ON order_details
FOR EACH ROW

BEGIN
                         ## fetch branch_id using select query into declare variable b_id
		DECLARE b_id INT ;
		
		SELECT 
			  om.branch_id INTO b_id
        FROM
			  order_master om JOIN order_details od
        ON 
			(om.order_id = od.order_id)
        WHERE 
			om.order_id =NEW.order_id;
        
UPDATE  
	  store s
SET 
	stock = stock - NEW.quantity
WHERE
	s.product_id = NEW.product_id
	AND 
	s.branch_id = b_id;
END //

DELIMITER ;

/*inserting one record in order_master and order_details  table to see trigger is working properly or
not*/
INSERT INTO order_master
			(cust_id,branch_id,order_date,delivery_type,delivery_charges)
			VALUES (3,102,CURRENT_DATE(),'self',0);
                
INSERT INTO order_details
VALUES (10006,1004,10);
