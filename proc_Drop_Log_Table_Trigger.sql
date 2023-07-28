SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC dbo.proc_Drop_Log_Table_Trigger
AS
-- Creates log tables and Trigger to the main tables.
DECLARE @Table_Name sysname,
        @Log_Table_Name sysname,
        @strSQL Varchar(8000)

DECLARE eRR_Data_Table Cursor FOR
SELECT Table_Name,
       Log_Table_Name
FROM tbl_Data_Tables
ORDER BY 1

OPEN eRR_Data_Table
FETCH FROM eRR_Data_Table
INTO @Table_Name,
     @Log_Table_Name
WHILE @@FETCH_STATUS = 0
BEGIN

    BEGIN TRY
        SET @strSQL = 'DROP TABLE dbo.[' + @Log_Table_Name + ']' + CHAR(13)
        EXEC (@strSQL)
    END TRY
    BEGIN CATCH
        print 'CANNOT DROP TABLE dbo.[' + @Log_Table_Name + ']'
    END CATCH

    BEGIN TRY
        SET @strSQL = 'DROP TRIGGER dbo.[Update_LOG_' + @Table_Name + ']' + CHAR(13)
        EXEC (@strSQL)
    END TRY
    BEGIN CATCH
        print 'CANNOT DROP TRIGGER dbo.[Update_LOG_' + @Table_Name + ']'
    END CATCH
    Fetch Next from eRR_Data_Table
    INTO @Table_Name,
         @Log_Table_Name
END
CLOSE eRR_Data_Table
DEALLOCATE eRR_Data_Table

truncate table tbl_Data_Tables

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO