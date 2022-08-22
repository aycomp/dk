-- Function: public.question3_1(date, date)

-- DROP FUNCTION public.question3_1(date, date);

CREATE OR REPLACE FUNCTION public.question3_1(
    IN p_time_window_begin date,
    IN p_time_window_end date)
  RETURNS TABLE(department text, item_no integer, unit_sales integer) AS
$BODY$
DECLARE 
 cursor_department CURSOR
 FOR SELECT DISTINCT("Department") FROM public."ProductHier" AS p; 
 rec_department RECORD;

BEGIN
 CREATE TEMP TABLE tmp(
  item_no integer, 
  unit_sales int,
  department text
  );
  
 OPEN cursor_department;

 LOOP
	FETCH cursor_department INTO rec_department;
	EXIT WHEN NOT FOUND;
		 RAISE NOTICE 'i want to print % ', rec_department."Department";
		 INSERT INTO tmp
		 SELECT 
			s."ItemNo",
			SUM(s."UnitSales") as unit_sales,
			rec_department."Department" as department
		 FROM public."Sales" as s
		 INNER JOIN public."ProductHier" as p
			ON s."ItemNo"= p."ItemNo"
		 WHERE 
			s."Date" >= p_time_window_begin AND s."Date" < p_time_window_end
			AND p."Department" = rec_department."Department"
			AND s."UnitSales" > 0
		 GROUP BY s."ItemNo", department
		 ORDER BY unit_sales DESC
		 LIMIT 10;

 END LOOP; 

 CLOSE cursor_department;
 
 RETURN QUERY 
	SELECT 
	 t.department,
	 t.item_no,
	 t.unit_sales
	FROM tmp as t;
	
 DROP TABLE tmp;
 
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.question3_1(date, date)
  OWNER TO postgres;
