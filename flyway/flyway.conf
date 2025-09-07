USE trading;
GO
-- Create roles
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='app_reader') CREATE ROLE app_reader;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='app_writer') CREATE ROLE app_writer;
GO

-- Grants
GRANT SELECT ON SCHEMA::dbo TO app_reader;
GRANT EXECUTE ON SCHEMA::dbo TO app_writer;
GRANT INSERT, UPDATE ON dbo.price_bars TO app_writer;
GRANT INSERT, UPDATE ON dbo.indicators TO app_writer;
GRANT INSERT ON dbo.trades TO app_writer;
GRANT INSERT, UPDATE ON dbo.predictions TO app_writer;

-- Example SQL Authentication users (or use AAD in Azure SQL)
-- CREATE USER python_svc WITH PASSWORD = 'StrongPass!1';
-- CREATE USER java_svc WITH PASSWORD = 'StrongPass!2';
-- EXEC sp_addrolemember 'app_writer', 'python_svc';
-- EXEC sp_addrolemember 'app_reader', 'java_svc';
