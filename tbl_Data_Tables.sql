--Tabela que controla as tabela de auditoria

CREATE TABLE [dbo].[tbl_Data_Tables] (
  [Id] [bigint] IDENTITY (1, 1) NOT NULL, 
  [Table_Name] [nvarchar] (100) NOT NULL, 
  [Log_Table_Name] [nvarchar] (104) NOT NULL, 
  [Active] [bit]  NOT NULL DEFAULT 1, 
  [CreationDate] [datetime]  NOT NULL DEFAULT GETDATE(),
  CONSTRAINT [PK_DataAuditTable] PRIMARY KEY CLUSTERED ([Id]) WITH FILLFACTOR = 85 ON [PRIMARY]
) ON [PRIMARY] 

GO