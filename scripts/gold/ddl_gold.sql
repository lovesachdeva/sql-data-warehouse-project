/*
==============================================================
GOLD LAYER: VIEWS
==============================================================
*/
-- ==============================================================
-- VIEW:gold.dim_customers
-- ==============================================================

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	CASE
		WHEN ci.cst_gndr!='n/a' then ci.cst_gndr
		else COALESCE(ca.gen,'n/a')
		END as gender,
	ca.bdate as birth_date,
	ci.cst_create_date as create_date
	
 from silver.crm_cust_info ci
 left join silver.erp_cust_az12 ca
 on ci.cst_key=ca.cid
 left join silver.erp_loc_a101 la
 on ci.cst_key=la.cid
-- ==============================================================
-- VIEW:gold.dim_products
-- ==============================================================
CREATE VIEW gold.dim_products as
SELECT
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance as maintenance,
	pn.prd_cost as cost,
	pn.prd_line as line,
	pn.prd_start_dt as start_date 
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
WHERE pn.prd_end_dt IS NULL
-- ==============================================================
-- VIEW:gold.view_sales
-- ==============================================================

CREATE VIEW gold.fact_sales as
SELECT
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id

