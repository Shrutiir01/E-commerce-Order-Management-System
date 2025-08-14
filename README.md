# E-commerce-Order-Management-System
This project is a backend implementation of a simplified e-commerce platform using SQL and PL/SQL in Oracle. It manages core operations such as customer registration, products management, shopping cart handling, order placement, and sales reporting. The database schema is designed with multiple tables — customers, products, cart, orders, and order_items — linked through primary and foreign key constraints to maintain referential integrity.

Business rules such as stock validation, cart total calculation, and automatic inventory updates are implemented using triggers, functions, and stored procedures. The system allows adding products to the cart only if sufficient stock is available, processes orders by transferring cart items to the order list, reduces inventory accordingly, and generates sales reports for any given month and year.

The project demonstrates the use of PL/SQL programming constructs like loops, cursors, and exception handling, along with SQL joins for relational queries. It serves as a complete example of designing and implementing a transactional database system for e-commerce.
