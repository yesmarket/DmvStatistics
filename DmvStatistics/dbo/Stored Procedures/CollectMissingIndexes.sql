-- =============================================
-- Author:           Ryan Bartsch
-- Create date: 2014-09-22
-- Description:      Collect missing index information
-- =============================================
CREATE PROCEDURE [dbo].[CollectMissingIndexes]
AS
BEGIN
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
                           INSERT INTO [DmvStatistics].[dbo].[MissingIndexes]
                           SELECT 
                                  dm_mid.database_id AS [DatabaseId],
                                  dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) [AverageEstimatedImpact],
                                  dm_migs.last_user_seek AS [LastUserSeek],
                                  OBJECT_NAME(dm_mid.OBJECT_ID, dm_mid.database_id) AS [TableName],
                                  ''CREATE INDEX [IX_'' 
                                         + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) 
                                         + ''_''
                                         + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''''),'', '',''_''),''['',''''),'']'','''') 
                                         + CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ''_'' ELSE '''' END
                                         + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''''),'', '',''_''),''['',''''),'']'','''')
                                         + '']''
                                         + '' ON '' 
                                         + dm_mid.statement
                                         + '' ('' 
                                         + ISNULL (dm_mid.equality_columns,'''')
                                         + CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '','' ELSE '''' END
                                         + ISNULL (dm_mid.inequality_columns, '''')
                                         + '')''
                                         + ISNULL ('' INCLUDE ('' 
                                         + dm_mid.included_columns 
                                         + '')'', '''') AS [CreateIndexStatement],
                                  GETDATE() AS [StatisticCreationDate]
                           FROM master.sys.dm_db_missing_index_groups dm_mig
                           INNER JOIN master.sys.dm_db_missing_index_group_stats dm_migs ON dm_migs.group_handle = dm_mig.index_group_handle
                           INNER JOIN master.sys.dm_db_missing_index_details dm_mid ON dm_mig.index_handle = dm_mid.index_handle
                           WHERE dm_mid.database_ID = DB_ID('''+@dbName+''')');
                     --print @sql;
                     exec sp_executesql @sql;
                     fetch next from @dbNames into @dbName;
              end

       close @dbNames;
       deallocate @dbNames;
END


