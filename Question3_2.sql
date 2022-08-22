-- Function: public.question3_2(date, date)

-- DROP FUNCTION public.question3_2(date, date);

CREATE OR REPLACE FUNCTION public.question3_2(
    IN p_time_window_begin date,
    IN p_time_window_end date)
  RETURNS TABLE(cls text, item_no integer, unit_sales integer) AS
$BODY$
DECLARE 
 cursor_class CURSOR
 FOR SELECT DISTINCT("Class") FROM public."ProductHier" AS p; 
 rec_class RECORD;

BEGIN
 CREATE TEMP TABLE tmp(
  item_no integer, 
  unit_sales int,
  cls text
  );
  
 OPEN cursor_class;

 LOOP
	FETCH cursor_class INTO rec_class;
	EXIT WHEN NOT FOUND;
		 RAISE NOTICE 'i want to print % ', rec_class."Class";
		 INSERT INTO tmp
		 SELECT 
			s."ItemNo",
			SUM(s."UnitSales") as unit_sales,
			rec_class."Class" as cls
		 FROM public."Sales" as s
		 INNER JOIN public."ProductHier" as p
			ON s."ItemNo"= p."ItemNo"
		 WHERE 
			s."Date" >= p_time_window_begin AND s."Date" < p_time_window_end
			AND p."Class" = rec_class."Class"
			AND s."UnitSales" > 0
		 GROUP BY s."ItemNo", cls
		 ORDER BY unit_sales DESC
		 LIMIT 10;

 END LOOP; 

 CLOSE cursor_class;
 
 RETURN QUERY 
	SELECT 
	 t.cls,
	 t.item_no,
	 t.unit_sales
	FROM tmp as t;
	
 DROP TABLE tmp;
 
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.question3_2(date, date)
  OWNER TO postgres;
