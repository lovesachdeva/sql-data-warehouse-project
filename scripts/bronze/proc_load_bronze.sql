/*
stored procedure for bronze layer
TO RUN : EXEC bronze.load_bronze
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		PRINT'===================================';
		PRINT'LOADING BRONZE LAYER';
		PRINT'===================================';

		PRINT'-----------------------------------';
		PRINT'LOADING CRM TABLES';
		PRINT'-----------------------------------';
		SET @batch_start_time=GETDATE();
		SET @start_time=GETDATE();
		PRINT '<< TRUNCATE TABLE :bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT'INSERTING DATA INTO :bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
		SET @start_time=GETDATE();
		PRINT '<< TRUNCATE TABLE :bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT'INSERTING DATA INTO :bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';

		SET @start_time=GETDATE();
		PRINT '<< TRUNCATE TABLE :bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT'INSERTING DATA INTO :bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
		PRINT'-----------------------------------';
		PRINT'LOADING ERP TABLES';
		PRINT'-----------------------------------';
		SET @start_time=GETDATE();
		PRINT '<< TRUNCATE TABLE :bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT'INSERTING DATA INTO :bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
		SET @start_time=GETDATE();
		PRINT '<< TRUNCATE TABLE :bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT'INSERTING DATA INTO :bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
	
		SET @start_time=GETDATE();	
		PRINT '<< TRUNCATE TABLE :bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT'INSERTING DATA INTO :bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\SQL P\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			firstrow=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE();
		PRINT'>>LOADING TIME:'+CAST(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT'-----------------------------------';
		
		SET @batch_end_time=GETDATE();
		PRINT'>>BATCH LOADING TIME:'+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as nvarchar) + 'seconds';

		END TRY
		BEGIN CATCH
				PRINT'===================================';
				PRINT'ERROR OCCURED WHILE LOADING BRONZE LAYER';
				PRINT'ERROR MESSAGE'+CAST(ERROR_MESSAGE() AS NVARCHAR);
				PRINT'ERROR NUMBER'+CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT'ERROR STATE'+CAST(ERROR_STATE() AS NVARCHAR);
				PRINT'===================================';
		END CATCH
END
