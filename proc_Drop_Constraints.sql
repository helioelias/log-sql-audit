SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE proc dbo.proc_Drop_Constraints @tablename sysname
AS
-- sp_drop_constraints will drop all constraints on the specified table, 
-- including CHECK, FOREIGN KEY, PRIMARY KEY, UNIQUE, DEFAULT and  Identiy constraints. 

SET NOCOUNT ON

DECLARE @constname sysname,
        @cmd varchar(1024)

DECLARE curs_constraints CURSOR FOR
SELECT NAME
FROM sysobjects
WHERE xtype in ( 'C', 'F', 'PK', 'UQ', 'D' )
      AND (status & 64) = 0
      AND parent_obj = object_id(@tablename)

OPEN curs_constraints

FETCH NEXT FROM curs_constraints
INTO @constname
WHILE (@@fetch_status = 0)
BEGIN
    SELECT @cmd = 'ALTER TABLE ' + @tablename + ' DROP CONSTRAINT ' + @constname
    EXEC (@cmd)
    FETCH NEXT FROM curs_constraints
    INTO @constname
END
CLOSE curs_constraints
DEALLOCATE curs_constraints
RETURN 0
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO