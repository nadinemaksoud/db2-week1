-- in the plugeable

CREATE OR REPLACE VIEW system.vw_sales_summary AS
SELECT s.Sale_Id, s.Sale_Date, e.Emp_Name AS Employee, c.Customer_Name AS Customer, s.Total_Amount, s.Payment_Method, COUNT(si.SaleItem_Id) AS Total_Items, SUM(si.Quantity * si.Price) AS Calculated_Total
FROM Sales s
JOIN Employees e ON s.Emp_Id = e.Emp_Id
JOIN Customers c ON s.Customer_Id = c.Customer_Id
JOIN SaleItems si ON s.Sale_Id = si.Sale_Id
GROUP BY s.Sale_Id, s.Sale_Date, e.Emp_Name, c.Customer_Name, s.Total_Amount, s.Payment_Method
ORDER BY s.Sale_Date DESC;

CREATE OR REPLACE VIEW system.vw_sale_detail AS
SELECT s.Sale_Id, s.Sale_Date, e.Emp_Name AS Employee, c.Customer_Name AS Customer, p.Product_Name, si.Quantity, si.Price, (si.Quantity * si.Price) AS Line_Total, s.Total_Amount, s.Payment_Method
FROM Sales s
JOIN Employees e ON s.Emp_Id = e.Emp_Id
JOIN Customers c ON s.Customer_Id = c.Customer_Id
JOIN SaleItems si ON s.Sale_Id = si.Sale_Id
JOIN Products p ON si.Product_Id = p.Product_Id
ORDER BY s.Sale_Date DESC, s.Sale_Id
WITH CHECK OPTION;

CREATE OR REPLACE VIEW system.vw_current_menu_with_category AS
SELECT p.Product_Id, p.Product_Name, p.Price, p.Stock, c.Category_Name
FROM Products p
JOIN Categories c ON p.Category_Id = c.Category_Id
ORDER BY c.Category_Name, p.Product_Name;

CREATE OR REPLACE VIEW system.vw_employee_performance AS
SELECT e.Emp_Id, e.Emp_Name, COUNT(s.Sale_Id) AS Total_Sales, SUM(s.Total_Amount) AS Total_Revenue
FROM Employees e
LEFT JOIN Sales s ON e.Emp_Id = s.Emp_Id
GROUP BY e.Emp_Id, e.Emp_Name
ORDER BY Total_Revenue DESC
WITH READ ONLY;

CREATE OR REPLACE VIEW system.vw_employee_roles AS
SELECT Emp_Id, Emp_Name, Emp_Role, Login_Id
FROM Employees
ORDER BY Emp_Role, Emp_Name;

CREATE OR REPLACE VIEW system.vw_top_selling_products AS
SELECT p.Product_Id, p.Product_Name, c.Category_Name, SUM(si.Quantity) AS Total_Quantity_Sold, SUM(si.Quantity * si.Price) AS Total_Revenue
FROM SaleItems si
JOIN Products p ON si.Product_Id = p.Product_Id
JOIN Categories c ON p.Category_Id = c.Category_Id
GROUP BY p.Product_Id, p.Product_Name, c.Category_Name
ORDER BY Total_Quantity_Sold DESC;

CREATE OR REPLACE VIEW system.vw_low_stock_alerts AS
SELECT p.Product_Id, p.Product_Name, p.Stock, c.Category_Name
FROM Products p
JOIN Categories c ON p.Category_Id = c.Category_Id
WHERE p.Stock <= 5
ORDER BY p.Stock ASC;

CREATE OR REPLACE VIEW system.vw_payment_breakdown AS
SELECT s.Payment_Method, COUNT(s.Sale_Id) AS Total_Sales, SUM(s.Total_Amount) AS Total_Amount
FROM Sales s
GROUP BY s.Payment_Method
ORDER BY Total_Amount DESC;

CREATE OR REPLACE VIEW system.vw_loyalty_summary AS
SELECT c.Customer_Id, c.Customer_Name, c.Loyalty_Points, SUM(s.Total_Amount) AS Total_Spent, COUNT(s.Sale_Id) AS Total_Purchases
FROM Customers c
LEFT JOIN Sales s ON c.Customer_Id = s.Customer_Id
GROUP BY c.Customer_Id, c.Customer_Name, c.Loyalty_Points
ORDER BY Total_Spent DESC;

CREATE OR REPLACE VIEW system.vw_daily_revenue AS
SELECT TRUNC(Sale_Date) AS Sale_Day, COUNT(Sale_Id) AS Total_Sales, SUM(Total_Amount) AS Total_Revenue
FROM Sales
GROUP BY TRUNC(Sale_Date)
ORDER BY Sale_Day DESC;

CREATE OR REPLACE VIEW system.vw_category_performance AS
SELECT c.Category_Id, c.Category_Name, COUNT(si.SaleItem_Id) AS Total_Items_Sold, SUM(si.Quantity * si.Price) AS Total_Revenue
FROM SaleItems si
JOIN Products p ON si.Product_Id = p.Product_Id
JOIN Categories c ON p.Category_Id = c.Category_Id
GROUP BY c.Category_Id, c.Category_Name
ORDER BY Total_Revenue DESC;

CREATE OR REPLACE VIEW system.vw_monthly_growth AS
SELECT TO_CHAR(Sale_Date, 'YYYY-MM') AS Sale_Month, COUNT(Sale_Id) AS Total_Sales, SUM(Total_Amount) AS Total_Revenue
FROM Sales
GROUP BY TO_CHAR(Sale_Date, 'YYYY-MM')
ORDER BY Sale_Month;

CREATE OR REPLACE VIEW system.vw_customer_activity AS
SELECT c.Customer_Id, c.Customer_Name, COUNT(s.Sale_Id) AS Total_Purchases, SUM(s.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Sales s ON c.Customer_Id = s.Customer_Id
GROUP BY c.Customer_Id, c.Customer_Name
ORDER BY Total_Purchases DESC;

GRANT SELECT ON system.vw_sales_summary TO C##POS_MANAGER;
GRANT SELECT ON system.vw_sales_summary TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_sale_detail TO C##POS_MANAGER;
GRANT SELECT ON system.vw_sale_detail TO C##POS_CASHIER;
GRANT SELECT ON system.vw_current_menu_with_category TO C##POS_CASHIER;
GRANT SELECT ON system.vw_current_menu_with_category TO C##POS_WAITER;
GRANT SELECT ON system.vw_employee_performance TO C##POS_MANAGER;
GRANT SELECT ON system.vw_employee_performance TO C##POS_HR;
GRANT SELECT ON system.vw_employee_roles TO C##POS_MANAGER;
GRANT SELECT ON system.vw_employee_roles TO C##POS_HR;
GRANT SELECT ON system.vw_top_selling_products TO C##POS_MANAGER;
GRANT SELECT ON system.vw_top_selling_products TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_low_stock_alerts TO C##POS_INVENTORY;
GRANT SELECT ON system.vw_payment_breakdown TO C##POS_MANAGER;
GRANT SELECT ON system.vw_payment_breakdown TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_loyalty_summary TO C##POS_MANAGER;
GRANT SELECT ON system.vw_loyalty_summary TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_daily_revenue TO C##POS_MANAGER;
GRANT SELECT ON system.vw_daily_revenue TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_category_performance TO C##POS_MANAGER;
GRANT SELECT ON system.vw_category_performance TO C##POS_ASSISTANTMANAGER;
GRANT SELECT ON system.vw_monthly_growth TO C##POS_MANAGER;
GRANT SELECT ON system.vw_customer_activity TO C##POS_MANAGER;