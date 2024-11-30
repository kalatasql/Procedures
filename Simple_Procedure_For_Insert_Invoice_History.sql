USE [kalatasql]
GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_Invoices]    Script Date: 30/11/2024 2:28:57 am ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_Insert_Invoices] -- Update procedure (ALTER)
AS
BEGIN
	BEGIN TRY -- try catch block
	
	DECLARE @Last_Load_Date DATE = (SELECT MAX(LoadDate) FROM Invoices) -- Get last loaddate and save it in variable

	IF @Last_Load_Date IS NULL -- if loaddate is null then throw error
        BEGIN
            THROW 51001, 'No LoadDate values found in Invoices.', 1;
        END;

	IF @Last_Load_Date = CONVERT(DATE, GETDATE()) -- check last load date is today
		BEGIN
			INSERT INTO Invoices_History (Invoice_ID, InvoiceDate, LastUpdateDate, DueDate, Seller_first_name, -- Insert in history table
										  Seller_last_name, Customer_first_name, Customer_last_name)
            SELECT ID, InvoiceDate, LastUpdateDate, DueDate, Seller_first_name,
										  Seller_last_name, Customer_first_name, Customer_last_name
			FROM Invoices WHERE LoadDate = @Last_Load_Date;
		END
		ELSE 
		throw 51000, 'The last loaddt is not today.', 1; -- throw error if load date is NOT today
	END TRY

	BEGIN CATCH -- try catch block
	 PRINT 'An error occurred: ' + ERROR_MESSAGE();
        THROW; 
	END CATCH
END
GO


