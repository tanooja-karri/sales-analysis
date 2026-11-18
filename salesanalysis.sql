use data_cleaning_project;
select * from cleaned_data
-- count of rows after cleaning
select count(*) as coun from cleaned_data


-- customer count based on orders
Select count(*) as frequeny from cleaned_data 
group by user_id
 order by frequeny desc;
 
 
 
-- distinct category
select distinct category from cleaned_data


-- top 1 selling categoty top 1 sports with 184060 and electronics least 40458
select category, count(category) as count_category
 from cleaned_data
group by category


-- avg delivry and avg deliver for all category are same 3.5
select category , avg(shipping_time_days) as avg_day from cleaned_data
group by category


-- max delivet time is 6 days
select max(shipping_time_days) as max from cleaned_data


-- device type and their rating to identify which device showing better website and giving better customer experience is same 3.8 
select distinct device, avg(rating) as avg_rat from cleaned_data
group by device


-- baased on shipping date and number of returns
SELECT
    shipping_time_days,
    COUNT(*) AS total_returns
FROM cleaned_data
WHERE delivery_status = 'Returned'
GROUP BY shipping_time_days
ORDER BY shipping_time_days;


-- percetage of returnd 6 day has high return 20%
SELECT
    shipping_time_days,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN delivery_status = 'Returned' THEN 1
        ELSE 0
    END) AS total_returns,
    ROUND(
        SUM(CASE
            WHEN delivery_status = 'Returned' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS return_rate
FROM cleaned_data
GROUP BY shipping_time_days
ORDER BY shipping_time_days;

-- avg time for each location banglore and hyderabad taking 4 days for shipping
select distinct location, 
avg(shipping_time_days) as avg_shipping_location
from cleaned_data 
group by location



-- location and return  banglore hyderabad and chennai has highest return  may be shipping taking dyas
select distinct location, count(*) as total_returns 
from cleaned_data where delivery_status="returned"
group by location


 -- which location has most delays every state has high delay around 46214 and around 29% in orders are delayed
 SELECT
    location,

    SUM(CASE
        WHEN delivery_status = 'DELAYED' THEN 1
        ELSE 0
    END) AS delay,

    ROUND(
        SUM(CASE
            WHEN delivery_status = 'DELAYED' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS delay_percentage,

    COUNT(*) AS total_deliveries

FROM cleaned_data
GROUP BY location;
-- chennai, banglore, hyderbad as 12% returns
SELECT
    location,

    SUM(CASE
        WHEN delivery_status = 'returned' THEN 1
        ELSE 0
    END) AS delay,

    ROUND(
        SUM(CASE
            WHEN delivery_status = 'returned' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS return_percentage,

    COUNT(*) AS total_deliveries

FROM cleaned_data
GROUP BY location;

-- payment menthod count to provide better user expoerience
select payment_method ,count(payment_method) as cout_pay from 
cleaned_data group by payment_method


-- revenue and new customers and total records
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT user_id) AS total_customers,
    SUM(final_price) AS total_revenue,
    AVG(final_price) AS average_value,
    MIN(purchase_date) AS first_purchase,
    MAX(purchase_date) AS last_purchase
FROM cleaned_data;
  -- monthly revenue
  
  SELECT
    DATE_FORMAT(purchase_date, '%Y-%m') AS purchase_month,
    COUNT(*) AS total_orders,
    SUM(final_price) AS monthly_revenue,
    ROUND(AVG(final_price), 2) AS average_value
FROM cleaned_data
GROUP BY DATE_FORMAT(purchase_date, '%Y-%m')
ORDER BY purchase_month;

-- top 1 revenue generated category clothig has high orders compared to sports but less revenue sports has high revenue
select distinct category, sum(final_price), 
count(category) as total_orders from cleaned_data
group by category  
order by total_orders desc

-- average order value electronics has high average order value
select category, avg(final_price) as aov from cleaned_data
group by category

-- customer who buy more than one time called customer retention
SELECT
    user_id,
    COUNT(DISTINCT purchase_date) AS purchase_days
FROM cleaned_data
GROUP BY user_id
HAVING COUNT(DISTINCT purchase_date) > 1
ORDER BY purchase_days DESC;

-- 
SELECT
    CASE
        WHEN purchase_days = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT
        user_id,
        COUNT(DISTINCT purchase_date) AS purchase_days
    FROM cleaned_data
    GROUP BY user_id
) AS customer_summary
GROUP BY customer_type;

-- top 10 repeated customers
SELECT
    user_id,
    total_orders,
    RANK() OVER(ORDER BY total_orders DESC) AS customer_rank
FROM (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM cleaned_data
    GROUP BY user_id
) AS customer_orders
LIMIT 10;
 -- 519094	191135	36.82% are have retention
 SELECT
    COUNT(*) AS total_customers,

    SUM(CASE
        WHEN total_orders > 1 THEN 1
        ELSE 0
    END) AS repeat_customers,

    ROUND(
        SUM(CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS repeat_customer_percentage

FROM (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM cleaned_data
    GROUP BY user_id
) AS customer_summary;



WITH customer_orders AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM cleaned_data
    GROUP BY user_id
),

customer_type AS (
    SELECT
        user_id,
        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_group
    FROM customer_orders
)
SELECT
    ct.customer_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(cd.shipping_time_days), 2) AS avg_shipping_days,
    MAX(cd.shipping_time_days) AS max_shipping_days

FROM cleaned_data cd
JOIN customer_type ct
    ON cd.user_id = ct.user_id

GROUP BY ct.customer_group;    



WITH customer_orders AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM cleaned_data
    GROUP BY user_id
),

customer_type AS (
    SELECT
        user_id,
        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_group
    FROM customer_orders
)

SELECT
    ct.customer_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(cd.rating), 2) AS average_rating,
    SUM(CASE
        WHEN cd.rating <= 2 THEN 1
        ELSE 0
    END) AS low_rated_orders

FROM cleaned_data cd
JOIN customer_type ct
    ON cd.user_id = ct.user_id

GROUP BY ct.customer_group;


--
WITH customer_orders AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM cleaned_data
    GROUP BY user_id
),

customer_type AS (
    SELECT
        user_id,
        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_group
    FROM customer_orders
)

SELECT
    ct.customer_group,
    COUNT(*) AS total_orders,

    SUM(CASE
        WHEN cd.delivery_status = 'Returned' THEN 1
        ELSE 0
    END) AS total_returns,

    ROUND(
        SUM(CASE
            WHEN cd.delivery_status = 'Returned' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS return_percentage

FROM cleaned_data cd
JOIN customer_type ct
    ON cd.user_id = ct.user_id

GROUP BY ct.customer_group;


