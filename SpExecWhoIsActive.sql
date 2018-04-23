USE [master]
GO
 
--Drop procedure if it exists
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_exec_whoisactive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].sp_exec_whoisactive
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Frank Gill
-- Create date: 2014-03-17
-- Description: This procedure executes Adam Machanic's sp_whoisactive, dumps the results to a temp table, and then selects the contents
--              'EXEC sp_whoisactive' can be set up as a keyboard shortcut to allow easy execution of the proc 
-- =============================================
CREATE PROCEDURE sp_exec_whoisactive
AS
BEGIN
 
--Drop temp table if it exists
IF OBJECT_ID('tempdb..#WhoIsActive') IS NOT NULL 
BEGIN
    SELECT 'Dropping'
    DROP TABLE #WhoIsActive
END
 
--Create temp table to hold the results of sp_whoisactive
CREATE TABLE #WhoIsActive
([dd hh:mm:ss.mss] VARCHAR(20)
,[dd hh:mm:ss.mss (avg)] VARCHAR(20)
,[session_id] SMALLINT
,[sql_text] XML
,[sql_command] XML
,[login_name] SYSNAME
,[wait_info] NVARCHAR(4000)
,[tran_log_writes] NVARCHAR(4000)
,[CPU] VARCHAR(30)
,[tempdb_allocations] VARCHAR(30)
,[tempdb_current] VARCHAR(30)
,[blocking_session_id] SMALLINT
,[blocked_session_count] VARCHAR(30)
,[reads] VARCHAR(30)
,[writes] VARCHAR(30)
,[physical_reads] VARCHAR(30)
,[query_plan] XML
,[used_memory] VARCHAR(30)
,[status] VARCHAR(30)
,[tran_start_time] DATETIME
,[open_tran_count] VARCHAR(30)
,[percent_complete] VARCHAR(30)
,[host_name] SYSNAME
,[database_name] SYSNAME
,[program_name] SYSNAME
,[start_time] DATETIME
,[login_time] DATETIME
,[request_id] INT
,[collection_time] DATETIME)
         
 
--Execute sp_whoisactive with #WhoIsActive set as the @destination_table parameter  
EXEC master.dbo.sp_WhoIsActive
@get_plans = 2, 
@get_outer_command = 1, 
@get_transaction_info = 1, 
@get_avg_time = 1, 
@find_block_leaders = 1,
@destination_table = #WhoIsActive
 
--Select the contents of #WhoIsActive, ordered by the blocked_session_count
--The ORDER BY clause can be removed or modified as necessary
SELECT * FROM #WhoIsActive
ORDER BY blocked_session_count DESC
 
END