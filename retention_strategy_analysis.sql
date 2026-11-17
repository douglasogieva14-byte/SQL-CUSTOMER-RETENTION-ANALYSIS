-- 1. Create the Portfolio Database
CREATE DATABASE IF NOT EXISTS retention_strategy_db;
USE retention_strategy_db;

-- 2. Create the Customers Dimension Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(50),
    segment VARCHAR(50),
    account_status VARCHAR(20)
);

-- 3. Create the Transactions Fact Table
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    amount DECIMAL(10,2),
    fee_charged DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Seed Mock Data for Customers
INSERT INTO customers (customer_id, signup_date, country, segment, account_status) VALUES
(1001, '2025-01-15', 'United Kingdom', 'Enterprise', 'Active'),
(1002, '2025-01-20', 'Singapore', 'Retail', 'Active'),
(1003, '2025-02-02', 'United Arab Emirates', 'Premium', 'Churned'),
(1004, '2025-03-12', 'United Kingdom', 'Retail', 'Active'),
(1005, '2025-04-01', 'Singapore', 'Enterprise', 'Churned'),
(1006, '2025-05-19', 'United Arab Emirates', 'Retail', 'Active'),
(1007, '2025-06-22', 'United Kingdom', 'Premium', 'Active'),
(1008, '2025-07-05', 'Singapore', 'Premium', 'Active'),
(1009, '2025-08-11', 'United Arab Emirates', 'Enterprise', 'Active'),
(1010, '2025-09-01', 'United Kingdom', 'Retail', 'Churned');

-- 5. Seed Mock Data for Transactions (Simulating historical activity)
INSERT INTO transactions (customer_id, transaction_date, amount, fee_charged) VALUES
(1001, '2025-01-16', 5000.00, 50.00),
(1001, '2025-06-20', 7500.00, 75.00),
(1002, '2025-01-22', 150.00, 4.50),
(1002, '2025-10-05', 300.00, 9.00),
(1003, '2025-02-03', 1200.00, 24.00), -- No transactions after Feb (Churned)
(1004, '2025-03-15', 80.00, 2.40),
(1004, '2025-11-01', 95.00, 2.85),
(1005, '2025-04-02', 12000.00, 120.00), -- No transactions after April (Churned)
(1006, '2025-05-20', 450.00, 13.50),
(1006, '2025-08-14', 600.00, 18.00),
(1007, '2025-06-25', 2500.00, 50.00),
(1007, '2025-12-15', 3100.00, 62.00),
(1008, '2025-07-06', 1800.00, 36.00),
(1009, '2025-08-12', 15000.00, 150.00),
(1009, '2025-11-20', 8500.00, 85.00),
(1010, '2025-09-02', 50.00, 1.50); -- No transactions after Sept (Churned)









-- Strategic Query: Identifying High-Value Revenue At Risk
SELECT 
    c.customer_id,
    c.country,
    c.segment,
    c.account_status,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_lifetime_volume,
    SUM(t.fee_charged) AS total_fees_earned,
    MAX(t.transaction_date) AS date_of_last_transaction,
    -- Calculate days of inactivity relative to end of year 2025
    DATEDIFF('2025-12-31', MAX(t.transaction_date)) AS days_since_last_activity,
    -- Flagging high value churn risks using conditional logic
    CASE 
        WHEN DATEDIFF('2025-12-31', MAX(t.transaction_date)) > 120 AND c.account_status = 'Active' THEN 'CRITICAL CHURN RISK'
        WHEN DATEDIFF('2025-12-31', MAX(t.transaction_date)) BETWEEN 60 AND 120 AND c.account_status = 'Active' THEN 'Medium Risk Warning'
        ELSE 'Healthy / Actioned'
    END AS strategic_status
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.country, c.segment, c.account_status
ORDER BY total_fees_earned DESC;
