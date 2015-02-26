
create view [dbo].[vw_WaitStats]
as
       with wati as
              (SELECT 
                     [WaitType],
                     [TotalWaitS],
                     [ResWaitS],
                     [SigWaitS],
                     [AvgWaitS],
                     [AvgResWaitS],
                     [AvgSigWaitS],
                     [WaitCount],
                     [Percentage],
                     [StatisticCreationDate],
                     rn = row_number() over(partition by [WaitType] order by [StatisticCreationDate] asc)
                FROM [DmvStatistics].[dbo].[WaitTimes])
       select 
              WaitType,
              TotalWaitS,
              ResWaitS,
              SigWaitS,
              case 
                     when WaitCount = 0 then 0
                     else CAST ((TotalWaitS / WaitCount) AS DECIMAL (14, 4))
              end AS [AvgWaitS],
              case 
                     when WaitCount = 0 then 0
                     else CAST ((ResWaitS / WaitCount) AS DECIMAL (14, 4))
              end AS [AvgResWaitS],
              WaitCount,
              case 
                     when SumOfTotalWaitS = 0 then 0
                     else CAST(100 * TotalWaitS / SumOfTotalWaitS as decimal(4,2))
              end as Percentage,
              StatisticCreationDate
       from
              (select 
                     w1.WaitType,
                     case 
                           when w2.TotalWaitS > w1.TotalWaitS then w1.TotalWaitS
                           else (w1.TotalWaitS - coalesce(w2.TotalWaitS, 0)) 
                     end as TotalWaitS,
                     case
                           when w2.ResWaitS > w1.ResWaitS then w1.ResWaitS
                           else (w1.ResWaitS - coalesce(w2.ResWaitS, 0)) 
                     end as ResWaitS,
                     case 
                           when w2.SigWaitS > w1.SigWaitS then w1.SigWaitS
                           else (w1.SigWaitS - coalesce(w2.SigWaitS, 0)) 
                     end as SigWaitS,
                     case 
                           when w2.WaitCount > w1.WaitCount then w1.WaitCount
                           else (w1.WaitCount - coalesce(w2.WaitCount, 0)) 
                     end as WaitCount,
                     w1.StatisticCreationDate,
                     case
                           when w2.TotalWaitS > w1.TotalWaitS then SUM(w1.TotalWaitS) over(partition by w1.StatisticCreationDate)
                           else SUM(w1.TotalWaitS - coalesce(w2.TotalWaitS, 0)) over(partition by w1.StatisticCreationDate) 
                     end as SumOfTotalWaitS
              from 
                     wati as w1
                     left outer join wati as w2 
                     on w1.WaitType = w2.WaitType and (w1.rn - 1) = w2.rn) w


