SHOW DATABASES;

CREATE DATABASE Task2;

use Task2;

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department_id INT,
    salary DECIMAL(10, 2),
    hire_date DATE
);

INSERT INTO Employees VALUES
(1, 'Alice', 1, 60000, '2015-06-01'),
(2, 'Bob', 2, 55000, '2016-07-15'),
(3, 'Charlie', 1, 75000, '2014-09-20'),
(4, 'David', 3, 50000, '2018-03-12'),
(5, 'Eve', 2, 70000, '2015-11-30'),
(6, 'Frank', 3, 62000, '2019-01-10'),
(7, 'Grace', 1, 58000, '2020-05-21'),
(8, 'Hank', 2, 72000, '2017-03-18'),
(9, 'Ivy', 3, 68000, '2016-10-02'),
(10, 'Jack', 1, 77000, '2014-02-15');

SELECT*FROM Employees;

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    salesperson_id INT,
    sale_date DATE,
    amount DECIMAL(10, 2)
);

INSERT INTO Sales VALUES
(1, 1, '2023-01-10', 5000),
(2, 1, '2023-01-15', 3000),
(3, 2, '2023-02-05', 4000),
(4, 3, '2023-03-12', 2500),
(5, 2, '2023-03-18', 4500),
(6, 4, '2023-04-10', 6000),
(7, 5, '2023-04-15', 7000),
(8, 6, '2023-05-20', 8000),
(9, 7, '2023-06-25', 5500),
(10, 8, '2023-07-05', 6500);

SELECT*FROM Sales;

CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

INSERT INTO Departments VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Marketing'),
(5, 'Operations');

SELECT*FROM Departments;

SELECT 
    e.employee_id,
    e.name,
    e.department_id,
    d.department_name,
    e.salary,
    RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank,
    SUM(e.salary) OVER (PARTITION BY e.department_id) AS total_department_salary
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id;   

SELECT e.employee_id, e.name, e.salary, d.department_name
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(salary)
    FROM Employees
    WHERE department_id = e.department_id
);


WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(sale_date, '%Y-%m-01') AS sale_month, 
        SUM(amount) AS total_revenue
    FROM Sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m-01')
),
RankedSales AS (
    SELECT 
        sale_month,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM MonthlySales
)
SELECT * FROM RankedSales;

WITH MonthlyPerformance AS (
    SELECT 
        salesperson_id,
        DATE_FORMAT(sale_date, '%Y-%m-01') AS sale_month, 
        SUM(amount) AS total_sales
    FROM Sales
    GROUP BY salesperson_id, DATE_FORMAT(sale_date, '%Y-%m-01')
),
RankedPerformance AS (
    SELECT 
        salesperson_id,
        sale_month,
        total_sales,
        RANK() OVER (PARTITION BY sale_month ORDER BY total_sales DESC) AS sales_rank
    FROM MonthlyPerformance
)
SELECT salesperson_id, sale_month, total_sales
FROM RankedPerformance
WHERE sales_rank = 1;

