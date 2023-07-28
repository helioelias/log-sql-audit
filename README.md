# log-sql-audit
Simples system for audit log table


Create Log tables and Triggers
Srinivasulu Nasam, 2007-10-26 (first published: 2007-08-09)
https://www.sqlservercentral.com/scripts/create-log-tables-and-triggers

Execute follow steps
1. Create table (tbl_Data_Tables.sql)
2. Create all sp´s (proc_Create_Log_Table_Trigger.sql, proc_Drop_Constraints.sql, proc_Drop_Log_Table_Trigger.sql, proc_Insert_To_Log.sql)


Execute SP to create all tables logs, if you drop table execute again to refresh table logs
exec dbo.proc_Create_Log_Table_Trigger


If you need drop logs table you can execute this sp
exec dbo.proc_Drop_Log_Table_Trigger


**Warning**
If you change table structure, add, update or delete columns,
you need change table log structure too

```
Files
|-- README.md
|-- proc_Create_Log_Table_Trigger.sql
|-- proc_Drop_Constraints.sql
|-- proc_Drop_Log_Table_Trigger.sql
|-- proc_Insert_To_Log.sql
 -- tbl_Data_Tables.sql
 ```
