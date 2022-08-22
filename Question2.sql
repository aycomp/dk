-- Function: public.question2(date, date)

-- DROP FUNCTION public.question2(date, date);

CREATE OR REPLACE FUNCTION public.question2(
    IN p_time_window_begin date,
    IN p_time_window_end date)
  RETURNS TABLE(item_no integer, department text, class text) AS
$BODY$
DECLARE 
 cursor_week_ending_dates CURSOR
 FOR SELECT DISTINCT("WeekEndingDate") FROM public."Calendar" AS c 
	WHERE (c."WeekEndingDate" - 6) >=  p_time_window_begin 
		AND (c."WeekEndingDate") <=  p_time_window_end ;
 rec_date RECORD;

BEGIN
 CREATE TEMP TABLE tmp(
	  item_no integer, 
	  unit_sale_sum integer,
	  week_ending_date date
  );
  
 OPEN cursor_week_ending_dates;

 LOOP
	FETCH cursor_week_ending_dates INTO rec_date;
	EXIT WHEN NOT FOUND;
		RAISE NOTICE 'i want to print % ', rec_date."WeekEndingDate";
		--Finds ItemNo for each week, which has SUM(UnitSales) >  20
		INSERT INTO tmp
		SELECT 
			s."ItemNo",
			SUM(s."UnitSales") as unit_sale_sum,
			rec_date."WeekEndingDate" as week_ending_date
		FROM public."Sales" as s
		WHERE (s."Date" <= rec_date."WeekEndingDate") AND (s."Date" >= rec_date."WeekEndingDate" - 6)
		GROUP BY s."ItemNo", week_ending_date
		HAVING SUM(s."UnitSales") > 20;	

 END LOOP; 

 CLOSE cursor_week_ending_dates;
 
 RETURN QUERY 
	SELECT
		p."ItemNo",
		p."Department",
		p."Class"
	FROM public."ProductHier" p
	WHERE p."ItemNo" IN 
	(
		SELECT 
			t."item_no"
		FROM tmp as t
		GROUP BY t."item_no"
		HAVING COUNT(t."item_no") >= 3
	)
	ORDER BY p."ItemNo";
	
 DROP TABLE tmp;
 
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.question2(date, date)
  OWNER TO postgres;
