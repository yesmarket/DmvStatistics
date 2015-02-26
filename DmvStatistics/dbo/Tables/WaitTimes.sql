CREATE TABLE [dbo].[WaitTimes] (
    [WaitType]              NVARCHAR (60)   NOT NULL,
    [TotalWaitS]            DECIMAL (14, 2) NOT NULL,
    [ResWaitS]              DECIMAL (14, 2) NOT NULL,
    [SigWaitS]              DECIMAL (14, 2) NOT NULL,
    [AvgWaitS]              DECIMAL (14, 4) NOT NULL,
    [AvgResWaitS]           DECIMAL (14, 4) NOT NULL,
    [AvgSigWaitS]           DECIMAL (14, 4) NOT NULL,
    [WaitCount]             BIGINT          NOT NULL,
    [Percentage]            DECIMAL (4, 2)  NOT NULL,
    [StatisticCreationDate] DATETIME        NOT NULL
);

