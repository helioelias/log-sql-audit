SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

ALTER PROCEDURE dbo.proc_Insert_To_Log @Table_Name sysname
AS
-- Insert data to log file
DECLARE @insRowCount Integer,
        @delRowCount Integer,
        @Operation Char(1),
        @Log_Table sysname,
        @strSQL0 Nvarchar(100),
        @strSourSQL1 varchar(8000),
        @strDestSQL1 varchar(8000),
        @Tbl_Col_Name NVarchar(200),
        @IdentityRowCount integer

-- Get the log table name from 
SELECT @Log_Table = Log_Table_Name
FROM tbl_Data_Tables
WHERE Table_Name = @Table_Name

-- Get the inserted and deleted row count
SELECT @insRowCount = count(*)
FROM #Tmp_Inserted
SELECT @delRowCount = count(*)
FROM #Tmp_Deleted

-- If no row is inserted or deleted return
IF @insRowCount = 0
   AND @delRowCount = 0
    Return
-- Get the activity-- if data is present in both insert and delete temp tables
-- then an update statement is fired
If @insRowCount > 0
   AND @delRowCount > 0
    SET @Operation = 'U'
ELSE IF @insRowCount > 0
        AND @delRowCount = 0 -- insert statement is fired
    SET @Operation = 'I'
ELSE IF @insRowCount = 0
        AND @delRowCount > 0 -- delete statement is fired
    SET @Operation = 'D'

-- Prepare the statement to insert data into logtable
SET @strSourSQL1 = 'INSERT INTO ' + @Log_Table + '('

-- Open cursor to get the columns of the current table from sysobjects
SET @strDestSQL1 = ' SELECT '
DECLARE Column_Cursor CURSOR FOR
SELECT T1.Name As [Column Name]
FROM [SYSCOLUMNS] T1
    INNER JOIN [SYSOBJECTS] T2
        ON T1.id = T2.id
WHERE T2.name = @Table_Name

OPEN Column_Cursor
FETCH FROM Column_Cursor
INTO @Tbl_Col_Name
WHILE @@Fetch_Status = 0
BEGIN
    SET @strSourSQL1 = @strSourSQL1 + '[' + @Tbl_Col_Name + ']'
    SET @strDestSQL1 = @strDestSQL1 + +'[' + @Tbl_Col_Name + ']'

    SET @strSourSQL1 = @strSourSQL1 + ','
    SET @strDestSQL1 = @strDestSQL1 + ','

    FETCH NEXT FROM Column_Cursor
    INTO @Tbl_Col_Name
END
CLOSE Column_Cursor

DEALLOCATE Column_Cursor
-- Append activity column
SET @strSourSQL1 = @strSourSQL1 + '[Activity], [ChangeDate], [UserName])'

SET @strDestSQL1 = @strDestSQL1 + '''' + @Operation + ''' , getdate() as ChangeDate, SUSER_SNAME() as UserName '
-- Get the data based on activity
IF @Operation = 'I'
    SET @strDestSQL1 = @strDestSQL1 + ' FROM #Tmp_Inserted'
ELSE
    SET @strDestSQL1 = @strDestSQL1 + ' FROM #Tmp_Deleted'

-- Check whether the log table has an identity column
SELECT @IdentityRowCount = COUNT(T2.Name)
FROM SYSOBJECTS T1
    INNER JOIN SYSCOLUMNS T2
        ON T1.ID = T2.ID
WHERE T1.name = @Log_Table
      AND T2.Status = 128

-- Enable identity insert if an identity column exists
IF @IdentityRowCount > 0
    SET @strSQL0 = 'SET IDENTITY_INSERT ' + @Log_Table + ' ON; '
ELSE
    SET @strSQL0 = ''

-- Execute the statements
EXEC (@strSQL0 + @strSourSQL1 + @strDestSQL1)

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO