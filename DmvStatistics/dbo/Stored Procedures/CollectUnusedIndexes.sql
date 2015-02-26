CREATE PROCEDURE [dbo].[CollectUnusedIndexes]
AS
BEGIN
       SET NOCOUNT ON;

       declare @dbName as nvarchar(128);
       declare @dbNames as cursor;

       set @dbNames = cursor
              for SELECT    name 
                     FROM   master.sys.databases 
                     where  [database_id] in (DB_ID('MasterV5'), DB_ID('Quote'), DB_ID('MyBudget'), DB_ID('MyBudget7'));

       open @dbNames;

       fetch next from @dbNames into @dbName;

       while @@fetch_status = 0
              begin
                     --print @dbName;
                     declare @sql nvarchar(max);
                     set @sql = (select 
                           N'USE ['+@dbName+'];
                           INSERT INTO [DmvStatistics].[dbo].[UnusedIndexes]
                           SELECT
                                  dm_ius.database_id as [DatabaseId],
                                  o.name AS [ObjectName], 
                                  i.name AS [IndexName], 
                                  i.index_id AS [IndexId], 
                                  dm_ius.user_seeks AS [UserSeeks], 
                                  dm_ius.user_scans AS [UserScans], 
                                  dm_ius.user_lookups AS [UserLookups], 
                                  dm_ius.user_updates AS [UserUpdates], 
                                  p.[TableRows], 
                                  ''DROP INDEX '' 
                                         + QUOTENAME(i.name)
                                         + '' ON '' 
                                         + QUOTENAME(s.name) 
                                         + ''.'' 
                                         + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS [DropIndexStatement],
                                  GETDATE() as [StatisticCreationDate]
                           FROM master.sys.dm_db_index_usage_stats dm_ius
                           INNER JOIN '+@dbName+'.sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
                           INNER JOIN '+@dbName+'.sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
                           INNER JOIN '+@dbName+'.sys.schemas s ON o.schema_id = s.schema_id
                           INNER JOIN (
                                  SELECT 
                                         SUM(p.rows) TableRows, 
                                         p.index_id, 
                                         p.OBJECT_ID
                                  FROM '+@dbName+'.sys.partitions p 
                                  GROUP BY p.index_id, p.OBJECT_ID) p ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
                           WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,''IsUserTable'') = 1
                           AND dm_ius.database_id = DB_ID('''+@dbName+''')
                           AND i.type_desc = ''nonclustered''
                           AND i.is_primary_key = 0
                           AND i.is_unique_constraint = 0;');
                     --print @sql;
                     exec sp_executesql @sql;
                     fetch next from @dbNames into @dbName;
              end

       close @dbNames;
       deallocate @dbNames;
END


