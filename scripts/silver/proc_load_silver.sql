/*
*/
CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		PRINT'===================================';
		PRINT'LOADING SILVER LAYER';
		PRINT'===================================';

		PRINT'-----------------------------------';
		PRINT'LOADING CRM TABLES';
		PRINT'-----------------------------------';
		SET @batch_start_time=GETDATE();
		SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT'>> Inserting Table into :silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE 'n/a'
			END as cst_marital_status,
		CASE
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
			END as cst_gndr,
		cst_create_date
	from(
	SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id order by cst_create_date desc) as flag_last 
	FROM bronze.crm_cust_info
	where cst_id is not null) t
	WHERE  flag_last=1 ;
	SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
	
	SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT'>> Inserting Table into :silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt ) 
	SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key, 
		prd_nm,
		ISNULL(prd_cost,0) as prd_cost,
		CASE UPPER(TRIM(prd_line)) 
			WHEN 'R' then 'Road'
			WHEN 'S' then 'Other Sales'
			WHEN 'M' then 'Mountain'
			WHEN 'T' then 'Touring'
			else 'n/a'
			END prd_line,
		CAST(prd_start_dt AS DATE) prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 as date) as prd_end_date
		FROM bronze.crm_prd_info;
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';

	SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT'>> Inserting Table into :silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt is null or len(sls_order_dt)!=8 then NULL
			else CAST(CAST(sls_order_dt as varchar) AS DATE)
			END sls_order_dt,
		CASE 
			WHEN sls_ship_dt is null or len(sls_ship_dt)!=8 then NULL
			else CAST(CAST(sls_ship_dt as varchar) AS DATE)
			END sls_ship_dt,
		CASE 
			WHEN sls_due_dt is null or len(sls_due_dt)!=8 then NULL
			else CAST(CAST(sls_due_dt as varchar) AS DATE)
			END sls_due_dt,
		CASE
			WHEN sls_sales is null or sls_sales<=0 or ABS(sls_price)*sls_quantity!=sls_sales then ABS(sls_price)*sls_quantity
			ELSE sls_sales
			END sls_sales,
		sls_quantity,
		CASE
			WHEN sls_price is null or sls_price<=0 then sls_sales/nullif(sls_quantity,0)
			ELSE sls_price
			END sls_price
	from bronze.crm_sales_details
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
	PRINT'-----------------------------------';
		PRINT'LOADING ERP TABLES';
		PRINT'-----------------------------------';
	SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT'>> Inserting Table into :silver.erp_cust_az12';
	INSERT INTO silver.erp_cust_az12(
		cid,
		bdate,
		gen
	)
	select
	CASE 
		WHEN cid like 'NAS%' then SUBSTRING(cid,4,len(cid)) 
		else cid
		end as cid,
	CASE
		WHEN bdate > GETDATE() then NULL
		ELSE bdate
		END as bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('M','MALE') then 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') then 'female'
		else 'n/a'
		end as gen
	from bronze.erp_cust_az12
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
	SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	PRINT'>> Inserting Table into :silver.erp_loc_a101';
	INSERT INTO silver.erp_loc_a101(cid,cntry)
	select
	REPLACE(cid,'-','') cid,
	CASE
		WHEN TRIM(cntry)='DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US' , 'USA') THEN 'United States'
		WHEN TRIM(cntry) is null or TRIM(cntry)='' then 'n/a'
		else cntry
		END as cntry
	from bronze.erp_loc_a101
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	

	SET @start_time=GETDATE();
	PRINT'>> Truncating Table :silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT'>> Inserting Table into :silver.erp_px_cat_g1v2';
	INSERT INTO silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
		)
	select
		id,
		cat,
		subcat,
		maintenance
	from bronze.erp_px_cat_g1v2
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
		
		SET @batch_end_time=GETDATE();
		PRINT'>>BATCH LOADING TIME:'+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as nvarchar) + 'seconds';

		END TRY
		BEGIN CATCH
				PRINT'===================================';
				PRINT'ERROR OCCURED WHILE LOADING SILVER LAYER';
				PRINT'ERROR MESSAGE'+CAST(ERROR_MESSAGE() AS NVARCHAR);
				PRINT'ERROR NUMBER'+CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT'ERROR STATE'+CAST(ERROR_STATE() AS NVARCHAR);
				PRINT'===================================';
		END CATCH
END


