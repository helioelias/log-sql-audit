CREATE TABLE [dbo].[tbl_Data_Tables] (
  [Id] [bigint] IDENTITY (1, 1) NOT NULL, 
  [Table_Name] [nvarchar] (100) NOT NULL, 
  [Log_Table_Name] [nvarchar] (104) NOT NULL, 
  CONSTRAINT [PK_tbl_Data_Tables] PRIMARY KEY CLUSTERED ([Id]) WITH FILLFACTOR = 85 ON [PRIMARY]
) ON [PRIMARY] 

GO