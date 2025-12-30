/*-----------------------------------------------------------
Project: Blinkit Sales Data Analysis
Database: PostgreSQL
Analyst: Lalitha
------------------------------------------------------------
Step 1: Create the main table structure to store sales data.
------------------------------------------------------------
Objective:
To define a schema for storing detailed sales information 
of Blinkit items across multiple outlets.

Table Name: sales_data

Columns:
- item_fat_content:     Describes whether the item is 'Low Fat' or 'Regular'
- item_identifier:      Unique product code for each item
- item_type:            Category or type of the item (e.g., Dairy, Snacks)
- outlet_establishment_year: Year in which the outlet was established
- outlet_identifier:    Unique code for each outlet
- outlet_location_type: Tier or region (e.g., Tier 1, Tier 2, Tier 3)
- outlet_size:          Size category of the outlet (Small/Medium/Large)
- outlet_type:          Type of outlet (Supermarket, Grocery Store, etc.)
- item_visibility:      Proportion of shelf area allocated to the item
- item_weight:          Weight of the product
- total_sales:          Total sales value for that item
- rating:               Customer rating of the item
-----------------------------------------------------------*/

CREATE TABLE sales_data (
  item_fat_content VARCHAR(50),
  item_identifier VARCHAR(50),
  item_type VARCHAR(100),
  outlet_establishment_year INT,
  outlet_identifier VARCHAR(50),
  outlet_location_type VARCHAR(50),
  outlet_size VARCHAR(50),
  outlet_type VARCHAR(100),
  item_visibility NUMERIC,
  item_weight NUMERIC,
  total_sales NUMERIC,
  rating NUMERIC
);

/*------------------------------------------------------------
Step 2:
Import the dataset into the sales_data table 
to begin exploratory data analysis.
------------------------------------------------------------*/

--See all the data imported into sales_data table
SELECT * FROM sales_data;

/*------------------------------------------------------------
Step 3: Data Cleaning – Standardize Item_Fat_Content
------------------------------------------------------------
Objective:
To ensure data consistency and accuracy in analysis by 
standardizing inconsistent category values in the 
`item_fat_content` column.

Reason:
The dataset contains multiple variations representing 
the same category (e.g., 'LF', 'low fat', 'Low Fat', 'reg', 'Regular').
Such variations can lead to incorrect grouping, aggregation, 
and filtering during analysis.

Logic:
- Replace 'LF' and 'low fat' with 'Low Fat'
- Replace 'reg' with 'Regular'
- Keep all other values unchanged

This improves data quality and ensures uniform reporting 
in subsequent analyses.
------------------------------------------------------------*/

UPDATE sales_data SET
item_fat_content=
CASE 
WHEN item_fat_content IN('LF','low fat')  THEN 'Low Fat'
WHEN item_fat_content ='reg'  THEN 'Regular'
ELSE item_fat_content
END;

SELECT DISTINCT(item_fat_content)
FROM sales_data;

--Step 4 KPIs
--1. TOTAL SALES:
SELECT SUM(total_Sales) FROM sales_data;

-- TOTAL SALES IN MILLIONS:
SELECT CAST(SUM(total_Sales)/1000000 AS DECIMAL(10,2))as Total_sales_in_Millions FROM sales_data;

/*Insight:
The total sales across all outlets amount to approximately ₹1.20 million, 
giving a quick and concise view of the overall business performance.
*/


--2. AVERAGE SALES
SELECT AVG(total_Sales) AS Avg_sales FROM sales_data;
/*------------------------------------------------------------
 Calculate Average Sales
------------------------------------------------------------
Objective:
To find the average (mean) sales value across all records 
in the dataset, providing a benchmark for typical sales performance.

Logic:
1. Use the aggregate function AVG() on the `total_sales` column.
2. Apply CAST() to format the result to two decimal places.
3. The result represents the average sales per item (or record).

------------------------------------------------------------*/
SELECT CAST(AVG(total_Sales) AS DECIMAL(10,2)) AS Avg_sales FROM sales_data;

/*------------------------------------------------------------
Insight:
- The average sales value = ₹140.99.
- Comparing this with total sales by item type or outlet type 
  can help identify above-average and below-average performers.
- Outlets or items with significantly higher-than-average sales 
  might represent best-selling categories, while lower ones 
  may need promotional focus.

------------------------------------------------------------*/

/*------------------------------------------------------------
 Count the Number of Items
------------------------------------------------------------
Objective:
To determine the total number of records (items) present 
in the dataset. This helps validate the completeness 
of the imported data and understand the dataset’s scale.

Logic:
1. Use COUNT(*) to count all rows in the `sales_data` table.
2. Each row represents one product-outlet combination record.


------------------------------------------------------------*/

--3. NO OF ITEMS
SELECT COUNT(*) FROM sales_Data;
/*------------------------------------------------------------
Insight:
- The dataset contains 8,523 records.
- This means there are 8,523 unique item–outlet entries captured.
- Knowing the total number of records is important for:
   - Ensuring data was fully imported (no missing rows).
   - Understanding the dataset size before performing 
     groupings, joins, or aggregations.
   - Estimating computation time for large queries.
------------------------------------------------------------*/

/*------------------------------------------------------------
Calculate Average Rating
--------------------------------------------------------------
Objective:
To determine the average customer rating across all products and outlets.
This helps assess the overall satisfaction level with products sold.

Logic:
1. Use AVG(rating) to calculate the mean rating value from the `rating` column.
2. Apply CAST() to round it to 0 decimal places for a clean, whole-number display.
3. This value represents the general customer feedback trend.

------------------------------------------------------------*/
--4. AVERAGE RATING
SELECT CAST(AVG(rating)AS DECIMAL(10,0)) FROM sales_data;

/*------------------------------------------------------------
Result: Avg_rating = 4
Insight:
- The overall average rating is **4 out of 5**, indicating strong 
  customer satisfaction across the dataset.
- This suggests that most items are performing well in quality and value.
- A rating near 4 typically reflects a positive perception among buyers, 
  but further analysis by outlet type or item type can reveal 
  which segments have higher or lower satisfaction levels.

------------------------------------------------------------*/

/*------------------------------------------------------------
 Total Sales by Item Fat Content
------------------------------------------------------------
Objective:
To analyze how total sales vary by the fat content category of items 
(e.g., "Low Fat" vs. "Regular"). 
This helps understand customer preferences and purchasing behavior 
based on product type.

Logic:
1. Group data by `item_fat_content`.
2. Use SUM(total_sales) to calculate total revenue per category.
3. Format results to two decimal places for clarity.
4. Compare which category contributes more to overall sales.

------------------------------------------------------------*/
-- 5.Total Sales by Item Fat Content
SELECT item_fat_content, CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales
FROM sales_data
GROUP BY item_fat_content;

/*------------------------------------------------------------
 Result:
| item_fat_content | total_sales |
|------------------|-------------|
| Regular          | 425361.80   |
| Low Fat          | 776319.68   |

 Insight:
- Items labeled as **"Low Fat"** generated higher total sales 
  (**₹776,319.68**) compared to **"Regular"** items (**₹425,361.80**).
- This indicates a stronger consumer preference toward 
  low-fat or health-conscious products.
- Marketing and inventory strategies can focus more on 
  expanding low-fat product lines to boost revenue.
- However, the significant sales share of regular items 
  also shows they remain a substantial market segment.

------------------------------------------------------------*/

/*------------------------------------------------------------
 Total Sales by Item Type
------------------------------------------------------------
Objective:
To identify which item categories contribute the most to total sales.
This analysis helps understand customer purchasing preferences and 
high-performing product segments.

Logic:
1. Group the dataset by `item_type`.
2. Use SUM(total_sales) to compute total revenue for each item category.
3. Format the result to 2 decimal places for readability.
4. Sort results in descending order to highlight top-selling categories.

------------------------------------------------------------*/
--6. Total Sales by Item Type
SELECT item_type, CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales
FROM sales_data
GROUP BY item_type
ORDER BY total_sales DESC

/*------------------------------------------------------------
✅ Result:
| item_type            | total_sales  |
|----------------------|--------------|
| Fruits and Vegetables| 178124.08    |
| Snack Foods          | 175433.92    |
| Household            | 135976.53    |
| Frozen Foods         | 118558.88    |
| Dairy                | 101276.46    |
| Canned               | 90706.73     |
| Baking Goods         | 81894.74     |
| Health and Hygiene   | 68025.84     |
| Meat                 | 59449.86     |
| Soft Drinks          | 58514.17     |
| Breads               | 35379.12     |
| Hard Drinks          | 29334.68     |
| Others               | 22451.89     |
| Starchy Foods        | 21880.03     |
| Breakfast            | 15596.70     |
| Seafood              | 9077.87      |

 Insight:
- **Fruits and Vegetables** (₹178,124.08) and **Snack Foods** (₹175,433.92) 
  are the **top revenue-generating categories**, showing strong consumer demand.
- **Household**, **Frozen Foods**, and **Dairy** also perform consistently well.
- **Seafood** and **Breakfast items** show the lowest sales, indicating 
  either low inventory, lower demand, or niche customer segments.
- These insights can guide inventory planning, marketing campaigns, 
  and shelf space optimization in retail outlets.

------------------------------------------------------------*/

/*------------------------------------------------------------
Total Sales for Item Fat Content by Outlet Location Type
------------------------------------------------------------
Objective:
To analyze how sales for each fat content category ('Low Fat' and 'Regular') 
are distributed across different outlet location tiers (Tier 1, Tier 2, Tier 3).  
This provides insights into consumer preferences by region or market type.

Logic:
1. Group data by `outlet_location_type`.
2. Use conditional aggregation with CASE WHEN to separately sum 
   `total_sales` for each fat content category.
3. Use COALESCE() to handle NULL values (replace with 0 if no sales).
4. Order results by `outlet_location_type` for a structured output.

------------------------------------------------------------*/
--7.  Total Sales for Item Fat Content by Outlet Location Type
SELECT 
    outlet_location_type,
    COALESCE(SUM(CASE WHEN item_fat_content = 'Low Fat' THEN total_sales END), 0) AS Low_Fat,
    COALESCE(SUM(CASE WHEN item_fat_content = 'Regular' THEN total_sales END), 0) AS Regular
FROM sales_data
GROUP BY outlet_location_type
ORDER BY outlet_location_type;

/*------------------------------------------------------------
 Result:
| outlet_location_type | Low_Fat     | Regular     |
|-----------------------|-------------|-------------|
| Tier 1               | 215047.91    | 121349.90   |
| Tier 2               | 254464.77    | 138685.87   |
| Tier 3               | 306806.99    | 165326.03   |

 Insight:
- **Tier 3 outlets** recorded the highest sales across both fat categories, 
  with total low-fat sales of ₹306,806.99 and regular sales of ₹165,326.03.
- This suggests Tier 3 outlets (likely in highly populated or urban areas) 
  have greater sales volume and consumer reach.
- **Low Fat items consistently outperform Regular items** across all tiers, 
  showing a clear consumer preference toward healthier options.
- This insight can guide marketing and stocking decisions per location type 
  — for example, stocking more low-fat items in Tier 3 outlets to maximize profit.

------------------------------------------------------------*/
/*------------------------------------------------------------
 Total Sales by Outlet Establishment Year
------------------------------------------------------------
Objective:
To analyze how total sales vary based on the year in which the outlet 
was established. This helps identify whether older or newer outlets 
generate more revenue and can reflect maturity, brand presence, or 
market penetration over time.

Logic:
1. Group data by `outlet_establishment_year`.
2. Use SUM(total_sales) to calculate total revenue per establishment year.
3. Format results to 2 decimal places for readability.
4. Sort by year to visualize sales trend chronologically.

------------------------------------------------------------*/

-- 8. Total Sales by Outlet Establishment Year
SELECT 
    outlet_establishment_year, 
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS total_sales
FROM sales_data
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;

/*------------------------------------------------------------
Result:
| outlet_establishment_year | total_sales  |
|----------------------------|--------------|
| 1998                       | 204522.26    |
| 2000                       | 131809.02    |
| 2010                       | 132113.37    |
| 2011                       | 78131.56     |
| 2012                       | 130476.86    |
| 2015                       | 130942.78    |
| 2017                       | 133103.91    |
| 2020                       | 129103.96    |
| 2022                       | 131477.77    |

 Insight:
- **Outlets established in 1998** recorded the highest total sales (₹204,522.26), 
  indicating strong brand maturity and customer loyalty for older stores.
- Outlets from **2011** show the lowest performance (₹78,131.56), which could 
  be due to smaller footprint, less visibility, or lower market presence.
- Sales for outlets established after 2010 remain relatively stable 
  (₹129k–₹133k range), suggesting consistent performance among newer outlets.
- This insight implies that **outlet age and experience** may positively 
  influence total sales, especially for long-established locations.

------------------------------------------------------------*/


/*------------------------------------------------------------
 Percentage of Sales by Outlet Size
------------------------------------------------------------
Objective:
To determine how much each outlet size (Small, Medium, High) contributes 
to total company sales. This helps evaluate which store size drives 
the majority of revenue and supports decisions on store expansion or 
downsizing.

Logic:
1. Group data by `outlet_size`.
2. Compute total sales for each outlet size using SUM(total_sales).
3. Calculate percentage contribution using:
      (SUM(total_sales) * 100.0 / SUM(SUM(total_sales)) OVER())
4. Format both total and percentage values for clarity.
5. Order results by total sales (highest to lowest).

------------------------------------------------------------*/

-- 9. Percentage of Sales by Outlet Size
SELECT 
    outlet_size, 
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS total_sales,
    CAST((SUM(total_sales) * 100.0 / SUM(SUM(total_sales)) OVER()) AS DECIMAL(10,2)) AS sales_percentage
FROM sales_data
GROUP BY outlet_size
ORDER BY total_sales DESC;

/*------------------------------------------------------------
 Result:
| outlet_size | total_sales | sales_percentage |
|--------------|-------------|------------------|
| Medium       | 507895.73   | 42.27%           |
| Small        | 444794.17   | 37.01%           |
| High         | 248991.58   | 20.72%           |

 Insight:
- **Medium-sized outlets** dominate with **42.27%** of total sales, 
  suggesting an optimal balance between cost and customer reach.
- **Small outlets** contribute a strong **37.01%**, highlighting their 
  efficiency and accessibility despite limited capacity.
- **High-sized outlets** account for only **20.72%**, which may indicate 
  underutilized space or higher operating costs relative to revenue.
- The company could focus on **expanding medium-sized outlets** or 
  optimizing large outlets to improve their performance.

------------------------------------------------------------*/


/*------------------------------------------------------------
 Sales by Outlet Location Type
------------------------------------------------------------
Objective:
To analyze how total sales vary across different outlet location tiers 
(Tier 1, Tier 2, Tier 3).  
This helps identify which regions or market segments generate the most 
revenue and where to focus business expansion or marketing efforts.

Logic:
1. Group sales data by `outlet_location_type`.
2. Use SUM(total_sales) to calculate total revenue for each tier.
3. Format totals for readability and rank them in descending order 
   to highlight top-performing tiers.

------------------------------------------------------------*/

-- 10. Sales by Outlet Location Type
SELECT 
    outlet_location_type, 
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS total_sales
FROM sales_data
GROUP BY outlet_location_type
ORDER BY total_sales DESC;

/*------------------------------------------------------------
 Result:
| outlet_location_type | total_sales |
|-----------------------|-------------|
| Tier 3               | 472133.03   |
| Tier 2               | 393150.64   |
| Tier 1               | 336397.81   |

 Insight:
- **Tier 3 outlets** lead with the highest sales (₹472K+), indicating 
  strong performance in **urban or densely populated markets**.
- **Tier 2 outlets** contribute ₹393K+, showing consistent performance 
  across semi-urban regions.
- **Tier 1 outlets** show lower total sales (₹336K+), suggesting possible 
  constraints such as limited store count or lower customer footfall.
- The business could **prioritize Tier 3 regions** for new store openings 
  or **invest in promotional campaigns** to boost Tier 1 performance.

------------------------------------------------------------*/


/*------------------------------------------------------------
 All Key Metrics by Outlet Type
------------------------------------------------------------
Objective:
To compare various performance metrics across different outlet types — 
including total sales, average sales, number of items, average rating, 
and average item visibility.  
This provides a complete picture of how each outlet type performs 
in terms of revenue generation, customer satisfaction, and product reach.

Logic:
1. Group data by `outlet_type`.
2. Calculate multiple metrics:
   - Total Sales → Overall revenue contribution.
   - Average Sales → Typical sales per item or outlet.
   - No_Of_Items → Count of records (product–outlet combinations).
   - Average Rating → Customer or product performance score.
   - Item Visibility → Measures in-store product prominence.
3. Order results by total sales to highlight top-performing outlet types.

------------------------------------------------------------*/

-- 11. All Metrics by Outlet Type
SELECT 
    outlet_type, 
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(total_sales) AS DECIMAL(10,0)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(rating) AS DECIMAL(10,2)) AS Avg_Rating,
    CAST(AVG(item_visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM sales_data
GROUP BY outlet_Type
ORDER BY total_sales DESC;

/*------------------------------------------------------------
Result:
| outlet_type         | Total_Sales | Avg_Sales | No_Of_Items | Avg_Rating | Item_Visibility |
|---------------------|-------------|------------|--------------|-------------|-----------------|
| Supermarket Type1   | 787,549.89  | 141        | 5,577        | 3.96        | 0.06            |
| Grocery Store       | 151,939.15  | 140        | 1,083        | 3.99        | 0.10            |
| Supermarket Type2   | 131,477.77  | 142        |   928        | 3.97        | 0.06            |
| Supermarket Type3   | 130,714.67  | 140        |   935        | 3.95        | 0.06            |

 Insights:
- **Supermarket Type1** clearly dominates with ₹787K+ in total sales, 
  driven by the highest number of items and balanced visibility.  
- **Grocery Stores** show strong average ratings (3.99) but higher 
  item visibility (0.10), which may indicate smaller product variety 
  with focused display strategies.
- **Supermarket Type2** and **Type3** perform similarly in both 
  average sales (~₹140–142) and visibility (~0.06), suggesting 
  operational consistency across store formats.
- Despite similar ratings across outlets (3.9–4.0), differences in 
  visibility and product count affect total revenue distribution.
- Recommendation: 
  - Maintain the strong performance of Supermarket Type1 through 
    optimized inventory and promotions.
  - Explore why Grocery Stores, despite higher visibility, 
    generate significantly lower total sales.

------------------------------------------------------------*/





