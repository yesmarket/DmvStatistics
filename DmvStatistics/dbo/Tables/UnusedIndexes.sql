CREATE TABLE [dbo].[UnusedIndexes] (
    [DatabaseId]            SMALLINT       NOT NULL,
    [ObjectName]            NVARCHAR (128) NOT NULL,
    [IndexName]             NVARCHAR (128) NOT NULL,
    [IndexId]               INT            NOT NULL,
    [UserSeeks]             BIGINT         NOT NULL,
    [UserScans]             BIGINT         NOT NULL,
    [UserLookups]           BIGINT         NOT NULL,
    [UserUpdates]           BIGINT         NOT NULL,
    [TableRows]             INT            NOT NULL,
    [DropIndexStatement]    NVARCHAR (MAX) NOT NULL,
    [StatisticCreationDate] DATETIME       NOT NULL
);

