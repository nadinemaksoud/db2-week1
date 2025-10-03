CREATE TABLE Categor(
    CategoryId VARCHAR2(15) NOT NULL PRIMARY KEY,
    CategoryName VARCHAR2(15)
    );
CREATE TABLE Product(
    ProductId VARCHAR2(15) NOT NULL PRIMARY KEY,
    ProductName VARCHAR2(15),
    Price INT,
    Stock INT,
    FOREIGN KEY (CategoryId) REFERENCES Categor(CategoryId)
    );
CREATE TABLE Employee(
    EmpId VARCHAR2(15) NOT NULL PRIMARY KEY,
    EmpName VARCHAR2(15) NOT NULL,
    EmpRole VARCHAR2(15),
    LoginId INT,
    EmpPassword VARCHAR2(15)
    );
CREATE TABLE Customer(
    CustomerId VARCHAR2(15) NOT NULL PRIMARY KEY,
    CustomerName VARCHAR2(15),
    phoneNumber int,
    LoyaltyPts int,
    Email VARCHAR2(15)
    );
CREATE TABLE Sales(
    SaleId VARCHAR2(15) NOT NULL PRIMARY KEY,
    DateTime date,
    TotalAmount int,
    PaymentMethod VARCHAR2(15),
    FOREIGN KEY (EmpId) REFERENCES Employee(EmpId),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
    );
CREATE TABLE Payment(
    PaymentId VARCHAR2(15) NOT NULL PRIMARY KEY,
    PaymentType VARCHAR2(15),
    Amount int,
    PayDay date,
    FOREIGN KEY (SaleId) REFERENCES Sales(SaleId)
    );
CREATE TABLE SaleItem(
    SaleItemId VARCHAR2(15) NOT NULL PRIMARY KEY,
    Quantity int,
    Price int,
    FOREIGN KEY (SaleId) REFERENCES Sales(SaleId),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
    );