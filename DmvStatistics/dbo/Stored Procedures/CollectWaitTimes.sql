
-- =============================================
-- Author:           Ryan Bartsch
-- Create date: 2014-09-22
-- Description:      Collect missing index information
-- =============================================
CREATE PROCEDURE [dbo].[CollectWaitTimes]
AS
BEGIN
       WITH [Waits] AS
              (SELECT
                     [wait_type],
                     [wait_time_ms] / 1000.0 AS [WaitS],
                     ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
                     [signal_wait_time_ms] / 1000.0 AS [SignalS],
                     [waiting_tasks_count] AS [WaitCount],
                     case 
                           when SUM ([wait_time_ms]) OVER() = 0 then 0
                           else 100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() 
                     end AS [Percentage],
                     ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
              FROM sys.dm_os_wait_stats
              WHERE [wait_type] NOT IN (
                     N'CLR_SEMAPHORE',    N'LAZYWRITER_SLEEP',
                     N'RESOURCE_QUEUE',   N'SQLTRACE_BUFFER_FLUSH',
                     N'SLEEP_TASK',       N'SLEEP_SYSTEMTASK',
                     N'WAITFOR',          N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
                     N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
                     N'XE_TIMER_EVENT',   N'XE_DISPATCHER_JOIN',
                     N'LOGMGR_QUEUE',     N'FT_IFTS_SCHEDULER_IDLE_WAIT',
                     N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
                     N'CLR_AUTO_EVENT',   N'DISPATCHER_QUEUE_SEMAPHORE',
                     N'TRACEWRITE',       N'XE_DISPATCHER_WAIT',
                     N'BROKER_TO_FLUSH',  N'BROKER_EVENTHANDLER',
                     N'FT_IFTSHC_MUTEX',  N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                     N'DIRTY_PAGE_POLL')
              )
       INSERT INTO [DmvStatistics].[dbo].[WaitTimes]
                        ([WaitType]
                        ,[TotalWaitS]
                        ,[ResWaitS]
                        ,[SigWaitS]
                        ,[AvgWaitS]
                        ,[AvgResWaitS]
                        ,[AvgSigWaitS]
                        ,[WaitCount]
                        ,[Percentage]
                        ,[StatisticCreationDate])
       SELECT
              [W1].[wait_type] AS [WaitType], 
              CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [TotalWaitS],
              CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [ResWaitS],
              CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [SigWaitS],
              case 
                     when [W1].[WaitCount] = 0 then 0
                     else CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) 
              end AS [AvgWaitS],
              case 
                     when [W1].[WaitCount] = 0 then 0
                     else CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) 
              end AS [AvgResWaitS],
              case 
                     when [W1].[WaitCount] = 0 then 0
                     else CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) 
              end AS [AvgSigWaitS],
              [W1].[WaitCount] AS [WaitCount],
              CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
              GETDATE() AS [StatisticCreationDate]
       FROM [Waits] AS [W1]
       INNER JOIN [Waits] AS [W2]
              ON [W2].[RowNum] <= [W1].[RowNum]
       GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
              [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
       HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold
END

