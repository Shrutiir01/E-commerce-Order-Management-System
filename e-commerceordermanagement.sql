--E-commerce order management system

--Table Creation
----Customers
CREATE TABLE customerse
(customer_id   NUMBER PRIMARY KEY
,customer_name VARCHAR2(50) UNIQUE
,email         VARCHAR2(100)
,password      VARCHAR2(100)
);

----Products                      
CREATE TABLE productse
(product_id   NUMBER PRIMARY KEY
,product_name VARCHAR2(100)
,price        NUMBER(10,2)
,stock        NUMBER
);

----Cart                  
CREATE TABLE carte
(cart_id     NUMBER PRIMARY KEY
,customer_id NUMBER
,product_id  NUMBER
,quantity    NUMBER
,CONSTRAINTS carte_customer_id_fk FOREIGN KEY(customer_id)
                                  REFERENCES customerse(customer_id)
,CONSTRAINTS carte_product_id_fk  FOREIGN KEY(product_id)
                                  REFERENCES productse(product_id)
);

----Orders
CREATE TABLE orderse
(order_id     NUMBER PRIMARY KEY
,customer_id  NUMBER
,order_date   DATE
,total_amount NUMBER
,CONSTRAINTS orderse_customer_id_fk FOREIGN KEY(customer_id)
                                    REFERENCES customerse(customer_id)
);

----Order_items
CREATE TABLE order_itemse
(item_id    NUMBER PRIMARY KEY
,order_id   NUMBER
,product_id NUMBER
,quantity   NUMBER
,price      NUMBER
,CONSTRAINTS order_itemse_order_id_fk FOREIGN KEY(order_id)
                                      REFERENCES orderse(order_id)                  
);

