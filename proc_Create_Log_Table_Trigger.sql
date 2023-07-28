SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE dbo.proc_Create_Log_Table_Trigger
AS
-- Creates log tables and Trigger to the main tables.
DECLARE @Table_Name sysname,
        @Log_Table sysname,
        @strSQL Varchar(8000)

DECLARE eRR_Data_Table Cursor FOR
SELECT sobj.Name [Table_Name]
FROM [sysobjects] sobj
WHERE sobj.Name NOT in ( 'tbl_Data_Tables', 'dtproperties' )
      AND sobj.Name NOT IN (
                               SELECT Table_Name
                               FROM tbl_Data_Tables
                               UNION
                               SELECT Log_Table_Name AS Table_Name
                               FROM tbl_Data_Tables
                           )
      AND sobj.xType = 'U'
ORDER BY 1

OPEN eRR_Data_Table
FETCH FROM eRR_Data_Table
INTO @Table_Name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Log_Table = @Table_Name + '_Log'
    --Create New log Table
    SET @strSQL = '  SELECT * INTO [dbo].[' + @Log_Table + '] FROM [dbo].[' + @Table_Name + '] WHERE 1 = 2  '
    EXEC (@strSQL)

    -- Drop all Constraints
    EXECUTE proc_drop_constraints @Log_Table
    SET @strSQL
        = ' Alter Table ' + @Log_Table
          + ' ADD  Activity Char(1), ChangeDate datetime not null, UserName nvarchar(100) not null '
    EXEC (@strSQL)

    --Insert Data to maintain relation ship between log tables and main table
    INSERT INTO tbl_Data_Tables
    (
        Table_Name,
        Log_Table_Name
    )
    SELECT @Table_Name,
           @Log_Table

    --Create Trigger for main  table 
    --PRINT @Table_Name
    SET @strSQL = 'CREATE TRIGGER dbo.[Update_LOG_' + @Table_Name + '] ON [dbo].[' + @Table_Name + '] ' + CHAR(13)
    SET @strSQL = @strSQL + 'FOR INSERT,UPDATE,DELETE ' + CHAR(13)
    SET @strSQL = @strSQL + 'AS ' + CHAR(13)
    SET @strSQL = @strSQL + 'SELECT * INTO #Tmp_Inserted FROM Inserted ' + CHAR(13)
    SET @strSQL = @strSQL + 'SELECT * INTO #Tmp_Deleted FROM Deleted  ' + CHAR(13)
    SET @strSQL = @strSQL + 'exec proc_Insert_To_Log  [' + @Table_Name + '] ' + CHAR(13)
    SET @strSQL = @strSQL + 'Drop Table #Tmp_Inserted  ' + CHAR(13) -- the temp tables are used in proc_Insert_To_Log
    SET @strSQL = @strSQL + 'Drop Table #Tmp_Deleted ' + CHAR(13)
    --PRINT @strSQL
    EXEC (@strSQL)
    Fetch Next from eRR_Data_Table
    INTO @Table_Name
END
CLOSE eRR_Data_Table
DEALLOCATE eRR_Data_Table

--Delete Log Table if not exists in database
DECLARE eRR_Garbage_Table Cursor FOR
select Table_Name,
       Log_Table_Name
from tbl_Data_Tables
where Table_Name not in (
                            SELECT sobj.Name [Table_Name]
                            FROM [sysobjects] sobj
                            WHERE sobj.Name NOT in ( 'tbl_Data_Tables', 'dtproperties' )
                                  AND sobj.xType = 'U'
                        )
OPEN eRR_Garbage_Table
FETCH FROM eRR_Garbage_Table
INTO @Table_Name,
     @Log_Table
WHILE @@FETCH_STATUS = 0
BEGIN

    BEGIN TRY
        SET @strSQL = 'DROP TABLE dbo.[' + @Log_Table + ']' + CHAR(13)
        EXEC (@strSQL)
    END TRY
    BEGIN CATCH
        print 'CANNOT DROP TABLE dbo.[' + @Log_Table + ']'
    END CATCH

    Delete tbl_Data_Tables
    where Table_Name = @Table_Name

    Fetch Next from eRR_Garbage_Table
    INTO @Table_Name,
         @Log_Table
END
CLOSE eRR_Garbage_Table
DEALLOCATE eRR_Garbage_Table

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
