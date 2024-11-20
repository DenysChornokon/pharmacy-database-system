-- Active: 1731167437977@@127.0.0.1@5432@pharmacy
-- //Визначити групу препаратів, яких є найбільше в аптеці
SELECT
    CASE
        WHEN Requires_prescription THEN 'Рецептурні'
        ELSE 'Безрецептурні'
    END AS DrugGroup,
    SUM(Total_amount) AS TotalQuantity
FROM Drug
GROUP BY
    Requires_prescription
ORDER BY TotalQuantity DESC
LIMIT 1;

-- //Середня вартість замовлення по кожному клієнту за останні 6 місяців
SELECT c.Full_name, AVG(o.Total_cost) AS AvgOrderCost
FROM "Order" o
    JOIN Client c ON o.Client_ID = c.ID
WHERE
    o.Order_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY
    c.Full_name;

--// Дата найдорожчого замовлення для кожного клієнта  
SELECT c.Full_name, o.Order_date, o.Total_cost
FROM "Order" o
    JOIN Client c ON o.Client_ID = c.ID
WHERE (o.Client_ID, o.Total_cost) IN (
        SELECT Client_ID, MAX(Total_cost)
        FROM "Order"
        GROUP BY
            Client_ID
    );

-- //ТОР 15 препаратів, які купують найчастіше
SELECT d.Name, SUM(od.Quantity) AS TotalQuantity
FROM Order_Drug od
    JOIN Drug d ON od.Drug_ID = d.ID
GROUP BY
    d.Name
ORDER BY TotalQuantity DESC
LIMIT 15;

-- Перелік замовлень за минулий тиждень з препаратами певної групи --! Відсутні дані
SELECT o.ID AS OrderID, o.Order_date, c.Full_name, d.Name AS DrugName, od.Quantity
FROM
    "Order" o
    JOIN Order_Drug od ON o.ID = od.Order_ID
    JOIN Drug d ON od.Drug_ID = d.ID
    JOIN Client c ON o.Client_ID = c.ID
WHERE
    o.Order_date >= CURRENT_DATE - INTERVAL '1 week'
    AND d.Requires_prescription = true;


-- //Клієнти з найбільшою кількістю замовлень та найбільшими сумами замовлень
SELECT c.Full_name, COUNT(o.ID) AS TotalOrders, SUM(o.Total_cost) AS TotalSpent
FROM "Order" o
    JOIN Client c ON o.Client_ID = c.ID
GROUP BY
    c.Full_name
ORDER BY TotalOrders DESC, TotalSpent DESC
LIMIT 3;

SELECT * from Client

SELECT * from "Order"

SELECT * from discount

select * from prescription where client_id = 5