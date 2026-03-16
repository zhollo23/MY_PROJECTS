--Create a database for the AR Aging 
CREATE DATABASE ARAgingDB
GO
--Activate the database
USE ARAgingDB
--View the AR Aging table
SELECT * FROM AR_Aging
--Display the share of the total AR & Share of total AR (%) for each source system. Sort from highest to lowest total AR
SELECT source_system, SUM(amount_paid) AS Total_AR, 
	   ROUND(SUM(amount_paid) * 100.0 / (SELECT SUM(amount_paid) FROM AR_Aging),2) AS Share_of_Total_AR
	   FROM AR_Aging
	   Group BY source_system
	   Order BY Total_AR DESC
--Dispaly each customer_id, due_date, and the sum of open_amount_due for each age bucket. 
--Also include a total_ar column that sums all the open_amount_due for each customer_id and due_date combination. 
--Sort by customer_id.
SELECT
    customer_id,
    due_date,
    SUM(CASE WHEN age_bucket = 'Current'      THEN open_amount_due ELSE 0 END) AS "Current",
    SUM(CASE WHEN age_bucket = '1-30 days'    THEN open_amount_due ELSE 0 END) AS "1_30_days",
    SUM(CASE WHEN age_bucket = '31-60 days'   THEN open_amount_due ELSE 0 END) AS "31_60_days",
    SUM(CASE WHEN age_bucket = '61-90 days'   THEN open_amount_due ELSE 0 END) AS "61_90_days",
    SUM(CASE WHEN age_bucket = '91-180 days'  THEN open_amount_due ELSE 0 END) AS "91_180_days",
    SUM(CASE WHEN age_bucket = '181-365 days' THEN open_amount_due ELSE 0 END) AS "181_365_days",
    SUM(open_amount_due) AS total_ar
FROM ar_aging
Group BY customer_id, due_date
ORDER BY customer_id;
