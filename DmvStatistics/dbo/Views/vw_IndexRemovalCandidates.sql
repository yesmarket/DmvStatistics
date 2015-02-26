create view [dbo].[vw_IndexRemovalCandidates]
as
       SELECT 
              *
       FROM 
              (select
                     DB_NAME([DatabaseId]) as DatabaseName,
                     [ObjectName],
                     [IndexName],
                     [IndexId],
                     sum([UserSeeks]) as [UserSeeks],
                     sum([UserScans]) as [UserScans],
                     sum([UserLookups]) as [UserLookups],
                     sum([UserUpdates]) as [UserUpdates],
                     max([TableRows]) as [TableRows],
                     [DropIndexStatement]
              from 
                     [DmvStatistics].[dbo].[UnusedIndexes]
              group by 
                     [DatabaseId],
                     [ObjectName],
                     [IndexName],
                     [IndexId],
                     [DropIndexStatement]) as unin
       where
              (unin.[UserSeeks] + unin.[UserScans] + unin.[UserLookups]) = 0 or
              (unin.[UserUpdates] > 10 * (unin.[UserSeeks] + unin.[UserScans] + unin.[UserLookups]) and unin.[UserUpdates] > 10000)
       --order by 
       --     unin.DatabaseName asc,
       --     (unin.[UserSeeks] + unin.[UserScans] + unin.[UserLookups]) asc,
       --     unin.[UserUpdates] desc

