--P_TransactionByPeriod Procedure
--This stored procedure retrieves aggregated transaction data for a specified date range. It validates the dates, 
--checks if transactions exist in the range, and then calculates the total, maximum, and average transaction amounts per account.
--Additionally, it counts how many transactions are below the average for each account.

--The result includes:

--Total transaction amount
--Maximum transaction amount
--Average transaction amount
--Count of transactions below the average
--It uses Common Table Expressions (CTEs) and a LEFT JOIN to combine the data.


CREATE OR ALTER PROCEDURE P_TransactionByPeriod @StartDate DATE, @EndDate DATE
AS 
BEGIN 
	DECLARE @IsTransactionsEmpty INT;
	
	IF @StartDate > @EndDate 
	BEGIN
		THROW 51000, 'Start date MUST be smaller than End date.', 1;
	END;

	SELECT @IsTransactionsEmpty = COUNT(*) 
	FROM Transactions 
	WHERE TranDate BETWEEN @StartDate AND @EndDate

	IF @IsTransactionsEmpty = 0
	BEGIN 
		THROW 51000, 'There is no transaction between these periods.', 1;
	END;

	WITH 
		transBetween AS (
		SELECT 
		AccountID,
		SUM(Amount) AS [Total Amount for Acc tran],
		MAX(Amount) AS [Max Amount for ACC tran],
		AVG(Amount) AS [Average Amount for ACC tran]
	FROM Transactions
	WHERE TranDate BETWEEN @StartDate AND @EndDate
	GROUP BY AccountID
	               ),
		count_below_avg AS (
		SELECT 
		t.AccountID,
		COUNT(*) AS [Tran below AVG]
		from Transactions t
		inner join transBetween tb on t.accountID = tb.accountID
		WHERE t.Amount < tb.[Average Amount for ACC tran] 
			  AND TranDate BETWEEN @StartDate AND @EndDate
		GROUP BY t.AccountID 
						   ) 
		SELECT 
			  tb.accountID,
			  tb.[Total Amount for Acc tran],
			  tb.[Max Amount for ACC tran],
			  tb.[Average Amount for ACC tran],
			  ISNULL(cba.[Tran below AVG], 0) AS [Tran below AVG]
		FROM transBetween tb
		LEFT JOIN count_below_avg cba ON tb.accountID = cba.accountID
	
END 
