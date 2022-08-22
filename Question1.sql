-- Function: public.question1(date, date)

-- DROP FUNCTION public.question1(date, date);

CREATE OR REPLACE FUNCTION public.question1(
    IN p_time_window_begin date,
    IN p_time_window_end date)
  RETURNS TABLE(department text, week_ending_date date, item_no integer, avg_retail_sales double precision, unit_sales integer, retail_sales double precision) AS
$BODY$
DECLARE 
 cursor_week_ending_dates CURSOR
 FOR SELECT DISTINCT("WeekEndingDate") FROM public."Calendar" AS c 
	WHERE (c."WeekEndingDate" - 6) >=  p_time_window_begin 
		AND (c."WeekEndingDate") <=  p_time_window_end ;
 rec_date RECORD;

 cursor_department CURSOR
 FOR SELECT DISTINCT("Department") FROM public."ProductHier";
 rec_department RECORD;
BEGIN
 CREATE TEMP TABLE tmp(
  department text,
  week_ending_date date,
  item_no integer, 
  avg_retail_sales double precision,
  unit_sales int,
  retail_sales double precision  
  );
  
 OPEN cursor_week_ending_dates;

 LOOP
	FETCH cursor_week_ending_dates INTO rec_date;
	EXIT WHEN NOT FOUND;
		OPEN cursor_department;
		LOOP
			FETCH cursor_department INTO rec_department;
			EXIT WHEN NOT FOUND;
			RAISE NOTICE 'i want to print % and %', rec_date."WeekEndingDate",rec_department."Department";
			 INSERT INTO tmp
			 SELECT 
				rec_department."Department",
				rec_date."WeekEndingDate",
				s."ItemNo",
				(SUM(s."RetailSales") / SUM(s."UnitSales")) as avg_retail_sales,
				SUM(s."UnitSales"),
				SUM(s."RetailSales")
			 FROM public."Sales" as s
			 INNER JOIN public."ProductHier" as p
				ON s."ItemNo"= p."ItemNo"
			 WHERE 
				s."Date" >= (rec_date."WeekEndingDate" - 6)
				AND s."Date" < rec_date."WeekEndingDate"
				AND p."Department" = rec_department."Department"
				AND s."UnitSales" > 0
			 GROUP BY s."ItemNo"
			 ORDER BY avg_retail_sales DESC
			 LIMIT 10;
		END LOOP;
		CLOSE cursor_department;
 END LOOP; 

 CLOSE cursor_week_ending_dates;
 
 RETURN QUERY 
	SELECT *
	FROM tmp 
	ORDER BY week_ending_date, avg_retail_sales DESC;
	
 DROP TABLE tmp;
 
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.question1(date, date)
  OWNER TO postgres;
