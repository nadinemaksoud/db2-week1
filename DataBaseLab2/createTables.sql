-- i added more constraints (pk and chk) to the tables and corrected the datatypes to be more professional,
-- w kmn zbtt chaklon w bs wallah

CREATE TABLE Categories(
    Category_Id     VARCHAR2(15) CONSTRAINT pk_categories PRIMARY KEY,
    Category_Name   VARCHAR2(50) NOT NULL
    );

CREATE TABLE Products(
    Product_Id      VARCHAR2(15) CONSTRAINT pk_products PRIMARY KEY,
    Product_Name    VARCHAR2(100) NOT NULL,
    Price           NUMBER(10,2) CONSTRAINT chk_product_price CHECK (Price >= 0),
    Stock           NUMBER DEFAULT 0,
    Category_Id     VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_products_category 
        FOREIGN KEY (Category_Id) REFERENCES Categories(Category_Id)
    );

CREATE TABLE Employees(
    Emp_Id          VARCHAR2(15) CONSTRAINT pk_employees PRIMARY KEY,
    Emp_Name        VARCHAR2(50) NOT NULL,
    Emp_Role        VARCHAR2(30),
    Login_Id        VARCHAR2(30) UNIQUE,
    Emp_Password    VARCHAR2(100) NOT NULL
    );

ALTER TABLE Employees ADD User_Schema VARCHAR2(30);

UPDATE Employees 
SET User_Schema = 'C##NADINE' 
WHERE Emp_Name = 'Nadine Maksoud';



CREATE TABLE Customers(
    Customer_Id     VARCHAR2(15) CONSTRAINT pk_customers PRIMARY KEY,
    Customer_Name   VARCHAR2(50) NOT NULL,
    Phone_Number    VARCHAR2(20),
    Loyalty_Points  NUMBER DEFAULT 0,
    Email           VARCHAR2(100) UNIQUE
    );

CREATE TABLE Sales(
    Sale_Id         VARCHAR2(15) CONSTRAINT pk_sales PRIMARY KEY,
    Sale_Date       DATE DEFAULT SYSDATE,
    Total_Amount    NUMBER(10,2) CONSTRAINT chk_sale_amount CHECK (Total_Amount >= 0),
    Payment_Method  VARCHAR2(30),
    Emp_Id          VARCHAR2(15) NOT NULL,
    Customer_Id     VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_sales_employee 
        FOREIGN KEY (Emp_Id) REFERENCES Employees(Emp_Id),
    CONSTRAINT fk_sales_customer 
        FOREIGN KEY (Customer_Id) REFERENCES Customers(Customer_Id)
    );

CREATE TABLE Payments (
    Payment_Id      VARCHAR2(15) CONSTRAINT pk_payments PRIMARY KEY,
    Payment_Type    VARCHAR2(30) NOT NULL,
    Amount          NUMBER(10,2) NOT NULL,
    Payment_Date    DATE,
    Sale_Id         VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_payments_sale 
        FOREIGN KEY (Sale_Id) REFERENCES Sales(Sale_Id)
);

CREATE TABLE SaleItems (
    SaleItem_Id     VARCHAR2(15) CONSTRAINT pk_saleitems PRIMARY KEY,
    Quantity        NUMBER CONSTRAINT chk_quantity CHECK (Quantity > 0),
    Price           NUMBER(10,2) NOT NULL,
    Sale_Id         VARCHAR2(15) NOT NULL,
    Product_Id      VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_saleitems_sale 
        FOREIGN KEY (Sale_Id) REFERENCES Sales(Sale_Id),
    CONSTRAINT fk_saleitems_product 
        FOREIGN KEY (Product_Id) REFERENCES Products(Product_Id)
);