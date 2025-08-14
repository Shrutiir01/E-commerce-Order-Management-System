--E-commerce order management system

--1.Table Creation
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



--2.Insertion
-- Insert customers
INSERT INTO customerse(customer_id
                      ,customer_name
                      ,email
                      ,password
                      )                    
VALUES                (1
                      ,'shruti'
                      ,'shruti@gmail.com'
                      ,'password123'
                      );
                      

INSERT INTO customerse(customer_id
                      ,customer_name
                      ,email
                      ,password
                      )                    
VALUES                (2
                      ,'trupti'
                      ,'trupti@gmail.com'
                      ,'password321'
                      );
                      

INSERT INTO customerse(customer_id
                      ,customer_name
                      ,email
                      ,password
                      )                    
VALUES                (3
                      ,'aryan'
                      ,'aryan@gmail.com'
                      ,'password100'
                      );


INSERT INTO customerse(customer_id
                      ,customer_name
                      ,email
                      ,password
                      )                    
VALUES                (4
                      ,'suyash'
                      ,'suyash@gmail.com'
                      ,'pass123'
                      );

-- Insert products
INSERT INTO productse(product_id
                     ,product_name
                     ,price
                     ,stock
                     )
VALUES               (101
                     ,'Laptop'
                     ,50000
                     ,10
                     );
                     
INSERT INTO productse(product_id
                     ,product_name
                     ,price
                     ,stock
                     )
VALUES               (102
                     ,'Phone'
                     ,20000
                     ,20
                     );

--Insert an orders
INSERT INTO orderse(order_id
                   ,customer_id
                   ,order_date
                   ,total_amount
                   )
VALUES             (1001
                   ,1
                   ,SYSDATE
                   ,70000
                   );

--Insert order items

INSERT INTO order_itemse(item_id
                        ,order_id
                        ,product_id
                        ,quantity
                        ,price
                        )
VALUES                  (1
                        ,1001
                        ,101
                        ,1
                        ,50000
                        );
                        
INSERT INTO order_itemse(item_id
                        ,order_id
                        ,product_id
                        ,quantity
                        ,price
                        )
VALUES                  (2
                        ,1001
                        ,102
                        ,1
                        ,20000
                        );
                        
                        
                        
-- View all orders with user info
-----Using Join
SELECT o.order_id, u.customer_name, o.total_amount
FROM orderse o
JOIN customerse u ON o.customer_id = u.customer_id;

-- View products in a specific order
SELECT oi.order_id, p.product_name, oi.quantity, oi.price
FROM order_itemse oi
JOIN productse p ON oi.product_id = p.product_id
WHERE oi.order_id = 1001;

----Trigger: Check Stock Before Adding to Cart

CREATE OR REPLACE TRIGGER trg_check_stock
BEFORE INSERT OR UPDATE ON carte
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock
    INTO   v_stock 
    FROM   productse 
    WHERE  product_id = :NEW.product_id
    ;
    IF v_stock < :NEW.quantity
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Not enough stock available.');
    END IF;
END;


----- Function: Get Cart Total

CREATE OR REPLACE FUNCTION get_cart_total(p_customer_id NUMBER)
RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT SUM(p.price * c.quantity)
    INTO v_total
    FROM carte c
    JOIN productse p ON c.product_id = p.product_id
    WHERE c.customer_id = p_customer_id;

    RETURN NVL(v_total, 0);
END;


----Procedure: Monthly Sales Report
CREATE OR REPLACE PROCEDURE monthly_sales_report(p_month NUMBER, p_year NUMBER) IS
BEGIN
    FOR rec IN (
        SELECT o.order_id, u.customer_name, o.total_amount, o.order_date
        FROM orderse o
        JOIN customerse u ON o.customer_id = u.customer_id
        WHERE EXTRACT(MONTH FROM o.order_date) = p_month
        AND EXTRACT(YEAR FROM o.order_date) = p_year
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Order ID : ' || rec.order_id ||
                             ' | Customer : ' || rec.customer_name ||
                             ' | Amount : ' || rec.total_amount ||
                             ' | Date : ' || rec.order_date);
    END LOOP;
END;


----Procedure: Place Order

CREATE OR REPLACE PROCEDURE place_order(p_customer_id NUMBER) IS
    v_order_id NUMBER;
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(MAX(order_id), 0) + 1 INTO v_order_id FROM orderse;

    INSERT INTO orderse(order_id, customer_id, order_date, total_amount)
    VALUES(v_order_id, p_customer_id, SYSDATE, 0);

    FOR rec IN (
        SELECT c.product_id, c.quantity, p.price
        FROM carte c
        JOIN productse p ON c.product_id = p.product_id
        WHERE c.customer_id = p_customer_id
    ) LOOP
        INSERT INTO order_itemse(item_id, order_id, product_id, quantity, price)
        VALUES(NVL((SELECT MAX(item_id) FROM order_itemse), 0) + 1,
               v_order_id, rec.product_id, rec.quantity, rec.price);

        UPDATE productse
        SET stock = stock - rec.quantity
        WHERE product_id = rec.product_id;

        v_total := v_total + (rec.price * rec.quantity);
    END LOOP;

    UPDATE orderse
    SET total_amount = v_total
    WHERE order_id = v_order_id;

    DELETE FROM carte WHERE customer_id = p_customer_id;

    DBMS_OUTPUT.PUT_LINE('Order placed successfully! Order ID: ' || v_order_id);
END;


----Testing the Flow
-- Add to cart
INSERT INTO carte VALUES (1, 1, 101, 1); -- 1 Laptop
INSERT INTO carte VALUES (2, 1, 102, 1); -- 1 Mobile

-- Check cart total
SELECT get_cart_total(1) AS total FROM dual;

-- Place order
BEGIN
    place_order(2);
END;


-- View orders
SELECT * FROM orders;
SELECT * FROM order_items;

-- Generate sales report for August 2025
BEGIN
    monthly_sales_report(8, 2025);
END;























