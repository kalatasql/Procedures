ALTER PROCEDURE rtool.SP_GEN_REPORT_CHECK_AND_INSERT 
	@report_id INT,
	@check BIT, -- An integer data type that can take a value of 1, 0, or NULL.
	@insert BIT
AS
BEGIN

	SET DATEFIRST 1;	

	DECLARE @is_report_valid TINYINT;
	DECLARE @last_generated_date DATE;
	
	SELECT TOP(1) @is_report_valid = id 
	FROM rtool.reports 
	WHERE id = @report_id

	IF @is_report_valid IS NULL
		BEGIN
			THROW 51000, 'The report_id does not exist.', 1;
		END	

	SELECT @last_generated_date = max(GeneratedOn)
	FROM rtool.report_generated 
	WHERE report_id = @report_id

	IF @last_generated_date = CONVERT(DATE, GETDATE())
		THROW 51000, 'The report is inserted today.', 1;

	ELSE IF	(@check = 1 AND @insert = 0) 
		AND (@last_generated_date < CONVERT(DATE, GETDATE()) OR @last_generated_date IS NULL)  -- before we start with python code for execute dtsx, we need to check if executed dtsx is successful
									 -- that's why we need to execute this procedure two times.
		return 1; -- we continue 

	ELSE IF  (@check = 1 AND @insert = 1) AND (@last_generated_date < CONVERT(DATE, GETDATE()) OR @last_generated_date IS NULL)
				-- IF DTSX is executed sucesfully set @check = 1 and @insert = 1 in Python.
		BEGIN
			INSERT INTO rtool.report_generated (Report_ID, GeneratedOn) VALUES (@report_id, GETDATE())
			return 1; -- success
		END
	ELSE 
		BEGIN
			THROW 51000, 'Check your [check] and [insert] variables.', 1;
		END
END
