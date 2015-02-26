CREATE TABLE [dbo].[MissingIndexes] (
    [DatabaseId]             SMALLINT       NOT NULL,
    [AverageEstimatedImpact] FLOAT (53)     NOT NULL,
    [LastUserSeek]           DATETIME       NOT NULL,
    [TableName]              NVARCHAR (128) NOT NULL,
    [CreateIndexStatement]   NVARCHAR (MAX) NOT NULL,
    [StatisticCreationDate]  DATETIME       NOT NULL
);

